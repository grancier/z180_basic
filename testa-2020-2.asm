
;==============================================================================
;
; DEFINES SECTION
;

DEFC    CPU_CLOCK       =   6144000

DEFC    ROMSTART        =   $0000   ; Bottom of Common 0 FLASH
DEFC    ROMSTOP         =   $7FFF   ; Top of Common 0 FLASH

DEFC    RAMSTART_CA0    =   $8000   ; Bottom of Common 0 RAM
DEFC    RAMSTOP_CA0     =   $BFFF   ; Top of Common 0 RAM

DEFC    RAMSTART_BANK   =   $C000   ; Bottom of Banked RAM
DEFC    RAMSTOP_BANK    =   $DFFF   ; Top of Banked RAM

DEFC    RAMSTART_CA1    =   $E000   ; Bottom of Common 1 RAM
DEFC    RAMSTOP_CA1     =   $FFFF   ; Top of Common 1 RAM

DEFC    ASCI0_RX_BUFSIZE    =   $100    ; FIXED Rx buffer, 256 Bytes, no range checking
DEFC    ASCI0_TX_BUFSIZE    =   $100    ; FIXED Tx buffer, 256 Bytes, no range checking

DEFC    ASCI1_RX_BUFSIZE    =   $100    ; FIXED Rx buffer, 256 Bytes, no range checking
DEFC    ASCI1_TX_BUFSIZE    =   $100    ; FIXED Tx buffer, 256 Bytes, no range checking

DEFC    APU_CMD_BUFSIZE     =   $100    ; FIXED CMD buffer size, 256 CMDs
DEFC    APU_PTR_BUFSIZE     =   $100    ; FIXED DATA POINTER buffer size, 128 POINTERs

DEFC    RAMSTART        =   RAMSTART_CA0
DEFC    RAMSTOP         =   RAMSTOP_CA1

DEFC    STACKTOP        =   $BFFD   ; start of a global stack (any pushes pre-decrement)

;   RAM Vector Address for Z80 RST Table, and for Z180 Vector Table
DEFC    Z80_VECTOR_BASE =   RAMSTART_CA0

; Top of BASIC line input buffer (CURPOS WRKSPC+0ABH)
; so it is "free ram" when BASIC resets
; set BASIC Work space WRKSPC $8000, in RAM

DEFC    WRKSPC          =   RAMSTART_CA1    ; set BASIC Work space WRKSPC

DEFC    TEMPSTACK       =   WRKSPC+$AB      ; Top of BASIC line input buffer
                                            ; (CURPOS = WRKSPC+0ABH)
                                            ; so it is "free ram" when BASIC resets

;==============================================================================
;
; Interrupt vectors (offsets) for Z80 RST, INT0, and NMI interrupts
;

;   Squeezed between INT0 0x0038 and NMI 0x0066
DEFC    Z80_VECTOR_PROTO    =   $003C
DEFC    Z80_VECTOR_SIZE     =   $24

;   Prototype Interrupt Service Routines - complete in main program
;
;DEFC       Z180_TRAP   =       Z180_INIT   Reboot
;DEFC       RST_08      =       TX0         TX a character over ASCI0
;DEFC       RST_10      =       RX0         RX a character over ASCI0, block no bytes available
;DEFC       RST_18      =       RX0_CHK     Check ASCI0 status, return # bytes available
;DEFC       RST_20      =       NULL_INT
;DEFC       RST_28      =       NULL_INT
;DEFC       RST_30      =       NULL_INT
;DEFC       INT_INT0    =       NULL_INT
;DEFC       INT_NMI     =       NULL_NMI

;   Z80 Interrupt Service Routine Addresses - rewrite as needed
DEFC    Z180_TRAP_ADDR      =   Z80_VECTOR_BASE+$01
DEFC    RST_08_ADDR         =   Z80_VECTOR_BASE+$05
DEFC    RST_10_ADDR         =   Z80_VECTOR_BASE+$09
DEFC    RST_18_ADDR         =   Z80_VECTOR_BASE+$0D
DEFC    RST_20_ADDR         =   Z80_VECTOR_BASE+$11
DEFC    RST_28_ADDR         =   Z80_VECTOR_BASE+$15
DEFC    RST_30_ADDR         =   Z80_VECTOR_BASE+$19
DEFC    INT_INT0_ADDR       =   Z80_VECTOR_BASE+$1D
DEFC    INT_NMI_ADDR        =   Z80_VECTOR_BASE+$21

;==============================================================================
;
; Interrupt vectors (offsets) for Z180/HD64180 external and internal interrupts
;

DEFC    Z180_VECTOR_IL      =   $40 ; Vector Base address (IL)
                                    ; [001x xxxx] for Vectors at $nn40 - $nn5F

;   Locate the TRAP management just after NMI

DEFC    Z180_VECTOR_TRAP    =   $0070

;   Start Z180 Vectors immediately after the Z80 Vector Table.   
                                 
DEFC    Z180_VECTOR_BASE    =   Z80_VECTOR_BASE-(Z80_VECTOR_BASE%$100)+Z180_VECTOR_IL

