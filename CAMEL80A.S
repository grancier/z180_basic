;
;  camel80a.s      CamelForth modified to run on the Alerton
;  MicroView (Rev. 2) board.
;
;  This file was derived from the original camel80.s, as
;  created by Bradford J. Rodriquez (1994) and modified
;  by D. Beattie, Jr. (1998).
;
;  Modifications for the MicroView Rev 2 done June 2000
;  by Karl E. Lunt.
;


; ===============================================
; CamelForth for the Zilog Z80
; (c) 1994 Bradford J. Rodriguez
; Permission is granted to freely copy, modify,
; and distribute this program for personal or
; educational use.  Commercial inquiries should
; be directed to the author at 221 King St. E.,
; #32, Hamilton, Ontario L8N 1B5 Canada
;
; CAMEL80.S: Code Primitives
;   Source code is for the Zilog Macro Assembler.
;   Forth words are documented as follows:
;x   NAME     stack -- stack    description
;   where x=C for ANS Forth Core words, X for ANS
;   Extensions, Z for internal or private words.
;
; Direct-Threaded Forth model for Zilog Z80
; 16 bit cell, 8 bit char, 8 bit (byte) adrs unit
;    Z80 BC = Forth TOS (top Param Stack item)
;        HL =       W    working register
;        DE =       IP   Interpreter Pointer
;        SP =       PSP  Param Stack Pointer
;        IX =       RSP  Return Stack Pointer
;        IY =       UP   User area Pointer
;    A, alternate register set = temporaries
;
; Revision history:
;   19 Aug 94 v1.0
;   25 Jan 95 v1.01  now using BDOS function 0Ah
;       for interpreter input; TIB at 82h.
;   02 Mar 95 v1.02  changed ALIGN to ALIGNED in
;       S" (S"); changed ,BRANCH to ,XT in DO.
;   17 NOV 1998 SOURCE CODE CONVERTED TO ZMA v1.2
;       (Zilog Macro Assembler) by D. Beattie Jr.
;   22 Jun 2000  Extensive changes to support
;       Alerton MicroView (Rev. 2) electronics
;		by Karl E. Lunt
;


; ===============================================
; Macros to define Forth headers
; HEAD  label,length,name,action
; IMMED label,length,name,action
;    label  = assembler name for this word
;             (special characters not allowed)
;    length = length of name field
;    name   = Forth's name for this word
;    action = code routine for this word, e.g.
;             DOCOLON, or DOCODE for code words
; IMMED defines a header for an IMMEDIATE word.
;
docode  EQU 0      ; flag to indicate CODE words
link    .SET 0     ; link to previous Forth word

head    MACRO   label,length,name,action
        DW link
        DB 0
link    .SET $
        DB &length,&name
&label:
        IF  !(&action=docode)
        call &action
        ENDIF
        .ENDM

immed   MACRO   label,length,name,action
        DW link
        DB 1
link    .SET $
        DB length,&name
&label:
        IF  !(&action=docode)
        call &action
        ENDIF
        .ENDM

; The NEXT macro (7 bytes) assembles the 'next'
; code in-line in every Z80 CamelForth CODE word.
next    MACRO
        ex de,hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ex de,hl
        jp (hl)
        .ENDM

; NEXTHL is used when the IP is already in HL.
nexthl  MACRO
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ex de,hl
        jp (hl)
        .ENDM


;
;  Define the I/O registers used by the Z180 hardware.
;

CNTLA0	equ		00h					; control reg A for ASCI0
CNTLB0	equ		02h					; control reg B for ASCI0
STAT0	equ		04h					; status reg for ASCI0
TDR0	equ		06h					; transmit data reg for ASCI0
RDR0	equ		08h					; receive data reg for ASCI0
IL		equ		33h					; interrupt vector low reg
RCR		equ		36h					; refresh control reg
ICR		equ		3fh					; I/O control reg
DSTAT	equ		30h					; DMA status reg
OMCR	equ		3eh					; operation mode control reg

CNTR	equ		0ah					; CSI/O control reg
TRDR	equ		0bh					; transmit/receive data reg (CSI/O)


CBR		equ		038h				; common base reg
BBR		equ		039h				; bank base reg
CBAR	equ		03ah				; common/bank area reg

bankbeg	equ		8000h				; start of bank RAM
cma1beg	equ		9000h				; start of user program RAM
banksize	equ	cma1beg-bankbeg		; size of bank RAM area
ramend	equ		0ff00h				; end of user program RAM

;
;  Hardware map
;
;  The MicroViewR2 board contains several hardware devices in the
;  I/O map.  Here is a list of what is available and where it lives:
;
;  Eight-key keypad input port at 60h and 80h (read only).  Reads
;  of either port return exactly the same data, but accessing either
;  port also controls the SS* line used to access the 68hc68T1 real-time
;  clock:
;  		reads of 80h return the keyboard port and pull the RTC SS low,
;  		reads of 60h return the keyboard port and pull the RTC SS high.
;
;  SCC2691 UART at 0a0h - 0a7h (read/write).
;
;  Four-line by 20 char LCD at 0c0h - 0c1h (read/write).
;  Reads/writes to 0c0h affect the CMD register.
;  Reads/writes to 0c1h affect the DATA register.
;
;  Watchdog timer/reset supervisor at 0e0h (write only).  This chip
;  forces a reset if not serviced within approximately two seconds.
;  The WATCHDOG macro and the PAUSE high-level word provide this
;  servicing automatically.  Several of the I/O primitives now
;  include one of these words, so the system doesn't time out
;  waiting for I/O to complete.  Note that the watchdog IC (a MAX705)
;  can be disabled by cutting the trace at U4-6 and connecting
;  a wire between U4-6 and U6-12.  This mod routes A0 to the watchdog
;  timer, ensuring that it cannot ever time out.
;
;  Additionally, the MV2 has a 68hc68t1 real-time clock (RTC) connected to
;  the CSIO subsystem.  The CSIO acts like the Motorola Serial Peripheral
;  Interface (SPI), providing a high-speed synchronous interface.  Note
;  that unlike most Motorola devices, the RTC is selected when its slave-
;  select (SS) line is HIGH.  Also unlike Motorola SPI devices, the Z180
;  exchanges data LSB first; I've provided the word CBITREV to reverse
;  bits within a char if you want to talk to the Motorola world.
;

