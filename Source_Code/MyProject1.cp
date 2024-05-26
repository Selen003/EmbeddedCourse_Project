#line 1 "E:/Program Files/mikroC PRO for PIC/Examples/Development Systems/EASYPIC7/MY_PROJECTS/MyProject1.c"

sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D4 at RB0_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;

sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;


char keypadPort at PORTD;
unsigned short kp=0;
unsigned long int DelayMsCNTR=0;


void CCPPWM_init(void){
 T2CON = 0x07;
 CCP1CON = 0x00;
 CCP2CON = 0x00;
 PR2 = 250;
 TRISC = 0x00;

}

void myDelay_ms(signed long int ms){
 TMR0=248;
 DelayMsCNTR=0;
 INTCON=INTCON|0x20;
 while(DelayMsCNTR<ms);
 INTCON=INTCON&0xDF;
 }

void piezo_buzzer(void){
 PORTE=PORTE|0x02;
 myDelay_ms(100);
 PORTE=PORTE&0xFD;
 myDelay_ms(100);

}

void ATD_init(void){
 ADCON0 = 0x41;
 ADCON1 = 0xCE;
 TRISA = 0xFF;

}
unsigned int ATD_read(void){
 ADCON0 = ADCON0 | 0x04;
 while(ADCON0 & 0x04);
 return((ADRESH<<8) | ADRESL);
}

unsigned char Scan_Keypad(void){
 kp=0;

 do

 kp = Keypad_Key_Click();
 while (!kp);
#line 85 "E:/Program Files/mikroC PRO for PIC/Examples/Development Systems/EASYPIC7/MY_PROJECTS/MyProject1.c"
 if (kp==15){
 return 35;
 }

 kp=(kp%14)+48-((kp%14)/4);
 return kp;
}

void interrupt(void){



 INTCON=INTCON&0xFB;

 DelayMsCNTR++;

 TMR0=248;




}


 unsigned char PressedKey;
 unsigned int lightreading;
 unsigned int light_to_volt;
 signed int currentTime[4];
 signed int alarmTime[4];
 signed int i=0,j=0;
 char txt[]="";
 signed long int n=0;
 signed long int L=1000;
void main() {


 INTCON=0xE0;
 OPTION_REG=0x07;


 TRISC=0x00;



 PORTC=0x00;

 TRISE=0x00;
 PORTE=0x00;


 Lcd_Init();
 Keypad_Init();
 ATD_init();
 CCPPWM_init();
#line 168 "E:/Program Files/mikroC PRO for PIC/Examples/Development Systems/EASYPIC7/MY_PROJECTS/MyProject1.c"
 while(1){
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1,1,"Enter Nap time:");
 Lcd_Cmd(_LCD_SECOND_ROW);
 i=0;
 pressedKey= Scan_Keypad();
 while(pressedKey!=35 || i!=0){
 while (pressedKey==35 || pressedKey==58){
 Lcd_Out(1,1,"Invalid Input");
 myDelay_ms(2000);
 Lcd_Out(1,1,"Enter Nap time:");
 Lcd_Cmd(_LCD_SECOND_ROW);
 pressedKey =Scan_Keypad();
 }
 piezo_buzzer();
 alarmTime[3-i]=pressedKey;
 if(i==2) Lcd_Chr(2,3,':');
 if(i<2) Lcd_Chr(2,i+1,pressedKey);
 if(i>=2) Lcd_Chr(2,i+2,pressedKey);
 i++;
 i=i%4;
 pressedKey= Scan_Keypad();

 }


 Lcd_Cmd(_LCD_CLEAR);
 n=L*(alarmTime[0]%48+alarmTime[1]%48*10+alarmTime[2]%48*60+alarmTime[3]%48*600);
 Lcd_Out(1,1,"Sweet Dreams");
 Lcd_Out(2,1,"Zzzzz..");
 myDelay_ms(n);
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1,1,"ALARM ON!!!");
 CCP1CON = 0x0C;
 CCP2CON = 0x0C;
 PORTE=PORTE|0x03;
 CCPR1L= 125;
 CCPR2L= 125;



 while(PORTE & 0x02){

 lightreading=ATD_read();
 light_to_volt=(lightreading*50)/1023;
 myDelay_ms(500);



 if(!(PORTA & 0x08) && !(PORTA & 0x04)){
 PORTC=0x30;
 }
 else if(PORTA & 0x08 && PORTA & 0x04){
 PORTC=0x48;
 }
 else if(PORTA & 0x08){
 PORTC=0x20;

 }
 else if(PORTA & 0x04){
 PORTC=0x10;

 }

 if (light_to_volt >25){
 PORTE=PORTE&0xFD;
 Lcd_Out(2,1,"Lights ON!");
 }

 }


 CCPR1L= 250;
 CCPR2L= 250;

 while (!(PORTA &0x02)){



 if(!(PORTA & 0x08) && !(PORTA & 0x04)){
 PORTC=0x30;
 }
 else if(PORTA & 0x08 && PORTA & 0x04){
 PORTC=0x48;
 }
 else if(PORTA & 0x08){
 PORTC=0x20;

 }
 else if(PORTA & 0x04){
 PORTC=0x10;

 }

 }


 PORTE=PORTE&0xFE;


 PORTC=0x00;
 CCPR1L= 0;
 CCPR2L= 0;
 CCP1CON = 0x00;
 CCP2CON = 0x00;

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1,1,"GOOD MORNING!");
 myDelay_ms(2000);
 Lcd_Out(2,1,"Happy Day!");
 myDelay_ms(2000);
 Lcd_Cmd(_LCD_CLEAR);
 }

}