;   Locate the prototypes just after TRAP code

DEFC    Z180_VECTOR_PROTO   =   $00D0
DEFC    Z180_VECTOR_SIZE    =   $12

;   Prototype Interrupt Service Routines - provide these in your main program
;
;   INT_INT1    =       NULL_RET        ; external /INT1
;   INT_INT2    =       NULL_RET        ; external /INT2
;   INT_PRT0    =       NULL_RET        ; PRT channel 0
;   INT_PRT1    =       NULL_RET        ; PRT channel 1
;   INT_DMA0    =       NULL_RET        ; DMA channel 0
;   INT_DMA1    =       NULL_RET        ; DMA Channel 1
;   INT_CSIO    =       NULL_RET        ; Clocked serial I/O
;   INT_ASCI0   =       ASCI0_INTERRUPT ; Async channel 0
;   INT_ASCI1   =       NULL_RET        ; Async channel 1

;   Z180 Interrupt Service Routine Addresses - rewrite as needed

DEFC    INT_INT1_ADDR       =   Z180_VECTOR_BASE+$00
DEFC    INT_INT2_ADDR       =   Z180_VECTOR_BASE+$02
DEFC    INT_PRT0_ADDR       =   Z180_VECTOR_BASE+$04
DEFC    INT_PRT1_ADDR       =   Z180_VECTOR_BASE+$06
DEFC    INT_DMA0_ADDR       =   Z180_VECTOR_BASE+$08
DEFC    INT_DMA1_ADDR       =   Z180_VECTOR_BASE+$0A
DEFC    INT_CSIO_ADDR       =   Z180_VECTOR_BASE+$0C
DEFC    INT_ASCI0_ADDR      =   Z180_VECTOR_BASE+$0E
DEFC    INT_ASCI1_ADDR      =   Z180_VECTOR_BASE+$10

;==============================================================================
;
; Z180 Register Mnemonics
;

DEFC    CPU_TIMER_SCALE =       20                  ; PRT Scale Factor (Fixed)

DEFC    Z180_IO_BASE    =       $00                 ; Internal I/O Base Address (ICR)

DEFC    CNTLA0          =       Z180_IO_BASE+$00    ; ASCI Control Reg A Ch 0
DEFC    CNTLA1          =       Z180_IO_BASE+$01    ; ASCI Control Reg A Ch 1
DEFC    CNTLB0          =       Z180_IO_BASE+$02    ; ASCI Control Reg B Ch 0
DEFC    CNTLB1          =       Z180_IO_BASE+$03    ; ASCI Control Reg B Ch 1
DEFC    STAT0           =       Z180_IO_BASE+$04    ; ASCI Status  Reg   Ch 0
DEFC    STAT1           =       Z180_IO_BASE+$05    ; ASCI Status  Reg   Ch 1
DEFC    TDR0            =       Z180_IO_BASE+$06    ; ASCI Tx Data Reg   Ch 0
DEFC    TDR1            =       Z180_IO_BASE+$07    ; ASCI Tx Data Reg   Ch 1
DEFC    RDR0            =       Z180_IO_BASE+$08    ; ASCI Rx Data Reg   Ch 0
DEFC    RDR1            =       Z180_IO_BASE+$09    ; ASCI Rx Data Reg   Ch 1

DEFC    ASEXT0          =       Z180_IO_BASE+$12    ; ASCI Extension Control Reg Ch 0 (Z8S180 & higher Only)
DEFC    ASEXT1          =       Z180_IO_BASE+$13    ; ASCI Extension Control Reg Ch 1 (Z8S180 & higher Only)

DEFC    ASTC0L          =       Z180_IO_BASE+$1A    ; ASCI Time Constant Ch 0 Low (Z8S180 & higher Only)
DEFC    ASTC0H          =       Z180_IO_BASE+$1B    ; ASCI Time Constant Ch 0 High (Z8S180 & higher Only)
DEFC    ASTC1L          =       Z180_IO_BASE+$1C    ; ASCI Time Constant Ch 1 Low (Z8S180 & higher Only)
DEFC    ASTC1H          =       Z180_IO_BASE+$1D    ; ASCI Time Constant Ch 1 High (Z8S180 & higher Only)

DEFC    CNTR            =       Z180_IO_BASE+$0A    ; CSI/O Control Reg
DEFC    TRDR            =       Z180_IO_BASE+$0B    ; CSI/O Tx/Rx Data Reg

DEFC    TMDR0L          =       Z180_IO_BASE+$0C    ; Timer Data Reg Ch 0 Low
DEFC    TMDR0H          =       Z180_IO_BASE+$0D    ; Timer Data Reg Ch 0 High
DEFC    RLDR0L          =       Z180_IO_BASE+$0E    ; Timer Reload Reg Ch 0 Low
DEFC    RLDR0H          =       Z180_IO_BASE+$0F    ; Timer Reload Reg Ch 0 High
DEFC    TCR             =       Z180_IO_BASE+$10    ; Timer Control Reg

