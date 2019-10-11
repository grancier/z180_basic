; **********************************************************************
; **  Config: Standard features                 by Stephen C Cousins  **
; **********************************************************************

; **********************************************************************
; Hardware identifier constants 
;
; These provide the ID for a specific hardware design. They are used in
; the BUILD.ASM file statement:  kConfHardw:  .SET HW_xxxx
; If the configuration is to be used with more than one hardware design, 
; use the value HW_UNKNOWN.
;
; Symbol     Value              Description
; ======     =====              ===========
HW_UNKNOWN: EQU 0              ;Unknown or Custom hardware
HW_WSHOP:   EQU 1              ;SC Workshop / simulated 
HW_SCDEV:   EQU 2              ;SC Development Kit 01
HW_RC2014:  EQU 3              ;RC2014 Generic 
HW_SBC1:    EQU 5              ;LiNC80 SBC1 with Z50Bus
HW_TomSBC:  EQU 6              ;Tom Szolyga's Z80 SBC rev C
HW_Z280RC:  EQU 7              ;Bill Shen's Z280RC
HW_Z80SBC:  EQU 9              ;Bill Shen's Z80SBC RC
HW_SC101:   EQU 101            ;SC101 Prototype motherboard
HW_SC108:   EQU 108            ;SC126 Z80 processor for RC2014
HW_SC111:   EQU 111            ;SC111 Z180 processor for RC2014+
HW_SC114:   EQU 114            ;SC114 Z80 SBC / motherboard for
HW_SC118:   EQU 118            ;SC118 Z80 processor for Z50Bus
HW_SC121:   EQU 121            ;SC121 Z80 processor for Z50sc
HW_SC126:   EQU 126            ;SC126 Z180 SBC / motherboard


; **********************************************************************
; Default configuration details

; Configuration identifiers
kConfMajor: EQU '0'            ;Config: Letter = official, number = user
kConfMinor: EQU '0'            ;Config: 1 to 9 = official, 0 = user
;#DEFINE    CNAME "Simulated"   ;Configuration name (max 11 characters)

; Console devices
kConDef:    EQU 1              ;Default console device (1 to 6)
kBaud1Def:  EQU 0x11           ;Console device 1 default baud rate 
kBaud2Def:  EQU 0x11           ;Console device 2 default baud rate 

; Simple I/O ports
kPrtIn:     EQU 0x00           ;General input port
kPrtOut:    EQU 0x00           ;General output port

; ROM filing system
kROMBanks:  EQU 1              ;Number of software selectable ROM banks
kROMTop:    EQU 0x7F           ;Top of banked ROM (hi byte only)

; Processor
;#DEFINE    PROCESSOR Z180      ;Processor type "Z80", "Z180"
kCPUClock:  EQU 18432000       ;CPU clock speed in Hz
kZ180Base:  EQU 0xC0           ;Z180 internal register base address


; Memory map (code)
kCode:      EQU 0x0000         ;Typically 0x0000 or 0xE000

; Memory map (data in RAM)
kData:      EQU 0xFC00         ;Typically 0xFC00 (to 0xFFFF)


; **********************************************************************
; **  Alpha module                              by Stephen C Cousins  **
; **********************************************************************

; This module provides the following:
;   Defines the memory map (except kCode and kData)
;   Reset code / Cold start command line interpreter
;   Warm start command line interpreter
;
; Public functions provided:
;   ColdStart             Cold start monitor
;   WarmStart             Warm start monitor
;   InitJumps             Initialise jump table with vector list
;   ClaimJump             Claim jump table entry
;   ReadJump              Read jump table entry
;   MemAPI                Call API with parameters in RAM
;   SelConDev             Select console in/out device
;   SelConDevI            Select console input device
;   SelConDevO            Select console output device
;   DevInput              Input from specified console device
;   DevOutput             Output to specified console device
;   GetConDev             Get current console device numbers
;   GetMemTop             Get top of free memory
;   SetMemTop             Set top of free memory
;   GetVersion            Get version and configuration details
;   OutputMessage         Output specified embedded message
;   SetBaud               Set baud rate for console devices
;   SysReset              System reset


; **********************************************************************
; **  Constants                                                       **
; **********************************************************************

; Operating system version number
;kSysMajor: EQU 1              ;Bios version: revision
;kSysMinor: EQU 0              ;Bios version: revision
;kSysRevis: EQU 1              ;Bios version: revision


; Memory map (ROM or RAM)
Reset:      EQU 0x0000         ;Z80 reset location


