
;==============================================================================
;
; DEFINES SECTION
;

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
DEFC    kZ180Base   =   $C0
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

DEFC    ASCI0           =       $12
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

; I/O REGISTER BIT FIELDS

defc CNTLA0_MPE         = 0x80
defc CNTLA0_RE          = 0x40
defc CNTLA0_TE          = 0x20
defc CNTLA0_RTS0        = 0x10
defc CNTLA0_MPBR        = 0x08
defc CNTLA0_EFR         = 0x08
defc CNTLA0_MODE_MASK   = 0x07
defc CNTLA0_MODE_8P2    = 0x07
defc CNTLA0_MODE_8P1    = 0x06
defc CNTLA0_MODE_8N2    = 0x05
defc CNTLA0_MODE_8N1    = 0x04
defc CNTLA0_MODE_7P2    = 0x03
defc CNTLA0_MODE_7P1    = 0x02
defc CNTLA0_MODE_7N2    = 0x01
defc CNTLA0_MODE_7N1    = 0x00

defc CNTLA1_MPE         = 0x80
defc CNTLA1_RE          = 0x40
defc CNTLA1_TE          = 0x20
defc CNTLA1_CKA1D       = 0x10
defc CNTLA1_MPBR        = 0x08
defc CNTLA1_EFR         = 0x08
defc CNTLA1_MODE_MASK   = 0x07
defc CNTLA1_MODE_8P2    = 0x07
defc CNTLA1_MODE_8P1    = 0x06
defc CNTLA1_MODE_8N2    = 0x05
defc CNTLA1_MODE_8N1    = 0x04
defc CNTLA1_MODE_7P2    = 0x03
defc CNTLA1_MODE_7P1    = 0x02
defc CNTLA1_MODE_7N2    = 0x01
defc CNTLA1_MODE_7N1    = 0x00

defc CNTLB0_MPBT = 0x80
defc CNTLB0_MP = 0x40
defc CNTLB0_CTS = 0x20
defc CNTLB0_PS = 0x20
defc CNTLB0_PEO = 0x10
defc CNTLB0_DR = 0x08
defc CNTLB0_SS_MASK = 0x07
defc CNTLB0_SS_EXT = 0x07
defc CNTLB0_SS_DIV_64 = 0x06
defc CNTLB0_SS_DIV_32 = 0x05
defc CNTLB0_SS_DIV_16 = 0x04
defc CNTLB0_SS_DIV_8 = 0x03
defc CNTLB0_SS_DIV_4 = 0x02
defc CNTLB0_SS_DIV_2 = 0x01
defc CNTLB0_SS_DIV_1 = 0x00

defc CNTLB1_MPBT = 0x80
defc CNTLB1_MP = 0x40
defc CNTLB1_CTS = 0x20
defc CNTLB1_PS = 0x20
defc CNTLB1_PEO = 0x10
defc CNTLB1_DR = 0x08
defc CNTLB1_SS_MASK = 0x07
defc CNTLB1_SS_EXT = 0x07
defc CNTLB1_SS_DIV_64 = 0x06
defc CNTLB1_SS_DIV_32 = 0x05
defc CNTLB1_SS_DIV_16 = 0x04
defc CNTLB1_SS_DIV_8 = 0x03
defc CNTLB1_SS_DIV_4 = 0x02
defc CNTLB1_SS_DIV_2 = 0x01
defc CNTLB1_SS_DIV_1 = 0x00

defc STAT0_RDRF = 0x80
defc STAT0_OVRN = 0x40
defc STAT0_PE = 0x20
defc STAT0_FE = 0x10
defc STAT0_RIE = 0x08
defc STAT0_DCD0 = 0x04
defc STAT0_TDRE = 0x02
defc STAT0_TIE = 0x01

defc STAT1_RDRF = 0x80
defc STAT1_OVRN = 0x40
defc STAT1_PE = 0x20
defc STAT1_FE = 0x10
defc STAT1_RIE = 0x08
defc STAT1_CTS1E = 0x04
defc STAT1_TDRE = 0x02
defc STAT1_TIE = 0x01