DEFC    TMDR1L          =       Z180_IO_BASE+$14    ; Timer Data Reg Ch 1 Low
DEFC    TMDR1H          =       Z180_IO_BASE+$15    ; Timer Data Reg Ch 1 High
DEFC    RLDR1L          =       Z180_IO_BASE+$16    ; Timer Reload Reg Ch 1 Low
DEFC    RLDR1H          =       Z180_IO_BASE+$17    ; Timer Reload Reg Ch 1 High

DEFC    FRC             =       Z180_IO_BASE+$18    ; Free-Running Counter

DEFC    CMR             =       Z180_IO_BASE+$1E    ; CPU Clock Multiplier Reg (Z8S180 & higher Only)
DEFC    CCR             =       Z180_IO_BASE+$1F    ; CPU Control Reg (Z8S180 & higher Only)

DEFC    SAR0L           =       Z180_IO_BASE+$20    ; DMA Source Addr Reg Ch0-Low
DEFC    SAR0H           =       Z180_IO_BASE+$21    ; DMA Source Addr Reg Ch0-High
DEFC    SAR0B           =       Z180_IO_BASE+$22    ; DMA Source Addr Reg Ch0-Bank
DEFC    DAR0L           =       Z180_IO_BASE+$23    ; DMA Dest Addr Reg Ch0-Low
DEFC    DAR0H           =       Z180_IO_BASE+$24    ; DMA Dest Addr Reg Ch0-High
DEFC    DAR0B           =       Z180_IO_BASE+$25    ; DMA Dest ADDR REG CH0-Bank
DEFC    BCR0L           =       Z180_IO_BASE+$26    ; DMA Byte Count Reg Ch0-Low
DEFC    BCR0H           =       Z180_IO_BASE+$27    ; DMA Byte Count Reg Ch0-High
DEFC    MAR1L           =       Z180_IO_BASE+$28    ; DMA Memory Addr Reg Ch1-Low
DEFC    MAR1H           =       Z180_IO_BASE+$29    ; DMA Memory Addr Reg Ch1-High
DEFC    MAR1B           =       Z180_IO_BASE+$2A    ; DMA Memory Addr Reg Ch1-Bank
DEFC    IAR1L           =       Z180_IO_BASE+$2B    ; DMA I/O Addr Reg Ch1-Low
DEFC    IAR1H           =       Z180_IO_BASE+$2C    ; DMA I/O Addr Reg Ch2-High
DEFC    BCR1L           =       Z180_IO_BASE+$2E    ; DMA Byte Count Reg Ch1-Low
DEFC    BCR1H           =       Z180_IO_BASE+$2F    ; DMA Byte Count Reg Ch1-High
DEFC    DSTAT           =       Z180_IO_BASE+$30    ; DMA Status Reg
DEFC    DMODE           =       Z180_IO_BASE+$31    ; DMA Mode Reg
DEFC    DCNTL           =       Z180_IO_BASE+$32    ; DMA/Wait Control Reg

DEFC    IL              =       Z180_IO_BASE+$33    ; INT Vector Low Reg
DEFC    ITC             =       Z180_IO_BASE+$34    ; INT/TRAP Control Reg

DEFC    RCR             =       Z180_IO_BASE+$36    ; Refresh Control Reg

DEFC    CBR             =       Z180_IO_BASE+$38    ; MMU Common Base Reg
DEFC    BBR             =       Z180_IO_BASE+$39    ; MMU Bank Base Reg
DEFC    CBAR            =       Z180_IO_BASE+$3A    ; MMU Common/Bank Area Reg
    
DEFC    OMCR            =       Z180_IO_BASE+$3E    ; Operation Mode Control Reg
DEFC    ICR             =       Z180_IO_BASE+$3F    ; I/O Control Reg

;==============================================================================
;
; Some bit definitions used with the Z-180 on-chip peripherals:
;

;   ASCI Control Reg A (CNTLAn)

DEFC    ASCI_MPE        =       $80     ; Multi Processor Enable
DEFC    ASCI_RE         =       $40     ; Receive Enable
DEFC    ASCI_TE         =       $20     ; Transmit Enable
DEFC    ASCI_RTS0       =       $10     ; _RTS Request To Send
DEFC    ASCI_EFR        =       $08     ; Error Flag Reset

DEFC    ASCI_8P2        =       $07     ; 8 Bits    Parity 2 Stop Bits
DEFC    ASCI_8P1        =       $06     ; 8 Bits    Parity 1 Stop Bit
DEFC    ASCI_8N2        =       $05     ; 8 Bits No Parity 2 Stop Bits
DEFC    ASCI_8N1        =       $04     ; 8 Bits No Parity 1 Stop Bit
DEFC    ASCI_7P2        =       $03     ; 7 Bits    Parity 2 Stop Bits
DEFC    ASCI_7P1        =       $02     ; 7 Bits    Parity 1 Stop Bit
DEFC    ASCI_7N2        =       $01     ; 7 Bits No Parity 2 Stop Bits
DEFC    ASCI_7N1        =       $00     ; 7 Bits No Parity 1 Stop Bit