; Page zero use 
; SCMonitor: page zero can be in RAM or ROM
; CP/M: page zero must be in RAM
; <Address>   <Z80 function>   <Monitor>   <CP/M 2>
; 0000-0002   RST 00 / Reset   Cold start  Warm boot
; 0003-0004                    Warm start  IOBYTE / drive & user
; 0005-0007                    As CP/M     FDOS entry point
; 0008-000B   RST 08           Char out    Not used
; 000C-000F                    CstartOld   Not used
; 0010-0013   RST 10           Char in     Not used
; 0014-0017                    WstartOld   Not used
; 0018-001F   RST 18           In status   Not used
; 0020-0027   RST 20           Not used    Not used
; 0028-002F   RST 28           Breakpoint  Debugging
; 0030-0037   RST 30           API entry   Not used
; 0038-003F   RST 38 / INT     Interrupt   Interrupt mode 1 handler
; 0040-005B                    Options     Not used
; 005C-007F                    As CP/M     Default FCB
; 0066-0068   NMI              or Non-maskable interrupt (NMI) handler
; 0080-00FF                    As CP/M     Default DMA

; Memory map (ROM)
;kCode:     EQU 0x0000         ;Typically 0x0000 or 0xE000

; Memory map (RAM)
;kData:     EQU 0xFC00         ;Typically 0xFC00 (to 0xFFFF)
; 0xFC00 to 0xFCBF  User stack
; 0xFCC0 to 0xFCFF  System stack
; 0xFD00 to 0xFD7F  Line input buffer
; 0xFD80 to 0xFDFF  String buffer
; 0xFE00 to 0xFE5F  Jump table
; 0xFE60 to 0xFEFF  Workspace (currently using to about 0xFEAF)
; 0xFF00 to 0xFFFF  Pass info between apps and memory banks:
; 0xFF00 to 0xFF7F    Transient data area
; 0xFF80 to 0xFFEF    Transient code area
; 0xFFD0 to 0xFFDF    ROMFS file info block 2
; 0xFFE0 to 0xFFEF    ROMFS file info block 1
; 0xFFF0 to 0xFFFF    System variables
kSPUsr:     EQU kData+0x00C0   ;Top of stack for user program
kSPSys:     EQU kData+0x0100   ;Top of stack for system
kInputBuff: EQU kData+0x0100   ;Line input buffer start    (to +0x017F)
kInputSize: EQU 128            ;Size of input buffer
kStrBuffer: EQU kData+0x0180   ;String buffer              (to +0x01FF)
kStrSize:   EQU 128            ;Size of string buffer
kJumpTab:   EQU kData+0x0200   ;Redirection jump table     (to +0x025F)
;kWorkspace:                    EQU kData+0x0260;Space for data & variables (to +0x02FF)
; Pass information between apps and memory banks 0xFF00 to 0xFFFF
kPassData   EQU 0xFF00         ;0xFF00 to 0xFF7F Transient data area
kPassCode:  EQU 0xFF80         ;0xFF80 to 0xFFEF Transient code area
kPassInfo:  EQU 0xFFF0         ;0xFFF0 to 0xFFFF Variable passing area
kPassCtrl:  EQU kPassInfo+0x00 ;Pass control / paging information
kPassAF:    EQU kPassInfo+0x02 ;Pass AF to/from API
kPassBC:    EQU kPassInfo+0x04 ;Pass BC to/from API
kPassDE:    EQU kPassInfo+0x06 ;Pass DE to/from API
kPassHL:    EQU kPassInfo+0x08 ;Pass HL --/from API
kPassDevI:  EQU kPassInfo+0x0A ;Pass current input device
kPassDevO:  EQU kPassInfo+0x0B ;Pass current output device

; Fixed address to allow external code to use it
kTransCode: EQU 0xFF80         ;Transient code area

; Fixed address to allow external code to use this data
iConfigCpy: EQU 0xFFF0         ;Configure register shadow copy
iConfigPre: EQU 0xFFF1         ;Config register previous copy

; Define memory usage
kSysData    EQU kData + 0x0260
kMonData    EQU kData + 0x0280
kBiosData   EQU kData + 0x02C0


; **********************************************************************
; **  Initialise memory sections                                      **
; **********************************************************************

; Initialise data section
SECTION DATA

            ORG  kSysData      ;Establish workspace/data area

SECTION CODE1

            ORG kJumpTab