keypad_clr	equ		80h				; read keypad, deselect RTC
keypad_set	equ		60h				; read keypad, select RTC

wdog		equ		0e0h			; write this addr to hold off the watchdog

forcecold	equ		03h				; mask to check force COLD start (N & + keys)
skipauto	equ		10h				; mask to skip execution of AUTOSTART (P key)


;
;  Define the WATCHDOG macro.  Insert this macro in any assembly language
;  routine that might hog the MCU for longer than the MicroView's MAX705
;  watchdog timer.
;
;  This macro writes whatever is in A to the watchdog.  The value is A
;  doesn't matter, only the write operation is needed to reset the 'dog.
;

WATCHDOG	MACRO
			out0		(wdog),a
			.ENDM




; RESET AND INTERRUPT VECTORS ===================
;
;  The MicroViewR2 version runs standalone, so the
;  reset vector must exist at 0000h.
;

;
;  Following reset, the MV2 memory map must be rearranged
;  to give:
;  Common Area 0    0000h - 7fffh		EEPROM
;  Bank Area        8000h - 8fffh		RAM disk pages (future)
;  Common Area 1    9000h - ffffh		RAM for program
;
;  The MV2 has two 128K SRAM chips, SRC1 and SRC2.  SRC1 is addressed
;  from 40000h to 5ffffh, while SRC2 appears from 60000h to 7ffffh.
;  After the setup following reset, BBR controls the physical address
;  generated for references in the Bank Area; refer to the Z8018x MPU
;  User Manual for details.
;
;  This program must set up SRC1 and SRC2 so that the top 24K of SRC2
;  appears in Common Area 1, while all of SRC1 and the remainder of SRC2
;  appear in the Bank Area.  This allows Common Area 1 to act as the
;  user area RAM, while the Bank Area acts as a large RAM disk.  This setup
;  for Common Area 1 requires writing a 70h to CBR:
;
;  CBR = 70h, logical addr = 9000h, physical addr = 70000h + 09000h = 79000h.
;  CBR = 70h, logical addr = ffffh, physical addr = 70000h + 0ffffh = 7ffffh.
;
;  Setting up BBR to access the remainder of RAM means changing the value in
;  BBR to reflect the required physical address range.  Some sample values of
;  BBR and the resulting physical addresses are:
;
;  BBR = 38h, logical addr = 8000h, physical addr = 38000h + 8000h = 40000h.
;  BBR = 39h, logical addr = 8000h, physical addr = 39000h + 8000h = 41000h.
;  BBR = 56h, logical addr = 8fffh, physical addr = 56000h + 8fffh = 5efffh.
;  BBR = 70h, logical addr = 8000h, physical addr = 70000h + 8000h = 78000h.
;  BBR = 70h, logical addr = 8fffh, physical addr = 70000h + 8fffh = 78fffh.
;
;  This arrangement of CBR and BBR yields a 28K section of program RAM at the
;  top of memory, with a 4K window into the RAM disk immediately below it.  By
;  changing the value in BBR, the kernel can access any of the 228 1K RAM disk
;  pages, four pages at a time.
;

        ORG     0000h     		; z180 reset vector loc
		jp		reset			; transfer to the program start

		ORG		0038h			; z180 INT0 vector loc (mode 1)
		jp		reset			; use this for now

		ORG		0066h			; z180 NMI vector loc
		jp		reset			; use this for now



		ORG		0080h			; reset vector table (see reset below)
		DW		reset			; INT1
		DW		reset			; INT2
		DW		reset			; PRT0
		DW		reset			; PRT1
		DW		reset			; DMA0
		DW		reset			; DMA1
		DW		reset			; CSI/O
		DW		reset			; ASCI 0
		DW		reset			; ASCI 1



		ORG		0100h			; start of program
reset
		di						; no interrupts
		ld		a,80h			; set up vector table (see above)
		out0	(IL),a
		xor		a				; get a 0
		out0	(RCR),a			; shut off refresh
		out0	(ICR),a			; set up I/O control
		out0	(DSTAT),a		; shut off DMA
		out0	(CNTR),a		; shut off CSI/O
;		out0	(OMCR),a		; set operation mode

		ld		a,98h			; BA = 8000h to 8fffh, CA1 = 9000h to 0ffffh
		out0	(CBAR),a		; set up MMU reg
		ld		a,38h			; logical 8000h + 38000h gives physical 40000h
		out0	(BBR),a			; RAM disk area = 40000h to 78fffh
		ld		a,70h			; logical 9000h + 70000h gives physical 79000h
		out0	(CBR),a			; user RAM area = 79000h to 7ffffh

		ld		a,7ch			; rcrv & xmtr on, clear errors, 8N1, RTS high
		out0	(CNTLA0),a		; do it
		ld		a,21h			; set dividers for 9600 baud (phi = 9.216 MHz)
		out0	(CNTLB0),a		; do it

		ld		a,03h			; set CSIO baud rate to /160
		out0	(CNTR),a		; do it