;   ASCI Control Reg B (CNTLBn)
                                        ; BAUD Rate = PHI / PS / SS / DR

DEFC    ASCI_MPBT       =       $80     ; Multi Processor Bit Transmit
DEFC    ASCI_MP         =       $40     ; Multi Processor
DEFC    ASCI_PS         =       $20     ; Prescale PHI by 10 (PS 0) or 30 (PS 1)
DEFC    ASCI_PEO        =       $10     ; Parity Even or Odd
DEFC    ASCI_DR         =       $08     ; Divide SS by 16 (DR 0) or 64 (DR 1)

DEFC    ASCI_SS_EXT     =       $07     ; External Clock Source <= PHI / 40
DEFC    ASCI_SS_DIV_64  =       $06     ; Divide PS by 64
DEFC    ASCI_SS_DIV_32  =       $05     ; Divide PS by 32
DEFC    ASCI_SS_DIV_16  =       $04     ; Divide PS by 16
DEFC    ASCI_SS_DIV_8   =       $03     ; Divide PS by  8
DEFC    ASCI_SS_DIV_4   =       $02     ; Divide PS by  4
DEFC    ASCI_SS_DIV_2   =       $01     ; Divide PS by  2
DEFC    ASCI_SS_DIV_1   =       $00     ; Divide PS by  1

;   ASCI Status Reg (STATn)

DEFC    ASCI_RDRF       =       $80     ; Receive Data Register Full
DEFC    ASCI_OVRN       =       $40     ; Overrun (Received Byte)
DEFC    ASCI_PE         =       $20     ; Parity Error (Received Byte)
DEFC    ASCI_FE         =       $10     ; Framing Error (Received Byte)
DEFC    ASCI_RIE        =       $08     ; Receive Interrupt Enabled
DEFC    ASCI_DCD0       =       $04     ; _DCD0 Data Carrier Detect USART0
DEFC    ASCI_CTS1       =       $04     ; _CTS1 Clear To Send USART1
DEFC    ASCI_TDRE       =       $02     ; Transmit Data Register Empty
DEFC    ASCI_TIE        =       $01     ; Transmit Interrupt Enabled

;   Programmable Reload Timer (TCR)

DEFC    TCR_TIF1       =        $80
DEFC    TCR_TIF0       =        $40
DEFC    TCR_TIE1       =        $20
DEFC    TCR_TIE0       =        $10
DEFC    TCR_TOC1       =        $08
DEFC    TCR_TOC0       =        $04
DEFC    TCR_TDE1       =        $02
DEFC    TCR_TDE0       =        $01

;   CPU Clock Multiplier Reg (CMR) (Z8S180 & higher Only)

DEFC    CMR_X2          =       $80     ; CPU x2 XTAL Multiplier Mode
DEFC    CMR_LN_XTAL     =       $40     ; Low Noise Crystal 

;   CPU Control Reg (CCR) (Z8S180 & higher Only)

DEFC    CCR_XTAL_X2     =       $80     ; PHI = XTAL Mode
DEFC    CCR_STANDBY     =       $40     ; STANDBY after SLEEP
DEFC    CCR_BREXT       =       $20     ; Exit STANDBY on BUSREQ
DEFC    CCR_LNPHI       =       $10     ; Low Noise PHI (30% Drive)
DEFC    CCR_IDLE        =       $08     ; IDLE after SLEEP
DEFC    CCR_LNIO        =       $04     ; Low Noise I/O Signals (30% Drive)
DEFC    CCR_LNCPUCTL    =       $02     ; Low Noise CPU Control Signals (30% Drive)
DEFC    CCR_LNAD        =       $01     ; Low Noise Address and Data Signals (30% Drive)

;   DMA/Wait Control Reg (DCNTL)

DEFC    DCNTL_MWI1      =       $80     ; Memory Wait Insertion 1 (1 Default)
DEFC    DCNTL_MWI0      =       $40     ; Memory Wait Insertion 0 (1 Default)
DEFC    DCNTL_IWI1      =       $20     ; I/O Wait Insertion 1 (1 Default)
DEFC    DCNTL_IWI0      =       $10     ; I/O Wait Insertion 0 (1 Default)
DEFC    DCNTL_DMS1      =       $08     ; DMA Request Sense 1
DEFC    DCNTL_DMS0      =       $04     ; DMA Request Sense 0
DEFC    DCNTL_DIM1      =       $02     ; DMA Channel 1 I/O & Memory Mode
DEFC    DCNTL_DIM0      =       $01     ; DMA Channel 1 I/O & Memory Mode

;   INT/TRAP Control Register (ITC)

DEFC    ITC_TRAP        =       $80     ; TRAP Encountered
DEFC    ITC_UFO         =       $40     ; Unidentified Fetch Object
DEFC    ITC_ITE2        =       $04     ; Interrupt Enable #2
DEFC    ITC_ITE1        =       $02     ; Interrupt Enable #1
DEFC    ITC_ITE0        =       $01     ; Interrupt Enable #0 (1 Default)