JpNMI:      JP   0              ;Fn 0x00: Jump to non-maskable interrupt
JpRST08:    JP   0              ;Fn 0x01: Jump to restart 08 handler
JpRST10:    JP   0              ;Fn 0x02: Jump to restart 10 handler
JpRST18:    JP   0              ;Fn 0x03: Jump to restart 18 handler
JpRST20:    JP   0              ;Fn 0x04: Jump to restart 20 handler
JpBP:       JP   0              ;Fn 0x05: Jump to restart 28 breakpoint
JpAPI:      JP   0              ;Fn 0x06: Jump to restart 30 API handler
JpINT:      JP   0              ;Fn 0x07: Jump to restart 38 interrupt handler
JpConIn:    JP   0              ;Fn 0x08: Jump to console input character
JpConOut:   JP   0              ;Fn 0x09: Jump to console output character
            JP   0              ;Fn 0x0A: Jump to console get input status
            JP   0              ;Fn 0x0B: Jump to console get output status
JpIdle:     JP   0              ;Fn 0x0C: Jump to idle handler
JpTimer1:   JP   0              ;Fn 0x0D: Jump to timer 1 handler
JpTimer2:   JP   0              ;Fn 0x0E: Jump to timer 2 handler
JpTimer3:   JP   0              ;Fn 0x0F: Jump to timer 3 handler
            ;Fn 0x10: Start of console device jumps
            JP   0              ;Jump to device 1 input character
            JP   0              ;Jump to device 1 output character
            JP   0              ;Jump to device 2 input character
            JP   0              ;Jump to device 2 output character
            JP   0              ;Jump to device 3 input character
            JP   0              ;Jump to device 3 output character
            JP   0              ;Jump to device 4 input character
            JP   0              ;Jump to device 4 output character
            JP   0              ;Jump to device 5 input character
            JP   0              ;Jump to device 5 output character
            JP   0              ;Jump to device 6 input character
            JP   0              ;Jump to device 6 output character

            DEFS   12            ;Workspace starts at kJumpTab + 0x60
;           ORG  kWorkspace

; Initialise code section
SECTION CODE
            ORG  kCode


; **********************************************************************
; **  Page zero default vectors etc, copied to RAM if appropriate     **
; **********************************************************************

; Reset / power up here
Page0Strt:
ColdStart:  JP   HW_Test        ;0x0000  or CP/M 2 Warm boot
WarmStart:  JR   WStrt          ;0x0003  or CP/M 2 IOBYTE/drive & user
            JP   FDOS           ;0x0005  or CP/M 2 FDOS entry point
            JP   JpRST08        ;0x0008  RST 08 Console character out
            DEFB  0              ;0x000B  
_CStrt:     JP   ColdStrt       ;0x000C  Cold start (eg. after selftest)
            DEFB  0              ;0x000F  
            JP   JpRST10        ;0x0010  RST 10 Console character in
            DEFB  0              ;0x0013 
WStrt:      JP   WarmStrt       ;0x0014  Warm start (unofficial entry)
            DEFB  0              ;0x0017
            JP   JpRST18        ;0x0018  RST 18 Console input status
            DEFB  0              ;0x001B
            DEFB  "SCM",0        ;0x001C  SCM identifier string
            JP   JpRST20        ;0x0020  RST 20 Not used
            DEFB  0,0,0,0,0      ;0x0023
            JP   JpBP           ;0x0028  RST 28 Our debugging breakpoint
            DEFB  0,0,0,0,0      ;0x002B         and CP/M debugging tools
            JP   JpAPI          ;0x0030  RST 30 API entry point
            DEFB  0              ;0x0033         parameters in registers
            JP   MemAPI         ;0x0034  API call with
            DEFB  0              ;0x0037         parameters in memory 
            JP   JpINT          ;0x0038  RST 38 Interrupt mode 1 handler
            DEFB  0,0,0,0,0      ;0x003B
            DEFB  kConDef        ;0x0040  Default console device (1 to 6)
            DEFB  kBaud1Def      ;0x0041  Default device 1 baud rate
            DEFB  kBaud2Def      ;0x0042  Default device 2 baud rate
            DEFB  0              ;0x0043  Default device 3 baud rate
            DEFB  0              ;0x0044  Default device 4 baud rate
            DEFB  kPrtIn         ;0x0045  Default status input port
            DEFB  kPrtOut        ;0x0046  Default status output port
            DEFB  0              ;0x0047  Not used
            DEFW  0,0            ;0x0048  Not used
            DEFB  0              ;0x004C  Not used
            DEFB  kROMTop        ;0x004D  Top of RomFS (hi byte)
            DEFB  CodeBegin\256  ;0x004E  Start of SCM code (hi byte)
            DEFB  CodeEnd\256    ;0x004F  End of SCM code (hi byte)
            DEFW  0,0,0,0        ;0x0050  Not used
            DEFW  0,0            ;0x0058  Not used
            DEFW  0,0            ;0x005C  CP/M 2 Default FCB
            DEFW  0,0,0          ;0x0060         from 0x005C to 0x007F
            JP   JpNMI          ;0x0066  Non-maskable interrupt handler