;
;  The following code sends an endless stream of 'A's to the terminal.
;  If you need a quick test to verify that you got through the reset
;  and intial configuration, uncomment this code, burn a ROM, and
;  try it.
;

;reset1
;	in0		a,(STAT0)			; get status of ASC0
;	and		2h					; test TDRE
;	jr		z,reset1			; loop until TDRE=1
;	ld		a,'A'				; move byte into A
;	out0	(TDR0),a			; send byte to ASC0
;	jp		reset1				; do forever
		
		ld		hl,ramend		; top of RAM is end-of-memory
		dec		h				; EM - 100h = top of param stack
		ld		sp,hl			; move to stack pointer
		inc		h				; recover EM
		push	hl				; need to move it
		pop		ix				; into IX
		dec		h				; calc EM - 200h
		dec		h
		push	hl				; this is bottom of user area
		pop		iy				; move to IY
		ld		de,1			; do reset if COLD returns
		jp		COLD			; start Forth


;
;  Because of the above use of the MMU, the memory map for this system
;  looks like this:
;
;  0000h to 7fffh		Forth kernel in EEPROM or flash
;  8000h to 8fffh		RAM disk pages 0 to 228, available 4 pages at a time
;  9000h to 907fh		Terminal Input Buffer, 128 bytes
;  9080h to fcffh		Forth dictionary
;  fd00h				User area, 128 bytes
;  fe00h				Parameter stack, 128 bytes, grows down
;  fe00h ?				HOLD area, 40 bytes, grows down
;  fe28h ?				PAD buffer, 88 bytes
;  ff00h				Return stack, 128 bytes, grows down
;  ff00h				End of memory
	
;
; See also the definitions of U0, S0, and R0
; in the "system variables & constants" area.
; A task w/o terminal input requires 200h bytes.
; Double all except TIB and PAD for 32-bit CPUs.


;
;  The data table at keypdtbl is used by the KEYKPD word to
;  translate a pressed key on the MicroView2 keypad into an
;  ASCII character.  Entries in the table are of the form:
;
;		DB		portvalue,ASCIIchar
;
;  where portvalue is the inverted value read from the keypad
;  port, and ASCIIchar is the character corresponding to the
;  key pressed.  If you want to change any keys, or add your own,
;  feel free.
;

keypdtbl
		DB		01h,'n'
		DB		02h,'+'
		DB		04h,'-'
		DB		08h,'d'
		DB		10h,'p'
		DB		20h,'l'
		DB		40h,'r'
		DB		80h,'u'
		DB		03h,'N'					; n and +
		DB		0ah,'D'					; d and +
		DB		12h,'P'					; p and +
		DB		22h,'L'					; l and +
		DB		42h,'R'					; r and +
		DB		82h,'U'					; u and +
		DB		05h,'m'					; n and -
		DB		0dh,'c'					; d and -
		DB		14h,'o'					; p and -
		DB		24h,'k'					; l and -
		DB		44h,0dh					; r and -
		DB		84h,'t'					; u and -
keypdtblz



;
;  The data table at lcdpostbl maps a row number from 0 to 3
;  into an address in the LCD's memory.  This table is used
;  by LCDRC to move the cursor to a specified location on the
;  LCD screen.
;

lcdpostbl
		DB		080h,0c0h,094h,0d4h



; INTERPRETER LOGIC =============================
; See also "defining words" at end of this file

;C EXIT     --      exit a colon definition
    head EXIT,4,"exit",docode
        ld e,(ix+0)    ; pop old IP from ret stk
        inc ix
        ld d,(ix+0)
        inc ix
        next

;Z lit      -- x    fetch inline literal to stack
; This is the primtive compiled by LITERAL.
    head LIT,3,"lit",docode
        push bc        ; push old TOS
        ld a,(de)      ; fetch cell at IP to TOS,
        ld c,a         ;        advancing IP
        inc de
        ld a,(de)
        ld b,a
        inc de
        next

;C EXECUTE   i*x xt -- j*x   execute Forth word
;C                           at 'xt'
    head EXECUTE,7,"execute",docode
        ld h,b          ; address of word -> HL
        ld l,c
        pop bc          ; get new TOS
        jp (hl)         ; go do Forth word

; DEFINING WORDS ================================