;   Refresh Control Reg (RCR)

DEFC    RCR_REFE        =       $80     ; DRAM Refresh Enable
DEFC    RCR_REFW        =       $40     ; DRAM Refresh 2 or 3 Wait states
DEFC    RCR_CYC1        =       $02     ; Cycles x4
DEFC    RCR_CYC0        =       $01     ; Cycles x2 on base 10 T states

;   Operation Mode Control Reg (OMCR)

DEFC    OMCR_M1E        =       $80     ; M1 Enable (0 Disabled)
DEFC    OMCR_M1TE       =       $40     ; M1 Temporary Enable
DEFC    OMCR_IOC        =       $20     ; IO Control (1 64180 Mode)

;==============================================================================
;
; Some definitions used with the YAZ-180 on-board peripherals:
;

;   BREAK for Single Step Mode

DEFC    BREAK       =       $2000       ; Any value written $2000->$21FF, halts CPU

;   82C55 PIO Port Definitions

DEFC    PIO         =       $4000       ; Base Address for 82C55
DEFC    PIOA        =       PIO+$00     ; Address for Port A
DEFC    PIOB        =       PIO+$01     ; Address for Port B
DEFC    PIOC        =       PIO+$02     ; Address for Port C
DEFC    PIOCNTL     =       PIO+$03     ; Address for Control Byte

;   PIO Mode Definitions

;   Mode 0 - Basic Input / Output

DEFC    PIOCNTL00   =       $80         ; A->, B->, CH->, CL->
DEFC    PIOCNTL01   =       $81         ; A->, B->, CH->, ->CL
DEFC    PIOCNTL02   =       $82         ; A->, ->B, CH->, CL->
DEFC    PIOCNTL03   =       $83         ; A->, ->B, CH->, ->CL

DEFC    PIOCNTL04   =       $88         ; A->, B->, ->CH, CL->
DEFC    PIOCNTL05   =       $89         ; A->, B->, ->CH, ->CL
DEFC    PIOCNTL06   =       $8A         ; A->, ->B, ->CH, CL->
DEFC    PIOCNTL07   =       $8B         ; A->, ->B, ->CH, ->CL

DEFC    PIOCNTL08   =       $90         ; ->A, B->, CH->, CL->
DEFC    PIOCNTL09   =       $91         ; ->A, B->, CH->, ->CL
DEFC    PIOCNTL10   =       $92         ; ->A, ->B, CH->, CL->
DEFC    PIOCNTL11   =       $83         ; ->A, ->B, CH->, ->CL

DEFC    PIOCNTL12   =       $98         ; ->A, B->, ->CH, CL-> (Default Setting)
DEFC    PIOCNTL13   =       $99         ; ->A, B->, ->CH, ->CL
DEFC    PIOCNTL14   =       $9A         ; ->A, ->B, ->CH, CL->
DEFC    PIOCNTL15   =       $9B         ; ->A, ->B, ->CH, ->CL

;   Mode 1 - Strobed Input / Output
;   TBA Later

;   Mode 2 - Strobed Bidirectional Bus Input / Output
;   TBA Later

;   Am9511A-1 APU Port Definitions

DEFC    APU             =   $C000       ; Base Address for Am9511A
DEFC    APUDATA         =   APU+$00     ; APU Data Port
DEFC    APUCNTL         =   APU+$01     ; APU Control Port

DEFC    APU_OP_ENT      =   $40
DEFC    APU_OP_REM      =   $50
DEFC    APU_OP_ENT16    =   $40
DEFC    APU_OP_ENT32    =   $41
DEFC    APU_OP_REM16    =   $50
DEFC    APU_OP_REM32    =   $51

DEFC    APU_CNTL_BUSY   =   $80
DEFC    APU_CNTL_SIGN   =   $40
DEFC    APU_CNTL_ZERO   =   $20
DEFC    APU_CNTL_DIV0   =   $10
DEFC    APU_CNTL_NEGRT  =   $08
DEFC    APU_CNTL_UNDFL  =   $04
DEFC    APU_CNTL_OVRFL  =   $02
DEFC    APU_CNTL_CARRY  =   $01

DEFC    APU_CNTL_ERROR  =   $1E

;   General TTY

DEFC    CTRLC           =   $03         ; Control "C"
DEFC    CTRLG           =   $07         ; Control "G"
DEFC    BKSP            =   $08         ; Back space
DEFC    LF              =   $0A         ; Line feed
DEFC    CS              =   $0C         ; Clear screen
DEFC    CR              =   $0D         ; Carriage return
DEFC    CTRLO           =   $0F         ; Control "O"
DEFC    CTRLQ	        =   $11         ; Control "Q"
DEFC    CTRLR           =   $12         ; Control "R"
DEFC    CTRLS           =   $13         ; Control "S"
DEFC    CTRLU           =   $15         ; Control "U"
DEFC    ESC             =   $1B         ; Escape
DEFC    DEL             =   $7F         ; Delete