defc CNTR_EF = 0x80
defc CNTR_EIE = 0x40
defc CNTR_RE = 0x20
defc CNTR_TE = 0x10
defc CNTR_SS_MASK = 0x07
defc CNTR_SS_EXT = 0x07
defc CNTR_SS_DIV_1280 = 0x06
defc CNTR_SS_DIV_640 = 0x05
defc CNTR_SS_DIV_320 = 0x04
defc CNTR_SS_DIV_160 = 0x03
defc CNTR_SS_DIV_80 = 0x02
defc CNTR_SS_DIV_40 = 0x01
defc CNTR_SS_DIV_20 = 0x00

;   ASCI Control Reg B (CNTLBn)
                                        ; BAUD Rate = PHI / PS / SS / DR

DEFC    ASCI1           =       $13
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
DEFC    ASCI_TDRE       =       $01     ; Transmit Data Register Empty
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

DEFC    CMR_X1          =       $00
DEFC    CMR_X2          =       $80     ; CPU x2 XTAL Multiplier Mode
DEFC    CMR_LN_XTAL     =       $40     ; Low Noise Crystal 

;   CPU Control Reg (CCR) (Z8S180 & higher Only)

DEFC    CCR_XTAL_DIV1     =       $80     ; PHI = XTAL Mode
DEFC    CCR_XTAL_DIV2     =       $00     ; PHI = XTAL Mode
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
defc __CPU_CLOCK = 18432000
defc __CPU_TIMER_SCALE = 20
DEFC kData  = 0xFC00         ;Typically 0xFC00 (to 0xFFFF)
DEFC kSPUsr = kData+0x00C0 
asci0TxLock:    defb    $FE             ; mutex for Tx0
asci0RxLock:    defb    $FE    
asci1RxLock:    defb    $FE             ; mutex for Rx1
asci1TxLock:    defb    $FE             ; mutex for Tx1

		ORG		0000h			; start of program
RESET:
;======MAIN======

    di
    LD   HL,kSPUsr      ;Get top of user stack
    LD   SP,HL
    xor     a               ; Zero Accumulator

    ld a,$80
    out0 (IL),a
    
    ld      a,kZ180Base
	out0	(ICR),a			; set up I/O control
    
    

; Initialise Memory Management Unit (MMU)
;
; Logical (64k) memory is divided into three areas:
;   Common(0)  This is always 0x0000
;   Bank       Starts at BA * 0x1000
;   Common     Starts at CA * 0x1000
;
; Physical (1M) memory is determined as follows:
;    Common(0)  This always starts at 0x00000
;    Bank       Starts at (CBR+CA) * 0x1000
;    Common     Starts at (BBR+BA) * 0x1000
;
; Registers:
;    Bank Base Register        (BBR)  = 0x00 to 0xFF
;    Common Base Register      (CBR)  = 0x00 to 0xFF
;    Common/Bank Area Register (CBAR) = CA.BA (nibbles)
;
; Following a hardware reset the MMU registers are:
;    BBR=0x00, CBR = 0x00, CBAR = 0xFF (= CA.BA)
; Thus the logical (64k) memory to physical (1M) memory mapping is:
;    Common(0) 0x0000 to 0xEFFF -> 0x00000 to 0x0EFFF (ROM)
;    Bank      0xF000 to 0xF000 -> 0x0F000 to 0x0F000 (RAM)
;    Common(1) 0xF000 to 0xFFFF -> 0x0F000 to 0x0FFFF (RAM)
;
; Initialise logical (64k) memory to physical (1M) memory mapping
; such that the bottom 32k bytes of logical memory is the bottom 32k
; bytes of the physical Flash ROM, and the top 32k bytes of logical 
; memory is the top 32k bytes of the physical RAM.
;    Common(0) 0x0000 to 0x0000 -> 0x00000 to 0x00000 (ROM)
;    Bank      0x0000 to 0x7FFF -> 0x00000 to 0x07FFF (ROM)
;    Common(1) 0x8000 to 0xFFFF -> 0xF8000 to 0xFFFFF (RAM)
; 
; This is achieved by setting the registers as follows:
;    CBAR = CA.BA = 0x8.0x0 = 0x80
;    BBR  = (physical address)/0x1000 - BA = 0x00 - 0x0 = 0x00
;    CBR  = (physical address)/0x1000 - BA = 0xF8 - 0x8 = 0xF0
            LD   A, 0x00        ;Physical memory base address:
            OUT0 (BBR), A       ;  Bank Base = 0x00000
            LD   A, 0xF0        ;Physical memory base address:
            OUT0 (CBR), A       ;  Common Base = 0xF8000
            LD   A, 0x80        ;Logical memory base addresses:
            OUT0 (CBAR), A      ;  Bank = 0x0000, Common = 0x8000


    ; ALREADY DONE DURING SELF TEST