; ENTER, a.k.a. DOCOLON, entered by CALL ENTER
; to enter a new high-level thread (colon def'n.)
; (internal code fragment, not a Forth word)
; N.B.: DOCOLON must be defined before any
; appearance of 'docolon' in a 'word' macro!
docolon                ; (alternate name)
enter
		dec ix         ; push old IP on ret stack
        ld (ix+0),d
        dec ix
        ld (ix+0),e
        pop hl         ; param field adrs -> IP
        nexthl         ; use the faster 'nexthl'

;C VARIABLE   --      define a Forth variable
;   CREATE 1 CELLS ALLOT ;
; Action of RAM variable is identical to CREATE,
; so we don't need a DOES> clause to change it.
    head VARIABLE,8,"variable",docolon
        DW CREATE,LIT,1,CELLS,ALLOT,EXIT
; DOVAR, code action of VARIABLE, entered by CALL
; DOCREATE, code action of newly created words
docreate:
dovar:  ; -- a-addr
        pop hl     ; parameter field address
        push bc    ; push old TOS
        ld b,h     ; pfa = variable's adrs -> TOS
        ld c,l
        next

;C CONSTANT   n --      define a Forth constant
;   CREATE , DOES> (machine code fragment)
    head CONSTANT,8,"constant",docolon
        DW CREATE,COMMA,XDOES
; DOCON, code action of CONSTANT,
; entered by CALL DOCON
docon:  ; -- x
        pop hl     ; parameter field address
        push bc    ; push old TOS
        ld c,(hl)  ; fetch contents of parameter
        inc hl     ;    field -> TOS
        ld b,(hl)
        next

;Z USER     n --        define user variable 'n'
;   CREATE , DOES> (machine code fragment)
    head USER,4,"user",docolon
        DW CREATE,COMMA,XDOES
; DOUSER, code action of USER,
; entered by CALL DOUSER
douser:  ; -- a-addr
        pop hl     ; parameter field address
        push bc    ; push old TOS
        ld c,(hl)  ; fetch contents of parameter
        inc hl     ;    field
        ld b,(hl)
        push iy    ; copy user base address to HL
        pop hl
        add hl,bc  ;    and add offset
        ld b,h     ; put result in TOS
        ld c,l
        next

; DODOES, code action of DOES> clause
; entered by       CALL fragment
;                  parameter field
;                       ...
;        fragment: CALL DODOES
;                  high-level thread
; Enters high-level thread with address of
; parameter field on top of stack.
; (internal code fragment, not a Forth word)
dodoes: ; -- a-addr
        dec ix         ; push old IP on ret stk
        ld (ix+0),d
        dec ix
        ld (ix+0),e
        pop de         ; adrs of new thread -> IP
        pop hl         ; adrs of parameter field
        push bc        ; push old TOS onto stack
        ld b,h         ; pfa -> new TOS
        ld c,l
        next


;
;  Removed cpmbdos word, as CP/M is not available stand-alone.
;
; CP/M TERMINAL I/O =============================
;cpmbdos EQU 5h          ; CP/M BDOS entry point

;
;  Removed BDOS word; this version of Forth runs stand-alone,
;  so there is no CP/M to call.
;
;Z BDOS   de c -- a   call CP/M BDOS
;    head BDOS,4,"BDOS",docode
;        ex de,hl    ; save important Forth regs
;        pop de      ;  (DE,IX,IY) & pop DE value
;        push hl
;        push ix
;        push iy
;        call cpmbdos
;        ld c,a      ; result in TOS
;        ld b,0
;        pop iy      ; restore Forth regs
;        pop ix
;        pop de
;        next

;
;  Created EMITASC0 to use the Z180 hardware directly.
;  This word provides the EMIT function for the ASC0
;  serial port.  See the EMIT word and the EMITV variable.
;
;  Note that this word uses the WATCHDOG macro.
;
;C EMITASC0     c --    output character to ASC0 serial port
	head	EMITASC0,8,"emitasc0",docode
emitas0:
	WATCHDOG								; pet the dog
	in0		a,(STAT0)						; get status of ASC0
	and		2h								; test TDRE
	jr		z,emitas0						; loop until TDRE=1
	ld		a,c								; move byte into A
	out0	(TDR0),a						; send byte to ASC0
	pop		bc								; pop new TOS
	next


;
;  SAVEKEY removed, as directly accessing the receive flags doesn't
;  disturb the contents of the ASC0 receive data register.
;

;
;  Created KEY?ASC0 to use the Z180 hardware directly.
;  This word provides the KEY? function for the ASC0
;  serial port.  See the KEY? word and the KEY?V variable.
;
;  Note that this word uses the WATCHDOG macro.
;
;X KEY?ASC0     -- f	return true if char waiting
	head	KEYQASC0,8,"key?asc0",docode
	WATCHDOG								; pet the dog
	push	bc								; save old TOS
	in0		a,(STAT0)						; get status of ASC0
	and		80h								; test RDRF, use as flag
	ld		c,a								; move to low byte of TOS
	ld		b,0								; force top byte to 0
	next


;
;  Created KEYASC0 to use the Z180 hardware directly.
;  This word provides the KEY function for the ASC0
;  serial port.  See the KEY word and the KEYV variable.
;
;  Note that this word uses the WATCHDOG macro.
;
;C KEYASC0      -- c	get character from keyboard
	head	KEYASC0,7,"keyasc0",docode
	push	bc								; save old TOS
keyasc0
	WATCHDOG								; pet the dog
	in0		a,(STAT0)						; get status of ASC0
	and		80h								; test RDRF
	jr		z,keyasc0						; loop until char available
	in0		a,(RDR0)						; get char
	ld		c,a								; move to new TOS
	ld		b,0								; force MSB of TOS to 0
	next
	


;
;  PAUSE is the traditional Forth multi-tasking switcher.  Although
;  this Forth is not (yet) a multi-tasker, I've included PAUSE here
;  for future expansion.
;
;  Note that this version of PAUSE uses the WATCHDOG timer to hold
;  off a watchdog reset.  You should include PAUSE in any Forth word
;  that might lock up the MCU longer than the MicroView's MAX705
;  watchdog timeout.  This includes any custom I/O routines you add
;  to these files, as well as any high-level Forth words you define
;  at run-time.  You can think of PAUSE as the high-level version of
;  the WATCHDOG macro.
;

	head	PAUSE,5,"pause",docode
	WATCHDOG								; pet the dog
	next



;
;  Removed CPMACCEPT, as CP/M is not available in stand-alone
;  system.
;
;Z CPMACCEPT  c-addr +n -- +n'  get line of input
;   SWAP 2 - TUCK C!      max # of characters
;   DUP 0A BDOS DROP      CP/M Get Console Buffer
;   1+ C@  0A EMIT ;      get returned count
; Note: requires the two locations before c-addr
; to be available for use.
;    head CPMACCEPT,9,"CPMACCEPT",docolon
;        DW SWOP,LIT,2,MINUS,TUCK,CSTORE
;        DW DUP,LIT,0Ah,BDOS,DROP
;        DW ONEPLUS,CFETCH,LIT,0Ah,EMIT,EXIT


;
;  Removed BYE until I decide how to handle this.  (COLD??)
;
;X BYE     i*x --    return to CP/M
;    head BYE,3,"bye",docode
;        jp 0

; STACK OPERATIONS ==============================

;C DUP      x -- x x      duplicate top of stack
    head DUP,3,"dup",docode
pushtos: push bc
        next

;C ?DUP     x -- 0 | x x    DUP if nonzero
    head QDUP,4,"?dup",docode
        ld a,b
        or c
        jr nz,pushtos
        next

;C DROP     x --          drop top of stack
    head DROP,4,"drop",docode
poptos: pop bc
        next

;C SWAP     x1 x2 -- x2 x1    swap top two items
    head SWOP,4,"swap",docode
        pop hl
        push bc
        ld b,h
        ld c,l
        next

;C OVER    x1 x2 -- x1 x2 x1   per stack diagram
    head OVER,4,"over",docode
        pop hl
        push hl
        push bc
        ld b,h
        ld c,l
        next

;C ROT    x1 x2 x3 -- x2 x3 x1  per stack diagram
    head ROT,3,"rot",docode
        ; x3 is in TOS
        pop hl          ; x2
        ex (sp),hl      ; x2 on stack, x1 in hl
        push bc
        ld b,h
        ld c,l
        next

;X NIP    x1 x2 -- x2           per stack diagram
    head NIP,3,"nip",docolon
        DW SWOP,DROP,EXIT

;X TUCK   x1 x2 -- x2 x1 x2     per stack diagram
    head TUCK,4,"tuck",docolon
        DW SWOP,OVER,EXIT

;C >R    x --   R: -- x   push to return stack
    head TOR,2,">r",docode
        dec ix          ; push TOS onto rtn stk
        ld (ix+0),b
        dec ix
        ld (ix+0),c
        pop bc          ; pop new TOS
        next

;C R>    -- x    R: x --   pop from return stack
    head RFROM,2,"r>",docode
        push bc         ; push old TOS
        ld c,(ix+0)     ; pop top rtn stk item
        inc ix          ;       to TOS
        ld b,(ix+0)
        inc ix
        next

;C R@    -- x     R: x -- x   fetch from rtn stk
    head RFETCH,2,"r@",docode
        push bc         ; push old TOS
        ld c,(ix+0)     ; fetch top rtn stk item
        ld b,(ix+1)     ;       to TOS
        next

;Z SP@  -- a-addr       get data stack pointer
    head SPFETCH,3,"sp@",docode
        push bc
        ld hl,0
        add hl,sp
        ld b,h
        ld c,l
        next

;Z SP!  a-addr --       set data stack pointer
    head SPSTORE,3,"sp!",docode
        ld h,b
        ld l,c
        ld sp,hl
        pop bc          ; get new TOS
        next

;Z RP@  -- a-addr       get return stack pointer
    head RPFETCH,3,"rp@",docode
        push bc
        push ix
        pop bc
        next

;Z RP!  a-addr --       set return stack pointer
    head RPSTORE,3,"rp!",docode
        push bc
        pop ix
        pop bc
        next

; MEMORY AND I/O OPERATIONS =====================

;C !        x a-addr --   store cell in memory
    head STORE,1,'!',docode
        ld h,b          ; address in hl
        ld l,c
        pop bc          ; data in bc
        ld (hl),c
        inc hl
        ld (hl),b
        pop bc          ; pop new TOS
        next

;C C!      char c-addr --    store char in memory
    head CSTORE,2,"c!",docode
        ld h,b          ; address in hl
        ld l,c
        pop bc          ; data in bc
        ld (hl),c
        pop bc          ; pop new TOS
        next

;C @       a-addr -- x   fetch cell from memory
    head FETCH,1,'@',docode
        ld h,b          ; address in hl
        ld l,c
        ld c,(hl)
        inc hl
        ld b,(hl)
        next

;C C@     c-addr -- char   fetch char from memory
    head CFETCH,2,"c@",docode
        ld a,(bc)
        ld c,a
        ld b,0
        next

;Z PC!     char c-addr --    output char to port
    head PCSTORE,3,"pc!",docode
        pop hl          ; char in L
        out (c),l       ; to port (BC)
        pop bc          ; pop new TOS
        next

;Z PC@     c-addr -- char   input char from port
    head PCFETCH,3,"pc@",docode
        in c,(c)        ; read port (BC) to C
        ld b,0
        next

; ARITHMETIC AND LOGICAL OPERATIONS =============

;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    head PLUS,1,'+',docode
        pop hl
        add hl,bc
        ld b,h
        ld c,l
        next

;X M+       d n -- d         add single to double
    head MPLUS,2,"m+",docode
        ex de,hl
        pop de          ; hi cell
        ex (sp),hl      ; lo cell, save IP
        add hl,bc
        ld b,d          ; hi result in BC (TOS)
        ld c,e
        jr nc,mplus1
        inc bc
mplus1: pop de          ; restore saved IP
        push hl         ; push lo result
        next

;C -      n1/u1 n2/u2 -- n3/u3    subtract n1-n2
    head MINUS,1,'-',docode
        pop hl
        or a
        sbc hl,bc
        ld b,h
        ld c,l
        next

;C AND    x1 x2 -- x3            logical AND
    head AND,3,"and",docode
        pop hl
        ld a,b
        and h
        ld b,a
        ld a,c
        and l
        ld c,a
        next

;C OR     x1 x2 -- x3           logical OR
    head OR,2,"or",docode
        pop hl
        ld a,b
        or h
        ld b,a
        ld a,c
        or l
        ld c,a
        next

;C XOR    x1 x2 -- x3            logical XOR
    head XOR,3,"xor",docode
        pop hl
        ld a,b
        xor h
        ld b,a
        ld a,c
        xor l
        ld c,a
        next

;C INVERT   x1 -- x2            bitwise inversion
    head INVERT,6,"invert",docode
        ld a,b
        cpl
        ld b,a
        ld a,c
        cpl
        ld c,a
        next

;C NEGATE   x1 -- x2            two's complement
    head NEGATE,6,"negate",docode
        ld a,b
        cpl
        ld b,a
        ld a,c
        cpl
        ld c,a
        inc bc
        next

;C 1+      n1/u1 -- n2/u2       add 1 to TOS
    head ONEPLUS,2,"1+",docode
        inc bc
        next

;C 1-      n1/u1 -- n2/u2     subtract 1 from TOS
    head ONEMINUS,2,"1-",docode
        dec bc
        next

;Z ><      x1 -- x2         swap bytes (not ANSI)
    head SWAPBYTES,2,"><",docode
        ld a,b
        ld b,c
        ld c,a
        next

;C 2*      x1 -- x2         arithmetic left shift
    head TWOSTAR,2,"2*",docode
        sla c
        rl b
        next

;C 2/      x1 -- x2        arithmetic right shift
    head TWOSLASH,2,"2/",docode
        sra b
        rr c
        next

;C LSHIFT  x1 u -- x2    logical L shift u places
    head LSHIFT,6,"lshift",docode
        ld b,c        ; b = loop counter
        pop hl        ;   NB: hi 8 bits ignored!
        inc b         ; test for counter=0 case
        jr lsh2
lsh1:   add hl,hl     ; left shift HL, n times
lsh2:   djnz lsh1
        ld b,h        ; result is new TOS
        ld c,l
        next

;C RSHIFT  x1 u -- x2    logical R shift u places
    head RSHIFT,6,"rshift",docode
        ld b,c        ; b = loop counter
        pop hl        ;   NB: hi 8 bits ignored!
        inc b         ; test for counter=0 case
        jr rsh2
rsh1:   srl h         ; right shift HL, n times
        rr l
rsh2:   djnz rsh1
        ld b,h        ; result is new TOS
        ld c,l
        next

;C +!     n/u a-addr --       add cell to memory
    head PLUSSTORE,2,"+!",docode
        pop hl
        ld a,(bc)       ; low byte
        add a,l
        ld (bc),a
        inc bc
        ld a,(bc)       ; high byte
        adc a,h
        ld (bc),a
        pop bc          ; pop new TOS
        next

; COMPARISON OPERATIONS =========================

;C 0=     n/u -- flag    return true if TOS=0
    head ZEROEQUAL,2,"0=",docode
        ld a,b
        or c            ; result=0 if bc was 0
        sub 1           ; cy set   if bc was 0
        sbc a,a         ; propagate cy through A
        ld b,a          ; put 0000 or FFFF in TOS
        ld c,a
        next

;C 0<     n -- flag      true if TOS negative
    head ZEROLESS,2,"0<",docode
        sla b           ; sign bit -> cy flag
        sbc a,a         ; propagate cy through A
        ld b,a          ; put 0000 or FFFF in TOS
        ld c,a
        next

;C =      x1 x2 -- flag         test x1=x2
    head EQUAL,1,'=',docode
        pop hl
        or a
        sbc hl,bc       ; x1-x2 in HL, SZVC valid
        jr z,tostrue
tosfalse: ld bc,0
        next

;X <>     x1 x2 -- flag    test not eq (not ANSI)
    head NOTEQUAL,2,"<>",docolon
        DW EQUAL,ZEROEQUAL,EXIT

;C <      n1 n2 -- flag        test n1<n2, signed
    head LESS,1,'<',docode
        pop hl
        or a
        sbc hl,bc       ; n1-n2 in HL, SZVC valid
; if result negative & not OV, n1<n2
; neg. & OV => n1 +ve, n2 -ve, rslt -ve, so n1>n2
; if result positive & not OV, n1>=n2
; pos. & OV => n1 -ve, n2 +ve, rslt +ve, so n1<n2
; thus OV reverses the sense of the sign bit
        jp pe,revsense  ; if OV, use rev. sense
        jp p,tosfalse   ;   if +ve, result false
tostrue: ld bc,0ffffh   ;   if -ve, result true
        next
revsense: jp m,tosfalse ; OV: if -ve, reslt false
        jr tostrue      ;     if +ve, result true

;C >     n1 n2 -- flag         test n1>n2, signed
    head GREATER,1,'>',docolon
        DW SWOP,LESS,EXIT

;C U<    u1 u2 -- flag       test u1<n2, unsigned
    head ULESS,2,"u<",docode
        pop hl
        or a
        sbc hl,bc       ; u1-u2 in HL, SZVC valid
        sbc a,a         ; propagate cy through A
        ld b,a          ; put 0000 or FFFF in TOS
        ld c,a
        next

;X U>    u1 u2 -- flag     u1>u2 unsgd (not ANSI)
    head UGREATER,2,"u>",docolon
        DW SWOP,ULESS,EXIT

; LOOP AND BRANCH OPERATIONS ====================

;Z branch   --                  branch always
    head BRANCH,6,"branch",docode
dobranch: ld a,(de)     ; get inline value => IP
        ld l,a
        inc de
        ld a,(de)
        ld h,a
        nexthl

;Z ?branch   x --              branch if TOS zero
    head QBRANCH,7,"?branch",docode
        ld a,b
        or c            ; test old TOS
        pop bc          ; pop new TOS
        jr z,dobranch   ; if old TOS=0, branch
        inc de          ; else skip inline value
        inc de
        next

;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2
;Z                          run-time code for DO
; '83 and ANSI standard loops terminate when the
; boundary of limit-1 and limit is crossed, in
; either direction.  This can be conveniently
; implemented by making the limit 8000h, so that
; arithmetic overflow logic can detect crossing.
; I learned this trick from Laxen & Perry F83.
; fudge factor = 8000h-limit, to be added to
; the start value.
    head XDO,4,"(do)",docode
        ex de,hl
        ex (sp),hl   ; IP on stack, limit in HL
        ex de,hl
        ld hl,8000h
        or a
        sbc hl,de    ; 8000-limit in HL
        dec ix       ; push this fudge factor
        ld (ix+0),h  ;    onto return stack
        dec ix       ;    for later use by 'I'
        ld (ix+0),l
        add hl,bc    ; add fudge to start value
        dec ix       ; push adjusted start value
        ld (ix+0),h  ;    onto return stack
        dec ix       ;    as the loop index.
        ld (ix+0),l
        pop de       ; restore the saved IP
        pop bc       ; pop new TOS
        next

;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.  Note that LOOP
; terminates when index=8000h.
    head XLOOP,6,"(loop)",docode
        exx
        ld bc,1
looptst: ld l,(ix+0)  ; get the loop index
        ld h,(ix+1)
        or a
        adc hl,bc    ; increment w/overflow test
        jp pe,loopterm  ; overflow=loop done
        ; continue the loop
        ld (ix+0),l  ; save the updated index
        ld (ix+1),h
        exx
        jr dobranch  ; take the inline branch
loopterm: ; terminate the loop
        ld bc,4      ; discard the loop info
        add ix,bc
        exx
        inc de       ; skip the inline branch
        inc de
        next

;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.
    head XPLUSLOOP,7,"(+loop)",docode
        pop hl      ; this will be the new TOS
        push bc
        ld b,h
        ld c,l
        exx
        pop bc      ; old TOS = loop increment
        jr looptst

;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
    head II,1,'i',docode
        push bc     ; push old TOS
        ld l,(ix+0) ; get current loop index
        ld h,(ix+1)
        ld c,(ix+2) ; get fudge factor
        ld b,(ix+3)
        or a
        sbc hl,bc   ; subtract fudge factor,
        ld b,h      ;   returning true index
        ld c,l
        next

;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
    head JJ,1,'j',docode
        push bc     ; push old TOS
        ld l,(ix+4) ; get current loop index
        ld h,(ix+5)
        ld c,(ix+6) ; get fudge factor
        ld b,(ix+7)
        or a
        sbc hl,bc   ; subtract fudge factor,
        ld b,h      ;   returning true index
        ld c,l
        next

;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
    head UNLOOP,6,"unloop",docode
        inc ix
        inc ix
        inc ix
        inc ix
        next

; MULTIPLY AND DIVIDE ===========================

;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
    head UMSTAR,3,"um*",docode
        push bc
        exx
        pop bc      ; u2 in BC
        pop de      ; u1 in DE
        ld hl,0     ; result will be in HLDE
        ld a,17     ; loop counter
        or a        ; clear cy
umloop: rr h
        rr l
        rr d
        rr e
        jr nc,noadd
        add hl,bc
noadd:  dec a
        jr nz,umloop
        push de     ; lo result
        push hl     ; hi result
        exx
        pop bc      ; put TOS back in BC
        next

;C UM/MOD   ud u1 -- umod uquot   unsigned 32/16->16
    head UMSLASHMOD,6,"um/mod",docode
        push bc
        exx
        pop bc      ; BC = divisor
        pop hl      ; HLDE = dividend
        pop de
        ld a,16     ; loop counter
        sla e
        rl d        ; hi bit DE -> carry
udloop: adc hl,hl   ; rot left w/ carry
        jr nc,udiv3
        ; case 1: 17 bit, cy:HL = 1xxxx
        or a        ; we know we can subtract
        sbc hl,bc
        or a        ; clear cy to indicate sub ok
        jr udiv4
        ; case 2: 16 bit, cy:HL = 0xxxx
udiv3:  sbc hl,bc   ; try the subtract
        jr nc,udiv4 ; if no cy, subtract ok
        add hl,bc   ; else cancel the subtract
        scf         ;   and set cy to indicate
udiv4:  rl e        ; rotate result bit into DE,
        rl d        ; and next bit of DE into cy
        dec a
        jr nz,udloop
        ; now have complemented quotient in DE,
        ; and remainder in HL
        ld a,d
        cpl
        ld b,a
        ld a,e
        cpl
        ld c,a
        push hl     ; push remainder
        push bc
        exx
        pop bc      ; quotient remains in TOS
        next

; BLOCK AND STRING OPERATIONS ===================

;C FILL   c-addr u char --  fill memory with char
    head FILL,4,"fill",docode
        ld a,c          ; character in a
        exx             ; use alt. register set
        pop bc          ; count in bc
        pop de          ; address in de
        or a            ; clear carry flag
        ld hl,0ffffh
        adc hl,bc       ; test for count=0 or 1
        jr nc,filldone  ;   no cy: count=0, skip
        ld (de),a       ; fill first byte
        jr z,filldone   ;   zero, count=1, done
        dec bc          ; else adjust count,
        ld h,d          ;   let hl = start adrs,
        ld l,e
        inc de          ;   let de = start adrs+1
        ldir            ;   copy (hl)->(de)
filldone: exx           ; back to main reg set
        pop bc          ; pop new TOS
        next

;X CMOVE   c-addr1 c-addr2 u --  move from bottom
; as defined in the ANSI optional String word set
; On byte machines, CMOVE and CMOVE> are logical
; factors of MOVE.  They are easy to implement on
; CPUs which have a block-move instruction.
    head CMOVE,5,"cmove",docode
        push bc
        exx
        pop bc      ; count
        pop de      ; destination adrs
        pop hl      ; source adrs
        ld a,b      ; test for count=0
        or c
        jr z,cmovedone
        ldir        ; move from bottom to top
cmovedone: exx
        pop bc      ; pop new TOS
        next

;X CMOVE>  c-addr1 c-addr2 u --  move from top
; as defined in the ANSI optional String word set
    head CMOVEUP,6,"cmove>",docode
        push bc
        exx
        pop bc      ; count
        pop hl      ; destination adrs
        pop de      ; source adrs
        ld a,b      ; test for count=0
        or c
        jr z,umovedone
        add hl,bc   ; last byte in destination
        dec hl
        ex de,hl
        add hl,bc   ; last byte in source
        dec hl
        lddr        ; move from top to bottom
umovedone: exx
        pop bc      ; pop new TOS
        next

;Z SKIP   c-addr u c -- c-addr' u'
;Z                          skip matching chars
; Although SKIP, SCAN, and S= are perhaps not the
; ideal factors of WORD and FIND, they closely
; follow the string operations available on many
; CPUs, and so are easy to implement and fast.
    head SKIP,4,"skip",docode
        ld a,c      ; skip character
        exx
        pop bc      ; count
        pop hl      ; address
        ld e,a      ; test for count=0
        ld a,b
        or c
        jr z,skipdone
        ld a,e
skiploop: cpi
        jr nz,skipmis   ; char mismatch: exit
        jp pe,skiploop  ; count not exhausted
        jr skipdone     ; count 0, no mismatch
skipmis: inc bc         ; mismatch!  undo last to
        dec hl          ;  point at mismatch char
skipdone: push hl   ; updated address
        push bc     ; updated count
        exx
        pop bc      ; TOS in bc
        next

;Z SCAN    c-addr u c -- c-addr' u'
;Z                      find matching char
    head SCAN,4,"scan",docode
        ld a,c      ; scan character
        exx
        pop bc      ; count
        pop hl      ; address
        ld e,a      ; test for count=0
        ld a,b
        or c
        jr z,scandone
        ld a,e
        cpir        ; scan 'til match or count=0
        jr nz,scandone  ; no match, BC & HL ok
        inc bc          ; match!  undo last to
        dec hl          ;   point at match char
scandone: push hl   ; updated address
        push bc     ; updated count
        exx
        pop bc      ; TOS in bc
        next

;Z S=    c-addr1 c-addr2 u -- n   string compare
;Z             n<0: s1<s2, n=0: s1=s2, n>0: s1>s2
    head SEQUAL,2,"s=",docode
        push bc
        exx
        pop bc      ; count
        pop hl      ; addr2
        pop de      ; addr1
        ld a,b      ; test for count=0
        or c
        jr z,smatch     ; by definition, match!
sloop:  ld a,(de)
        inc de
        cpi
        jr nz,sdiff     ; char mismatch: exit
        jp pe,sloop     ; count not exhausted
smatch: ; count exhausted & no mismatch found
        exx
        ld bc,0         ; bc=0000  (s1=s2)
        jr snext
sdiff:  ; mismatch!  undo last 'cpi' increment
        dec hl          ; point at mismatch char
        cp (hl)         ; set cy if char1 < char2
        sbc a,a         ; propagate cy thru A
        exx
        ld b,a          ; bc=FFFF if cy (s1<s2)
        or 1            ; bc=0001 if ncy (s1>s2)
        ld c,a
snext:  next


;
;  Added (NULL) word as a no-operation.  Used as a target for
;  AUTOSTART (see COLD in the high-level definitions).
;
		head	PNULL,6,"(null)",docode
		next


;
;  Added CBITREV word to reverse order of bits in a byte, since
;  the #@$% Z180 is backwards from Motorola on synchronous I/O!
;
		head	CBITREV,7,"cbitrev",docode
		srl		c							; convert c, save in a
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		srl		c
		rl		a
		ld		c,a							; put converted byte in TOS
		next

;
;  ======================================================
;
;  This marks the end of the assembly-language primitives.
;  Use .INCLUDE statements to add in any other modules.
;

        .INCLUDE "CAMEL80D.S"   ; CPU Dependencies
        .INCLUDE "CAMEL80H.S"   ; High Level words
;;      .INCLUDE "CAMELTST.S"   ; Primitives Test
		.INCLUDE "CAMEL80O.S"	; optional words (NOT ANSI!)

lastword EQU link       ; nfa of last word in dict.

enddict EQU		cma1beg       ; user's code starts here
        END     reset