;==============================================================================
;
; DRIVER VARIABLES SECTION - CAO
;

;   Starting immediately after the Z180 Vector Table.
DEFC    basicStarted    =   Z180_VECTOR_BASE+Z180_VECTOR_SIZE
DEFC    sysTimeFraction =   basicStarted+1      ; uint8_t
DEFC    sysTime         =   sysTimeFraction+1   ; uint32_t

DEFC    ASCI0RxInPtr    =   Z180_VECTOR_BASE+Z180_VECTOR_SIZE-(Z180_VECTOR_SIZE%$10)+$10
DEFC    ASCI0RxOutPtr   =   ASCI0RxInPtr+2
DEFC    ASCI0TxInPtr    =   ASCI0RxOutPtr+2
DEFC    ASCI0TxOutPtr   =   ASCI0TxInPtr+2
DEFC    ASCI0RxBufUsed  =   ASCI0TxOutPtr+2
DEFC    ASCI0TxBufUsed  =   ASCI0RxBufUsed+1

DEFC    ASCI1RxInPtr    =   Z180_VECTOR_BASE+Z180_VECTOR_SIZE-(Z180_VECTOR_SIZE%$10)+$20
DEFC    ASCI1RxOutPtr   =   ASCI1RxInPtr+2
DEFC    ASCI1TxInPtr    =   ASCI1RxOutPtr+2
DEFC    ASCI1TxOutPtr   =   ASCI1TxInPtr+2
DEFC    ASCI1RxBufUsed  =   ASCI1TxOutPtr+2
DEFC    ASCI1TxBufUsed  =   ASCI1RxBufUsed+1

DEFC    APUCMDInPtr     =   Z180_VECTOR_BASE+Z180_VECTOR_SIZE-(Z180_VECTOR_SIZE%$10)+$30
DEFC    APUCMDOutPtr    =   APUCMDInPtr+2
DEFC    APUPTRInPtr     =   APUCMDOutPtr+2
DEFC    APUPTROutPtr    =   APUPTRInPtr+2
DEFC    APUCMDBufUsed   =   APUPTROutPtr+2
DEFC    APUPTRBufUsed   =   APUCMDBufUsed+1
DEFC    APUStatus       =   APUPTRBufUsed+1
DEFC    APUError        =   APUStatus+1

;   $nn90 -> $nnFF is slack memory.

;   I/O Buffers must start on 0xnn00 because we increment low byte to roll-over
DEFC    BUFSTART_IO     =   Z80_VECTOR_BASE-(Z80_VECTOR_BASE%$100) + $100

DEFC    ASCI0RxBuf      =   BUFSTART_IO
DEFC    ASCI0TxBuf      =   ASCI0RxBuf+ASCI0_RX_BUFSIZE

DEFC    ASCI1RxBuf      =   ASCI0TxBuf+ASCI0_TX_BUFSIZE
DEFC    ASCI1TxBuf      =   ASCI1RxBuf+ASCI1_RX_BUFSIZE

DEFC    APUCMDBuf       =   ASCI1TxBuf+ASCI1_TX_BUFSIZE
DEFC    APUPTRBuf       =   APUCMDBuf+APU_CMD_BUFSIZE

;==============================================================================
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
reset:
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