; Position Z180 internal I/O at 0xC0 to 0xFF
            ;LD   A,0xC0        ;Start of Z180 internal I/O
            ;OUT0 (ICR),A

; ALREADY DONE DURING SELF TEST
; Initialise Memory Management Unit (MMU)
; This maps logical (64k) memory to physical (1M) memory
; Common(0) 0x0000 to 0x7FFF -> 0x00000 to 0x07FFF
; Bank      0x8000 to 0xFFFF -> 0x80000 to 0xFFFFF
; Common(1) 0x8000 to 0xFFFF -> 0x80000 to 0xFFFFF
            ;LD   A,0x80        ;Physical address = A x 0x1000
            ;OUT0 (BBR), A      ;Bank Base Register = 0x80
            ;OUT0 (CBR), A      ;Common(1) Base Register = 0x80
; Both Bank and Common(1) start at logical address 0x8000
            ;LD   A,0x88        ;Logical address = Nibble x 0x1000
            ;OUT0 (CBAR), A     ;Both start at 0x8000

; Initialise Z180 serial port 0
;
; Baud rate = PHI/(baud rate divider x prescaler x sampling divider)
;   PHI = CPU clock input / 1 = 18.432/1 MHz = 18.432 MHz
;   Baud rate divider (1,2,4,8,16,32,or 64) = 1
;   Prescaler (10 or 30) = 10
;   Sampling divide rate (16 or 64) = 16
; Baud rate = 18,432,00 / ( 1 x 10 x 16) = 18432000 / 160 = 115200 baud
;
; Control Register A for channel 0 (CNTLA0)
;   Bit 7 = 0    Multiprocessor Mode Enable (MPE)
;   Bit 6 = 1    Receiver Enable (RE)
;   Bit 5 = 1    Transmitter Enable (TE)
;   Bit 4 = 0    Request to Send Output (RTS0) (0 = Low, 1 = High)
;   Bit 3 = 0    Multiprocessor Bit Receive/Error Flag (MPBR) (0 = Reset)
;   Bit 2 = 1    Data Format (0 = 7-bit, 1 = 8-bit)
;   Bit 1 = 0    Parity (0 = No Parity, 1 = Parity Enabled)
;   Bit 0 = 0    Stop Bits (0 = 1 Stop Bit, 1 = 2 Stop Bits)
            LD   A, 0b01100100
            OUT0 (CNTLA0), A
; And the same for channel 1 
            OUT0 (CNTLA1), A

; Control Register B for channel 0 (CNTLB0)
;   Bit 7 = 0    Multiprocessor Bit Transmit (MPBT)
;   Bit 6 = 0    Multiprocessor Mode (MP)
;   Bit 5 = 0    Clear to Send/Prescale (CTC/PS) (0 = PHI/10, 1 = PHI/30)
;   Bit 4 = 0    Parity Even Odd (PEO) (0 = Even, 1 = Odd)
;   Bit 3 = 0    Divide Ratio (DR) (0 = divide 16, 1 = divide 64)
;   Bit 2 = 000  Source/Speed Select (SS2-SS0)
;    to 0        (0 = /1, 1 = /2, .. 6 = /64, 7 = External clock)
            LD   A, 0b00000000
            OUT0 (CNTLB0), A
; And the same for channel 1 
            OUT0 (CNTLB1), A

; Extension Control Register (ASCI0) [Z8S180/L180-class processors only)
;   Bit 7 = 0    Receive Interrupt Inhibit (0 = Inhibited, 1 = Enabled)
;   Bit 6 = 1    DCD0 Disable (0 = DCD0 Auto-enable Rx, 1 = Advisory)
;   Bit 5 = 1    CTS0 Disable (0 = CTS0 Auto-enable Tx, 1 = Advisory)
;   Bit 4 = 0    X1 Bit Clock (0 = CKA0/16 or 64, 1 = CKA0 is bit clock)
;   Bit 3 = 0    BRG0 Mode (0 = As S180, 1 = Enable 16-BRG counter)
;   Bit 2 = 0    Break Feature (0 = Enabled, 1 = Disabled)
;   Bit 1 = 0    Break Detect (0 = On, 1 = Off)
;   Bit 0 = 0    Send Break (0 = Normal transmit, 1 = Drive TXA Low)
            LD   A, 0b01100000
            OUT0 (ASCI0), A