Page0End:


; **********************************************************************
; **  Jump table defaults to be copied to RAM                         **
; **********************************************************************

JumpStrt:   JP   TrapNMI        ;Fn 0x00: non-maskable interrupt
            JP   OutputChar     ;Fn 0x01: restart 08 output character
            JP   InputChar      ;Fn 0x02: restart 10 input character
            JP   InputStatus    ;Fn 0x03: restart 18 get input status
            JP   TrapCALL       ;Fn 0x04: restart 20 handler
            JP   0              ;Fn 0x05: restart 28 breakpoint handler
            JP   APIHandler     ;Fn 0x06: restart 30 API handler
            JP   TrapINT        ;Fn 0x07: restart 38 interrupt handler
            JP   TrapCALL       ;Fn 0x08: console input character
            JP   TrapCALL       ;Fn 0x09: console output character
            JP   TrapCALL       ;Fn 0x0A: console get input status
            JP   TrapCALL       ;Fn 0x0B: console get output status
            JP   TrapCALL       ;Fn 0x0C: Jump to idle handler
            JP   TrapCALL       ;Fn 0x0D: Jump to timer 1 handler
            JP   TrapCALL       ;Fn 0x0E: Jump to timer 2 handler
            JP   TrapCALL       ;Fn 0x0F: Jump to timer 3 handler
            JP   DevNoIn        ;Fn 0x10: Device 1 input character
            JP   DevNoOut       ;Fn 0x11: Device 1 output character
            JP   DevNoIn        ;Fn 0x10: Device 2 input character
            JP   DevNoOut       ;Fn 0x11: Device 2 output character
            JP   DevNoIn        ;Fn 0x10: Device 3 input character
            JP   DevNoOut       ;Fn 0x11: Device 3 output character
            JP   DevNoIn        ;Fn 0x10: Device 4 input character
            JP   DevNoOut       ;Fn 0x11: Device 4 output character
            JP   DevNoIn        ;Fn 0x10: Device 5 input character
            JP   DevNoOut       ;Fn 0x11: Device 5 output character
            JP   DevNoIn        ;Fn 0x10: Device 6 input character
            JP   DevNoOut       ;Fn 0x11: Device 6 output character
JumpEnd:


; **********************************************************************
; **  Reset code                                                      **
; **********************************************************************

; Cold start Command Line Interpreter
ColdStrt:   DI                  ;Disable interrupts
            LD   SP,kSPSys      ;Initialise system stack pointer
; Copy vectors etc to page zero in case code is elsewhere
            LD   DE,0x0000      ;Copy vectors etc to here
            LD   HL,Page0Strt   ;Copy vectors etc from here
            LD   BC,Page0End-Page0Strt  ;Number of bytes to copy
            LDIR                ;Copy bytes
; Initialise jump table, other than console devices
            LD   DE,kJumpTab    ;Copy jump table to here
            LD   HL,JumpStrt    ;Copy jump table from here
            LD   BC,JumpEnd-JumpStrt  ;Number of bytes to copy
            LDIR                ;Copy bytes
; Initialise top of memory value
            LD   HL,kData-1     ;Top of free memory
            LD   (iMemTop),HL   ;Set top of free memory
; Initialise ports module for default I/O ports
; This will turn off all outputs at the default output port (LEDs)
            LD   A,(kaPortOut)  ;Default output port address
            CALL PrtOInit       ;Initialise output port
            LD   A,(kaPortIn)   ;Default input port address
            CALL PrtIInit       ;Initialise input port
; Initialise hardware and set up required jump table entries
; This may indicate an error at the default output port (LEDs)
            CALL HW_Init        ;Hardware_Initialise
; Initialise default console device to first physical device
            LD   A,(kaConDev)   ;Default device number
            CALL SelConDev      ;Select console device
; Initialise rest of system
            CALL ConInitialise  ;Initialise the console

; Output sign-on message
            CALL OutputNewLine  ;Output new line
            CALL OutputNewLine  ;Output new line
            LD   A,kMsgProdID   ;="Small Computer Monitor"
            CALL OutputMessage  ;Output message
            LD   A,'-'          ;="-"
            CALL OutputChar     ;Output character
            