;======MAIN======

            DI                      ; Disable interrupts
            LD      A,Z180_VECTOR_BASE%$100
            OUT0    (IL),A          ; Set interrupt vector address low byte (IL)

 ;           IM      1               ; Interrupt mode 1 for INT0

            XOR     A               ; Zero Accumulator

                                    ; Clear Refresh Control Reg (RCR)
            OUT0    (RCR),A         ; DRAM Refresh Enable (0 Disabled)

                                    ; Clear INT/TRAP Control Register (ITC)             
            OUT0    (ITC),A         ; Disable all external interrupts.             

                                    ; Set Operation Mode Control Reg (OMCR)
            LD      A,OMCR_M1E      ; Enable M1 for single step, disable 64180 I/O _RD Mode
            OUT0    (OMCR),A        ; X80 Mode (M1 Disabled, IOC Disabled)

                                    ; Set internal clock = crystal x 2 = 36.864MHz
                                    ; if using ZS8180 or Z80182 at High-Speed
            LD      A,CMR_X2        ; Set Hi-Speed flag
            OUT0    (CMR),A         ; CPU Clock Multiplier Reg (CMR)

                                    ; DMA/Wait Control Reg Set I/O Wait States
            LD      A,DCNTL_IWI0
            OUT0    (DCNTL),A       ; 0 Memory Wait & 2 I/O Wait

            LD      HL,Z80_VECTOR_PROTO ; Establish Z80 RST Vector Table
            LD      DE,Z80_VECTOR_BASE
            LD      BC,Z80_VECTOR_SIZE
            LDIR

            LD      HL,Z180_VECTOR_PROTO ; Establish Z180 Vector Table
            LD      DE,Z180_VECTOR_BASE
            LD      BC,Z180_VECTOR_SIZE
            LDIR

                                    ; Set Logical RAM Addresses
                                    ; $2000-$FFFF RAM   CA1 -> $2n
                                    ; $0000-$1FFF Flash BANK -> $n0

            LD      A,$C8           ; Set New Common 1 / Bank Areas for RAM
            OUT0    (CBAR),A

            LD      A,$10           ; Set Common 1 Base Physical $12000 -> $10
            OUT0    (CBR),A

            LD      A,$00           ; Set Bank Base Physical $00000 -> $00
            OUT0    (BBR),A

                                    ; load the default ASCI configuration
                                    ; BAUD = 115200 8n1
                                    ; receive enabled
                                    ; transmit enabled
                                    ; receive interrupt enabled
                                    ; transmit interrupt disabled

            LD      A,ASCI_RE|ASCI_TE|ASCI_8N1
            OUT0    (CNTLA0),A      ; output to the ASCI0 control A reg

                                    ; PHI / PS / SS / DR = BAUD Rate
                                    ; PHI = 18.432MHz
                                    ; BAUD = 115200 = 18432000 / 10 / 1 / 16 
                                    ; PS 0, SS_DIV_1 0, DR 0           
            XOR     A               ; BAUD = 115200
            OUT0    (CNTLB0),A      ; output to the ASCI0 control B reg

            LD      A,ASCI_RIE      ; receive interrupt enabled
            OUT0    (STAT0),A       ; output to the ASCI0 status reg

                                    ; we do 256 ticks per second
            ld      hl, CPU_CLOCK/CPU_TIMER_SCALE/256-1
            out0    (RLDR0L), l
            out0    (RLDR0H), h
                                    ; enable down counting and interrupts for PRT0
            ld      a, TCR_TIE0|TCR_TDE0
            out0    (TCR), a

            LD      SP,TEMPSTACK    ; Set up a temporary stack

            LD      HL,ASCI0RxBuf   ; Initialise 0Rx Buffer
            LD      (ASCI0RxInPtr),HL
            LD      (ASCI0RxOutPtr),HL

            LD      HL,ASCI0TxBuf   ; Initialise 0Tx Buffer
            LD      (ASCI0TxInPtr),HL
            LD      (ASCI0TxOutPtr),HL              

            XOR     A               ; 0 the ASCI0 Tx & Rx Buffer Counts
            LD      (ASCI0RxBufUsed),A
            LD      (ASCI0TxBufUsed),A

            EI                      ; enable interrupts

;reset1
;	in0		a,(STAT0)			; get status of ASC0
;	and		2h					; test TDRE
;	jr		z,reset1			; loop until TDRE=1
;	ld		a,'A'				; move byte into A
;	out0	(TDR0),a			; send byte to ASC0
;	jp		reset1				; do forever

ASCI0_INTERRUPT:
        push af
        push hl
                                    ; start doing the Rx stuff
        in0 a, (STAT0)              ; load the ASCI0 status register
        tst ASCI_RDRF               ; test whether we have received on ASCI0
        jr z, ASCI0_TX_CHECK        ; if not, go check for bytes to transmit

ASCI0_RX_GET:
        in0 l, (RDR0)               ; move Rx byte from the ASCI0 RDR to l
        
        and ASCI_OVRN|ASCI_PE|ASCI_FE   ; test whether we have error on ASCI0
        jr nz, ASCI0_RX_ERROR       ; drop this byte, clear error, and get the next byte

        ld a, (ASCI0RxBufUsed)      ; get the number of bytes in the Rx buffer      
        cp ASCI0_RX_BUFSIZE-1       ; check whether there is space in the buffer
        jr nc, ASCI0_RX_CHECK       ; buffer full, check whether we need to drain H/W FIFO

        ld a, l                     ; get Rx byte from l
        ld hl, (ASCI0RxInPtr)       ; get the pointer to where we poke
        ld (hl), a                  ; write the Rx byte to the ASCI0RxInPtr target

        inc l                       ; move the Rx pointer low byte along, 0xFF rollover
        ld (ASCI0RxInPtr), hl       ; write where the next byte should be poked

        ld hl, ASCI0RxBufUsed
        inc (hl)                    ; atomically increment Rx buffer count
        jr ASCI0_RX_CHECK           ; check for additional bytes

ASCI0_RX_ERROR:
        in0 a, (CNTLA0)             ; get the CNTRLA0 register
        and ~ASCI_EFR               ; to clear the error flag, EFR, to 0 
        out0 (CNTLA0), a            ; and write it back

ASCI0_RX_CHECK:                     ; Z8S180 has 4 byte Rx H/W FIFO
        in0 a, (STAT0)              ; load the ASCI0 status register
        tst ASCI_RDRF               ; test whether we have received on ASCI0
        jr nz, ASCI0_RX_GET         ; if still more bytes in H/W FIFO, get them

