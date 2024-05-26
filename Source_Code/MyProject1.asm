
_CCPPWM_init:

;MyProject1.c,22 :: 		void CCPPWM_init(void){ //Configure CCP1 and CCP2 at 2ms period with 50% duty cycle
;MyProject1.c,23 :: 		T2CON = 0x07;//enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount 2000uS to count 250 counts)
	MOVLW      7
	MOVWF      T2CON+0
;MyProject1.c,24 :: 		CCP1CON = 0x00;//enable PWM for CCP1
	CLRF       CCP1CON+0
;MyProject1.c,25 :: 		CCP2CON = 0x00;//enable PWM for CCP2
	CLRF       CCP2CON+0
;MyProject1.c,26 :: 		PR2 = 250;// 250 counts =8uS *250 =2ms period
	MOVLW      250
	MOVWF      PR2+0
;MyProject1.c,27 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;MyProject1.c,29 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_myDelay_ms:

;MyProject1.c,31 :: 		void myDelay_ms(signed long int ms){
;MyProject1.c,32 :: 		TMR0=248;
	MOVLW      248
	MOVWF      TMR0+0
;MyProject1.c,33 :: 		DelayMsCNTR=0;
	CLRF       _DelayMsCNTR+0
	CLRF       _DelayMsCNTR+1
	CLRF       _DelayMsCNTR+2
	CLRF       _DelayMsCNTR+3
;MyProject1.c,34 :: 		INTCON=INTCON|0x20;   //Enable TMR0 overflow interrupt
	BSF        INTCON+0, 5
;MyProject1.c,35 :: 		while(DelayMsCNTR<ms);         //keeps interrupting
L_myDelay_ms0:
	MOVF       FARG_myDelay_ms_ms+3, 0
	SUBWF      _DelayMsCNTR+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myDelay_ms56
	MOVF       FARG_myDelay_ms_ms+2, 0
	SUBWF      _DelayMsCNTR+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myDelay_ms56
	MOVF       FARG_myDelay_ms_ms+1, 0
	SUBWF      _DelayMsCNTR+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myDelay_ms56
	MOVF       FARG_myDelay_ms_ms+0, 0
	SUBWF      _DelayMsCNTR+0, 0
L__myDelay_ms56:
	BTFSC      STATUS+0, 0
	GOTO       L_myDelay_ms1
	GOTO       L_myDelay_ms0
L_myDelay_ms1:
;MyProject1.c,36 :: 		INTCON=INTCON&0xDF;   //Disable TMR0 overflow interrupt
	MOVLW      223
	ANDWF      INTCON+0, 1
;MyProject1.c,37 :: 		}
L_end_myDelay_ms:
	RETURN
; end of _myDelay_ms

_piezo_buzzer:

;MyProject1.c,39 :: 		void piezo_buzzer(void){
;MyProject1.c,40 :: 		PORTE=PORTE|0x02;
	BSF        PORTE+0, 1
;MyProject1.c,41 :: 		myDelay_ms(100);
	MOVLW      100
	MOVWF      FARG_myDelay_ms_ms+0
	CLRF       FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,42 :: 		PORTE=PORTE&0xFD;
	MOVLW      253
	ANDWF      PORTE+0, 1
;MyProject1.c,43 :: 		myDelay_ms(100);
	MOVLW      100
	MOVWF      FARG_myDelay_ms_ms+0
	CLRF       FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,45 :: 		}
L_end_piezo_buzzer:
	RETURN
; end of _piezo_buzzer

_ATD_init:

;MyProject1.c,47 :: 		void ATD_init(void){
;MyProject1.c,48 :: 		ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;MyProject1.c,49 :: 		ADCON1 = 0xCE;// All channels Analog, 500 KHz, right justified  XXXXX
	MOVLW      206
	MOVWF      ADCON1+0
;MyProject1.c,50 :: 		TRISA = 0xFF;
	MOVLW      255
	MOVWF      TRISA+0
;MyProject1.c,52 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read:

;MyProject1.c,53 :: 		unsigned int ATD_read(void){
;MyProject1.c,54 :: 		ADCON0 = ADCON0 | 0x04;// GO
	BSF        ADCON0+0, 2
;MyProject1.c,55 :: 		while(ADCON0 & 0x04);
L_ATD_read2:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read3
	GOTO       L_ATD_read2
L_ATD_read3:
;MyProject1.c,56 :: 		return((ADRESH<<8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProject1.c,57 :: 		}
L_end_ATD_read:
	RETURN
; end of _ATD_read

_Scan_Keypad:

;MyProject1.c,59 :: 		unsigned char Scan_Keypad(void){
;MyProject1.c,60 :: 		kp=0;  // Reset key code variable
	CLRF       _kp+0
;MyProject1.c,62 :: 		do
L_Scan_Keypad4:
;MyProject1.c,64 :: 		kp = Keypad_Key_Click();             // Store key code in kp variable
	CALL       _Keypad_Key_Click+0
	MOVF       R0+0, 0
	MOVWF      _kp+0
;MyProject1.c,65 :: 		while (!kp);
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Scan_Keypad4
;MyProject1.c,85 :: 		if (kp==15){     //case '#' can't be handeled using the equation
	MOVF       _kp+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_Scan_Keypad7
;MyProject1.c,86 :: 		return 35;
	MOVLW      35
	MOVWF      R0+0
	GOTO       L_end_Scan_Keypad
;MyProject1.c,87 :: 		}
L_Scan_Keypad7:
;MyProject1.c,89 :: 		kp=(kp%14)+48-((kp%14)/4);
	MOVLW      14
	MOVWF      R4+0
	MOVF       _kp+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      R3+0
	MOVF       R0+0, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	MOVF       R1+0, 0
	SUBWF      R3+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _kp+0
;MyProject1.c,90 :: 		return kp;
;MyProject1.c,91 :: 		}
L_end_Scan_Keypad:
	RETURN
; end of _Scan_Keypad

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject1.c,93 :: 		void interrupt(void){
;MyProject1.c,97 :: 		INTCON=INTCON&0xFB;
	MOVLW      251
	ANDWF      INTCON+0, 1
;MyProject1.c,99 :: 		DelayMsCNTR++;
	MOVF       _DelayMsCNTR+0, 0
	MOVWF      R0+0
	MOVF       _DelayMsCNTR+1, 0
	MOVWF      R0+1
	MOVF       _DelayMsCNTR+2, 0
	MOVWF      R0+2
	MOVF       _DelayMsCNTR+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _DelayMsCNTR+0
	MOVF       R0+1, 0
	MOVWF      _DelayMsCNTR+1
	MOVF       R0+2, 0
	MOVWF      _DelayMsCNTR+2
	MOVF       R0+3, 0
	MOVWF      _DelayMsCNTR+3
;MyProject1.c,101 :: 		TMR0=248;
	MOVLW      248
	MOVWF      TMR0+0
;MyProject1.c,106 :: 		}
L_end_interrupt:
L__interrupt62:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;MyProject1.c,118 :: 		void main() {
;MyProject1.c,121 :: 		INTCON=0xE0;        //Global Interrupt, periphral inrterrupt, TMR0 overflow interrupt enabled
	MOVLW      224
	MOVWF      INTCON+0
;MyProject1.c,122 :: 		OPTION_REG=0x07;     //Prescalar set to 1:256
	MOVLW      7
	MOVWF      OPTION_REG+0
;MyProject1.c,125 :: 		TRISC=0x00; //RC1-RC6 Motors --> output
	CLRF       TRISC+0
;MyProject1.c,129 :: 		PORTC=0x00;  //initialize all pins low
	CLRF       PORTC+0
;MyProject1.c,131 :: 		TRISE=0x00;  //Port E output -->Buzzer E0,E1
	CLRF       TRISE+0
;MyProject1.c,132 :: 		PORTE=0x00;  //initialize all pins low
	CLRF       PORTE+0
;MyProject1.c,135 :: 		Lcd_Init();                        //Initialize   Lcd on Port B
	CALL       _Lcd_Init+0
;MyProject1.c,136 :: 		Keypad_Init();                        // Initialize Keypad to port D
	CALL       _Keypad_Init+0
;MyProject1.c,137 :: 		ATD_init();                           // Initialize Port A where A0 is Analog, others digital  ALL PINS INPUTS
	CALL       _ATD_init+0
;MyProject1.c,138 :: 		CCPPWM_init();                         //PWM
	CALL       _CCPPWM_init+0
;MyProject1.c,168 :: 		while(1){
L_main8:
;MyProject1.c,169 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,170 :: 		Lcd_Out(1,1,"Enter Nap time:");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,171 :: 		Lcd_Cmd(_LCD_SECOND_ROW);
	MOVLW      192
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,172 :: 		i=0;
	CLRF       _i+0
	CLRF       _i+1
;MyProject1.c,173 :: 		pressedKey= Scan_Keypad();
	CALL       _Scan_Keypad+0
	MOVF       R0+0, 0
	MOVWF      _PressedKey+0
;MyProject1.c,174 :: 		while(pressedKey!=35 || i!=0){
L_main10:
	MOVF       _PressedKey+0, 0
	XORLW      35
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	MOVLW      0
	XORWF      _i+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main64
	MOVLW      0
	XORWF      _i+0, 0
L__main64:
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	GOTO       L_main11
L__main53:
;MyProject1.c,175 :: 		while (pressedKey==35 || pressedKey==58){
L_main14:
	MOVF       _PressedKey+0, 0
	XORLW      35
	BTFSC      STATUS+0, 2
	GOTO       L__main52
	MOVF       _PressedKey+0, 0
	XORLW      58
	BTFSC      STATUS+0, 2
	GOTO       L__main52
	GOTO       L_main15
L__main52:
;MyProject1.c,176 :: 		Lcd_Out(1,1,"Invalid Input");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,177 :: 		myDelay_ms(2000);
	MOVLW      208
	MOVWF      FARG_myDelay_ms_ms+0
	MOVLW      7
	MOVWF      FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,178 :: 		Lcd_Out(1,1,"Enter Nap time:");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,179 :: 		Lcd_Cmd(_LCD_SECOND_ROW);
	MOVLW      192
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,180 :: 		pressedKey =Scan_Keypad();
	CALL       _Scan_Keypad+0
	MOVF       R0+0, 0
	MOVWF      _PressedKey+0
;MyProject1.c,181 :: 		}
	GOTO       L_main14
L_main15:
;MyProject1.c,182 :: 		piezo_buzzer();
	CALL       _piezo_buzzer+0
;MyProject1.c,183 :: 		alarmTime[3-i]=pressedKey;
	MOVF       _i+0, 0
	SUBLW      3
	MOVWF      R3+0
	MOVF       _i+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	CLRF       R3+1
	SUBWF      R3+1, 1
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _alarmTime+0
	MOVWF      FSR
	MOVF       _PressedKey+0, 0
	MOVWF      INDF+0
	INCF       FSR, 1
	CLRF       INDF+0
;MyProject1.c,184 :: 		if(i==2)  Lcd_Chr(2,3,':');
	MOVLW      0
	XORWF      _i+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main65
	MOVLW      2
	XORWF      _i+0, 0
L__main65:
	BTFSS      STATUS+0, 2
	GOTO       L_main18
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
L_main18:
;MyProject1.c,185 :: 		if(i<2)   Lcd_Chr(2,i+1,pressedKey);
	MOVLW      128
	XORWF      _i+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main66
	MOVLW      2
	SUBWF      _i+0, 0
L__main66:
	BTFSC      STATUS+0, 0
	GOTO       L_main19
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	INCF       _i+0, 0
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _PressedKey+0, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
L_main19:
;MyProject1.c,186 :: 		if(i>=2)   Lcd_Chr(2,i+2,pressedKey);
	MOVLW      128
	XORWF      _i+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main67
	MOVLW      2
	SUBWF      _i+0, 0
L__main67:
	BTFSS      STATUS+0, 0
	GOTO       L_main20
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      2
	ADDWF      _i+0, 0
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _PressedKey+0, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
L_main20:
;MyProject1.c,187 :: 		i++;
	INCF       _i+0, 1
	BTFSC      STATUS+0, 2
	INCF       _i+1, 1
;MyProject1.c,188 :: 		i=i%4;
	MOVLW      4
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _i+0, 0
	MOVWF      R0+0
	MOVF       _i+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _i+0
	MOVF       R0+1, 0
	MOVWF      _i+1
;MyProject1.c,189 :: 		pressedKey= Scan_Keypad();
	CALL       _Scan_Keypad+0
	MOVF       R0+0, 0
	MOVWF      _PressedKey+0
;MyProject1.c,191 :: 		}
	GOTO       L_main10
L_main11:
;MyProject1.c,194 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,195 :: 		n=L*(alarmTime[0]%48+alarmTime[1]%48*10+alarmTime[2]%48*60+alarmTime[3]%48*600);
	MOVLW      48
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alarmTime+0, 0
	MOVWF      R0+0
	MOVF       _alarmTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      FLOC__main+0
	MOVF       R0+1, 0
	MOVWF      FLOC__main+1
	MOVLW      48
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alarmTime+2, 0
	MOVWF      R0+0
	MOVF       _alarmTime+3, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVF       R0+0, 0
	ADDWF      FLOC__main+0, 1
	MOVF       R0+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      FLOC__main+1, 1
	MOVLW      48
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alarmTime+4, 0
	MOVWF      R0+0
	MOVF       _alarmTime+5, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVF       R0+0, 0
	ADDWF      FLOC__main+0, 1
	MOVF       R0+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      FLOC__main+1, 1
	MOVLW      48
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alarmTime+6, 0
	MOVWF      R0+0
	MOVF       _alarmTime+7, 0
	MOVWF      R0+1
	CALL       _Div_16x16_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      88
	MOVWF      R4+0
	MOVLW      2
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVF       FLOC__main+0, 0
	ADDWF      R0+0, 1
	MOVF       FLOC__main+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVLW      0
	BTFSC      R0+1, 7
	MOVLW      255
	MOVWF      R0+2
	MOVWF      R0+3
	MOVF       _L+0, 0
	MOVWF      R4+0
	MOVF       _L+1, 0
	MOVWF      R4+1
	MOVF       _L+2, 0
	MOVWF      R4+2
	MOVF       _L+3, 0
	MOVWF      R4+3
	CALL       _Mul_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _n+0
	MOVF       R0+1, 0
	MOVWF      _n+1
	MOVF       R0+2, 0
	MOVWF      _n+2
	MOVF       R0+3, 0
	MOVWF      _n+3
;MyProject1.c,196 :: 		Lcd_Out(1,1,"Sweet Dreams");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,197 :: 		Lcd_Out(2,1,"Zzzzz..");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr5_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,198 :: 		myDelay_ms(n);
	MOVF       _n+0, 0
	MOVWF      FARG_myDelay_ms_ms+0
	MOVF       _n+1, 0
	MOVWF      FARG_myDelay_ms_ms+1
	MOVF       _n+2, 0
	MOVWF      FARG_myDelay_ms_ms+2
	MOVF       _n+3, 0
	MOVWF      FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,199 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,200 :: 		Lcd_Out(1,1,"ALARM ON!!!");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,201 :: 		CCP1CON = 0x0C;          //enable PWM for CCP1
	MOVLW      12
	MOVWF      CCP1CON+0
;MyProject1.c,202 :: 		CCP2CON = 0x0C;         //enable PWM for CCP2
	MOVLW      12
	MOVWF      CCP2CON+0
;MyProject1.c,203 :: 		PORTE=PORTE|0x03;        //Buzzers ON
	MOVLW      3
	IORWF      PORTE+0, 1
;MyProject1.c,204 :: 		CCPR1L= 125;              //RIGHT MOTOR
	MOVLW      125
	MOVWF      CCPR1L+0
;MyProject1.c,205 :: 		CCPR2L= 125;              //LEFT MOTOR
	MOVLW      125
	MOVWF      CCPR2L+0
;MyProject1.c,209 :: 		while(PORTE & 0x02){  //lights are off
L_main21:
	BTFSS      PORTE+0, 1
	GOTO       L_main22
;MyProject1.c,211 :: 		lightreading=ATD_read();
	CALL       _ATD_read+0
	MOVF       R0+0, 0
	MOVWF      _lightreading+0
	MOVF       R0+1, 0
	MOVWF      _lightreading+1
;MyProject1.c,212 :: 		light_to_volt=(lightreading*50)/1023;
	MOVLW      50
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _light_to_volt+0
	MOVF       R0+1, 0
	MOVWF      _light_to_volt+1
;MyProject1.c,213 :: 		myDelay_ms(500);
	MOVLW      244
	MOVWF      FARG_myDelay_ms_ms+0
	MOVLW      1
	MOVWF      FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,217 :: 		if(!(PORTA & 0x08) &&  !(PORTA & 0x04)){
	BTFSC      PORTA+0, 3
	GOTO       L_main25
	BTFSC      PORTA+0, 2
	GOTO       L_main25
L__main51:
;MyProject1.c,218 :: 		PORTC=0x30;
	MOVLW      48
	MOVWF      PORTC+0
;MyProject1.c,219 :: 		}
	GOTO       L_main26
L_main25:
;MyProject1.c,220 :: 		else if(PORTA & 0x08 &&  PORTA & 0x04){
	BTFSS      PORTA+0, 3
	GOTO       L_main29
	BTFSS      PORTA+0, 2
	GOTO       L_main29
L__main50:
;MyProject1.c,221 :: 		PORTC=0x48;
	MOVLW      72
	MOVWF      PORTC+0
;MyProject1.c,222 :: 		}
	GOTO       L_main30
L_main29:
;MyProject1.c,223 :: 		else if(PORTA & 0x08){
	BTFSS      PORTA+0, 3
	GOTO       L_main31
;MyProject1.c,224 :: 		PORTC=0x20;
	MOVLW      32
	MOVWF      PORTC+0
;MyProject1.c,226 :: 		}
	GOTO       L_main32
L_main31:
;MyProject1.c,227 :: 		else if(PORTA & 0x04){
	BTFSS      PORTA+0, 2
	GOTO       L_main33
;MyProject1.c,228 :: 		PORTC=0x10;
	MOVLW      16
	MOVWF      PORTC+0
;MyProject1.c,230 :: 		}
L_main33:
L_main32:
L_main30:
L_main26:
;MyProject1.c,232 :: 		if (light_to_volt >25){
	MOVF       _light_to_volt+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main68
	MOVF       _light_to_volt+0, 0
	SUBLW      25
L__main68:
	BTFSC      STATUS+0, 0
	GOTO       L_main34
;MyProject1.c,233 :: 		PORTE=PORTE&0xFD; //Light buzzer off
	MOVLW      253
	ANDWF      PORTE+0, 1
;MyProject1.c,234 :: 		Lcd_Out(2,1,"Lights ON!");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr7_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,235 :: 		}
L_main34:
;MyProject1.c,237 :: 		}
	GOTO       L_main21
L_main22:
;MyProject1.c,240 :: 		CCPR1L= 250;         //RIGHT MOTOR
	MOVLW      250
	MOVWF      CCPR1L+0
;MyProject1.c,241 :: 		CCPR2L= 250;          //LEFT MOTOR
	MOVLW      250
	MOVWF      CCPR2L+0
;MyProject1.c,243 :: 		while (!(PORTA &0x02)){      //push button is not pressed
L_main35:
	BTFSC      PORTA+0, 1
	GOTO       L_main36
;MyProject1.c,247 :: 		if(!(PORTA & 0x08) &&  !(PORTA & 0x04)){
	BTFSC      PORTA+0, 3
	GOTO       L_main39
	BTFSC      PORTA+0, 2
	GOTO       L_main39
L__main49:
;MyProject1.c,248 :: 		PORTC=0x30;
	MOVLW      48
	MOVWF      PORTC+0
;MyProject1.c,249 :: 		}
	GOTO       L_main40
L_main39:
;MyProject1.c,250 :: 		else if(PORTA & 0x08 &&  PORTA & 0x04){
	BTFSS      PORTA+0, 3
	GOTO       L_main43
	BTFSS      PORTA+0, 2
	GOTO       L_main43
L__main48:
;MyProject1.c,251 :: 		PORTC=0x48;
	MOVLW      72
	MOVWF      PORTC+0
;MyProject1.c,252 :: 		}
	GOTO       L_main44
L_main43:
;MyProject1.c,253 :: 		else if(PORTA & 0x08){
	BTFSS      PORTA+0, 3
	GOTO       L_main45
;MyProject1.c,254 :: 		PORTC=0x20;
	MOVLW      32
	MOVWF      PORTC+0
;MyProject1.c,256 :: 		}
	GOTO       L_main46
L_main45:
;MyProject1.c,257 :: 		else if(PORTA & 0x04){
	BTFSS      PORTA+0, 2
	GOTO       L_main47
;MyProject1.c,258 :: 		PORTC=0x10;
	MOVLW      16
	MOVWF      PORTC+0
;MyProject1.c,260 :: 		}
L_main47:
L_main46:
L_main44:
L_main40:
;MyProject1.c,262 :: 		}
	GOTO       L_main35
L_main36:
;MyProject1.c,265 :: 		PORTE=PORTE&0xFE;   //Turn Noise Buzzer off
	MOVLW      254
	ANDWF      PORTE+0, 1
;MyProject1.c,268 :: 		PORTC=0x00;
	CLRF       PORTC+0
;MyProject1.c,269 :: 		CCPR1L= 0;
	CLRF       CCPR1L+0
;MyProject1.c,270 :: 		CCPR2L= 0;
	CLRF       CCPR2L+0
;MyProject1.c,271 :: 		CCP1CON = 0x00;//disable PWM for CCP1
	CLRF       CCP1CON+0
;MyProject1.c,272 :: 		CCP2CON = 0x00;//disable PWM for CCP2
	CLRF       CCP2CON+0
;MyProject1.c,274 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,275 :: 		Lcd_Out(1,1,"GOOD MORNING!");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr8_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,276 :: 		myDelay_ms(2000);
	MOVLW      208
	MOVWF      FARG_myDelay_ms_ms+0
	MOVLW      7
	MOVWF      FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,277 :: 		Lcd_Out(2,1,"Happy Day!");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr9_MyProject1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject1.c,278 :: 		myDelay_ms(2000);
	MOVLW      208
	MOVWF      FARG_myDelay_ms_ms+0
	MOVLW      7
	MOVWF      FARG_myDelay_ms_ms+1
	CLRF       FARG_myDelay_ms_ms+2
	CLRF       FARG_myDelay_ms_ms+3
	CALL       _myDelay_ms+0
;MyProject1.c,279 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject1.c,280 :: 		}
	GOTO       L_main8
;MyProject1.c,282 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