; And the same for channel 1 
            OUT0 (ASCI1), A

; Refresh Control Register (RCR)
;   Bit 7 = 0    Refresh Enable (REFE) (0 = Disabled, 1 = Enabled)
;   Bit 6 = 0    Refresh Wait (REFW) (0 = 2 clocksm 3 = 3 clocks)
;   Bit 1-0 = 0  Cycle Interval (CYC1-0) 
            LD   A, 0b00000000
            OUT0 (RCR), A       ;Turn off memory refresh

; DMA/WAIT Control Register (DCNTL)
;   Bit 7-6 = 00 Memory Wait Insertion (MWI1-0) (0 to 3 wait states)
;   Bit 5-4 = 11 I/O Wait Insertion (IWI1-0) (0 to 3 wait states) 
;   Bit 3 = 0    DMA Request Sense ch 1 (DMS1) (0 = Level, 1 = Edge)
;   Bit 2 = 0    DMA Request Sense ch 0 (DMS0) (0 = Level, 1 = Edge)
;   Bit 1 = 0    DMA Channel 1 Mode (DIM1) (0 = Mem to I/O, 1 = I/O to Mem)
;   Bit 0 = 0    DMA Channel 0 Mode (DIM0) (0 = MARI+1, 1 = MARI-1)
;   Bit 3-2 = 00 DMA Request Sense (DMS1-0) (0 = Level, 1 = Edge)
            LD   A, 0b00110000
            OUT0 (DCNTL), A     ;Maximum wait states for I/O and Memory

; Operating Mode Control Register (OMCR)
;   Bit 7 = 0    M1 Enable (M1E) (1 = Default, 0 = Z80 compatibility mode)
;   Bit 6 = 0    M1 Temporary Enable (M1TE) (1 = Default, 0 = Z80 mode)
;   Bit 5 = 0    I/O Compatibility (IOC) (1 = Default, 0 = Z80 mode)
;   Bits 4-0 = 0 Reserved
            LD   A, 0b00000000
            OUT0 (OMCR), A      ;Select Z80 compatibility mode

; CPU Control Register (CCR)
;   Bit 7 = 1    CPU Clock Divide (0 = Divide 2, 1 = Divide 1)
;   Bit 6+3 = 0  Standy/Idle Mode (00 = No Standby, 01 = ...)
;   Bit 5 = 0    Bus Request Exit (0 = Ignore in standby, 1 = Exit on BR)
;   Bit 4 = 0    PHI Clock Drive (0 = Standard, 1 = 33%)
;   Bit 3+6 = 0  Standy/Idle Mode (00 = No Standby, 01 = ...)
;   Bit 2 = 0    External I/O Drive (0 = Standard, 1 = 33%)
;   Bit 1 = 0    Control Signal Drive (0 = Standard, 1 = 33%)
;   Bit 0 = 0    Address and Data Drive (0 = Standard, 1 = 33%)
            LD   A, 0b10000000
            OUT0 (CCR), A

; Set reload registers for 1ms timer
; Timer input clock is PHI/20 = 18,432,000MHz/20 = 921.6kHz
; Relead time to give 1ms timer is 921.6 (0x039A when rounded up)
            LD   A,0x9A
            OUT0 (RLDR0L),A
            LD   A,0x03
            OUT0 (RLDR0H),A

; Timer Control Register
;   Bit 7 = 0    Timer 1 interrupt flag
;   Bit 6 = 0    Timer 0 interrupt flag
;   Bit 5 = 0    Timer 1 interrupt enable
;   Bit 4 = 0    Timer 0 interrupt enable
;   Bit 3-2 = 00 Inhibit timer output on A18/Tout
;   Bit 1 = 0    Timer 1 down count enable
;   Bit 0 = 1    Timer 0 down count enable
            LD   A,0b00000001
            OUT0 (TCR),A

    
RESET1:
        IN0  B,(STAT0)      ;Read serial port status register
        BIT  ASCI_TDRE,B      ;Transmit register empty?
        RET  Z              ;Return Z as character not output
        LD		A,$41				; move byte into A
        OUT0 (TDR0), A      ;Write byte to serial port
        OR   0xFF           ;Return success A=0xFF and NZ flagged
	    jp	RESET1				; do forever