ASCI0_TX_CHECK:                     ; now start doing the Tx stuff
        and ASCI_TDRE               ; test whether we can transmit on ASCI0
        jr z, INTERRUPT_EXIT        ; if not, then end

        ld a, (ASCI0TxBufUsed)      ; get the number of bytes in the Tx buffer
        or a                        ; check whether it is zero
        jr z, ASCI0_TX_TIE0_CLEAR   ; if the count is zero, then disable the Tx Interrupt

        ld hl, (ASCI0TxOutPtr)      ; get the pointer to place where we pop the Tx byte
        ld a, (hl)                  ; get the Tx byte
        out0 (TDR0), a              ; output the Tx byte to the ASCI0

        inc l                       ; move the Tx pointer low byte along, 0xFF rollover
        ld (ASCI0TxOutPtr), hl      ; write where the next byte should be popped

        ld hl, ASCI0TxBufUsed
        dec (hl)                    ; atomically decrement current Tx count

        jr nz, INTERRUPT_EXIT       ; if we've more Tx bytes to send, we're done for now

ASCI0_TX_TIE0_CLEAR:
        in0 a, (STAT0)              ; get the ASCI0 status register
        and ~ASCI_TIE               ; mask out (disable) the Tx Interrupt
        out0 (STAT0), a             ; set the ASCI0 status register

INTERRUPT_EXIT:
        pop hl
        pop af
        ei
        ret

PRT0_INTERRUPT:
        push af
        push hl

        in0 a, (TCR)                ; to clear the PRT0 interrupt, read the TCR
        in0 a, (TMDR0H)             ; followed by the TMDR0

        ld hl, sysTimeFraction
        inc (hl)
        jr NZ, INTERRUPT_EXIT       ; at 0 we're at 1 second count, interrupted 256 times

;       ld hl, sysTime              ; inc hl works, provided the storage is contiguous
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr INTERRUPT_EXIT
        
RX0_CHK:
        LD      A,(ASCI0RxBufUsed)
        CP      $0
        RET

;------------------------------------------------------------------------------
RX0:
        ld a, (ASCI0RxBufUsed)      ; get the number of bytes in the Rx buffer
        or a                        ; see if there are zero bytes available
        jr z, RX0                   ; wait, if there are no bytes available

        push hl                     ; Store HL so we don't clobber it

        ld hl, (ASCI0RxOutPtr)      ; get the pointer to place where we pop the Rx byte
        ld a, (hl)                  ; get the Rx byte

        inc l                       ; move the Rx pointer low byte along, 0xFF rollover
        ld (ASCI0RxOutPtr), hl      ; write where the next byte should be popped

        ld hl, ASCI0RxBufUsed
        dec (hl)                    ; atomically decrement Rx count

        pop hl                      ; recover HL
        ret                         ; char ready in A

;------------------------------------------------------------------------------
TX0:
        push hl                     ; store HL so we don't clobber it        
        ld l, a                     ; store Tx character 

        ld a, (ASCI0TxBufUsed)      ; get the number of bytes in the Tx buffer
        or a                        ; check whether the buffer is empty
        jr nz, TX0_BUFFER_OUT       ; buffer not empty, so abandon immediate Tx

        in0 a, (STAT0)              ; get the ASCI0 status register
        and ASCI_TDRE                ; test whether we can transmit on ASCI0
        jr z, TX0_BUFFER_OUT        ; if not, so abandon immediate Tx

        ld a, l                     ; Retrieve Tx character for immediate Tx
        out0 (TDR0), a              ; output the Tx byte to the ASCI0

        pop hl                      ; recover HL
        ret                         ; and just complete

TX0_BUFFER_OUT:
        ld a, (ASCI0TxBufUsed)      ; Get the number of bytes in the Tx buffer
        cp ASCI0_TX_BUFSIZE-1       ; check whether there is space in the buffer
        jr nc, TX0_BUFFER_OUT       ; buffer full, so wait for free buffer for Tx

        ld a, l                     ; retrieve Tx character

        ld hl, ASCI0TxBufUsed
        di
        inc (hl)                    ; atomic increment of Tx count
        ld hl, (ASCI0TxInPtr)       ; get the pointer to where we poke
        ei
        ld (hl), a                  ; write the Tx byte to the ASCI0TxInPtr   

        inc l                       ; move the Tx pointer low byte along, 0xFF rollover
        ld (ASCI0TxInPtr), hl       ; write where the next byte should be poked

        pop hl                      ; recover HL

        in0 a, (STAT0)              ; load the ASCI0 status register
        and ASCI_TIE                ; test whether ASCI0 interrupt is set
        ret nz                      ; if so then just return

        di                          ; critical section begin
        in0 a, (STAT0)              ; get the ASCI status register again
        or ASCI_TIE                 ; mask in (enable) the Tx Interrupt
        out0 (STAT0), a             ; set the ASCI status register
        ei                          ; critical section end
        ret

;------------------------------------------------------------------------------
TX0_PRINT:
        LD      A,(HL)              ; Get a byte
        OR      A                   ; Is it $00 ?
        RET     Z                   ; Then RETurn on terminator
        CALL    TX0                 ; Print it
        INC     HL                  ; Next byte
        JR      TX0_PRINT           ; Continue until $00

;------------------------------------------------------------------------------
