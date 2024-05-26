// Lcd module connections
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
// End Lcd module connections

char keypadPort at PORTD;
unsigned short kp=0;
unsigned long int DelayMsCNTR=0;
//unsigned char mysevenseg[10]={0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F};

void CCPPWM_init(void){ //Configure CCP1 and CCP2 at 2ms period with 50% duty cycle
  T2CON = 0x07;//enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount 2000uS to count 250 counts)
  CCP1CON = 0x00;//enable PWM for CCP1
  CCP2CON = 0x00;//enable PWM for CCP2
  PR2 = 250;// 250 counts =8uS *250 =2ms period
  TRISC = 0x00;

}

void myDelay_ms(signed long int ms){
      TMR0=248;
      DelayMsCNTR=0;
      INTCON=INTCON|0x20;   //Enable TMR0 overflow interrupt
      while(DelayMsCNTR<ms);         //keeps interrupting
      INTCON=INTCON&0xDF;   //Disable TMR0 overflow interrupt
 }

void piezo_buzzer(void){
        PORTE=PORTE|0x02;
        myDelay_ms(100);
        PORTE=PORTE&0xFD;
        myDelay_ms(100);

}

void ATD_init(void){
 ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
 ADCON1 = 0xCE;// All channels Analog, 500 KHz, right justified  XXXXX
 TRISA = 0xFF;

}
unsigned int ATD_read(void){
  ADCON0 = ADCON0 | 0x04;// GO
  while(ADCON0 & 0x04);
  return((ADRESH<<8) | ADRESL);
}

unsigned char Scan_Keypad(void){
    kp=0;  // Reset key code variable
    // Wait for key to be pressed and released
    do
      // kp = Keypad_Key_Press();          // Store key code in kp variable
      kp = Keypad_Key_Click();             // Store key code in kp variable
    while (!kp);
   // Prepare value for output, transform key to it's ASCII value
    /*switch (kp) {
      case  1: kp = 49; break; // 1
      case  2: kp = 50; break; // 2
      case  3: kp = 51; break; // 3

      case  5: kp = 52; break; // 4
      case  6: kp = 53; break; // 5
      case  7: kp = 54; break; // 6

      case  9: kp = 55; break; // 7
      case 10: kp = 56; break; // 8
      case 11: kp = 57; break; // 9

      case 13: kp = 42; break; // *       --> invlaid input when setting the time
      case 14: kp = 48; break; // 0
      case 15: kp = 35; break; // #       --> will be used as enter

    }*/
    if (kp==15){     //case '#' can't be handeled using the equation
     return 35;
    }

    kp=(kp%14)+48-((kp%14)/4);
    return kp;
}

void interrupt(void){

      //if(INTCON&0x04){
        //TMR0 overflag Flag Interrupt
          INTCON=INTCON&0xFB;
          //overflow every 1ms
          DelayMsCNTR++;      
          //Turn Flag Down
          TMR0=248;


      

}

//variables
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

     //Registers                                                                                                           g
     INTCON=0xE0;        //Global Interrupt, periphral inrterrupt, TMR0 overflow interrupt enabled
     OPTION_REG=0x07;     //Prescalar set to 1:256

     // Initialize ports
     TRISC=0x00; //RC1-RC6 Motors --> output
     //[C1,Left motor enable](pwm)         [C2,Right motor enable](pwm)
     //C3 C4
     //C5 C6
     PORTC=0x00;  //initialize all pins low

    TRISE=0x00;  //Port E output -->Buzzer E0,E1
    PORTE=0x00;  //initialize all pins low


    Lcd_Init();                        //Initialize   Lcd on Port B
    Keypad_Init();                        // Initialize Keypad to port D
    ATD_init();                           // Initialize Port A where A0 is Analog, others digital  ALL PINS INPUTS
    CCPPWM_init();                         //PWM
     //C2 RIGHT MOTOR
     //C1 LEFT MOTOR
    
    /*Lcd_Out(1,1,"Set Current Time:");
    Lcd_Cmd(_LCD_SECOND_ROW);
    j=0;
    pressedKey= Scan_Keypad();
    while(pressedKey!=35 || j!=0){
         while (pressedKey==35 || pressedKey==42){
                    Lcd_Out(1,1,"Invalid Input");
                    myDelay_ms(2000);
                    Lcd_Out(1,1,"Set Current Time:");
                    Lcd_Cmd(_LCD_SECOND_ROW);
                    pressedKey =Scan_Keypad();
                }
         piezo_buzzer();
         alarmTime[3-j]=pressedKey;
         if(j==2)  Lcd_Chr(2,3,':');
         if(j<2)   Lcd_Chr(2,j+1,pressedKey);
         if(j>=2)   Lcd_Chr(2,j+2,pressedKey);
         j++;
         j=j%4;
         pressedKey= Scan_Keypad();
    }

    n=currentTime[0]%48+currentTime[1]%48*10+currentTime[2]%48*100+currentTime[3]%48*1000;
    */
    
    //infinite loop
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
         if(i==2)  Lcd_Chr(2,3,':');
         if(i<2)   Lcd_Chr(2,i+1,pressedKey);
         if(i>=2)   Lcd_Chr(2,i+2,pressedKey);
         i++;
         i=i%4;
         pressedKey= Scan_Keypad();
         //Lcd_Chr_Cp(pressedKey);
    }


    Lcd_Cmd(_LCD_CLEAR);
    n=L*(alarmTime[0]%48+alarmTime[1]%48*10+alarmTime[2]%48*60+alarmTime[3]%48*600);
    Lcd_Out(1,1,"Sweet Dreams");
    Lcd_Out(2,1,"Zzzzz..");
    myDelay_ms(n);
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1,1,"ALARM ON!!!");
    CCP1CON = 0x0C;          //enable PWM for CCP1
    CCP2CON = 0x0C;         //enable PWM for CCP2
    PORTE=PORTE|0x03;        //Buzzers ON
    CCPR1L= 125;              //RIGHT MOTOR
    CCPR2L= 125;              //LEFT MOTOR



    while(PORTE & 0x02){  //lights are off
                //read light intensity
                lightreading=ATD_read();
                light_to_volt=(lightreading*50)/1023;
                myDelay_ms(500);
                
                //Motors ON, Starts moving
                //avoiding obstacles
                if(!(PORTA & 0x08) &&  !(PORTA & 0x04)){
                    PORTC=0x30;
                }
                else if(PORTA & 0x08 &&  PORTA & 0x04){
                         PORTC=0x48;
                }
                else if(PORTA & 0x08){
                  PORTC=0x20;

                }
                else if(PORTA & 0x04){
                  PORTC=0x10;

                }
                
                if (light_to_volt >25){
                   PORTE=PORTE&0xFD; //Light buzzer off
                   Lcd_Out(2,1,"Lights ON!");
                }
                
        }

    //increase speed
    CCPR1L= 250;         //RIGHT MOTOR
    CCPR2L= 250;          //LEFT MOTOR
  
    while (!(PORTA &0x02)){      //push button is not pressed


                   //avoiding obstacles
                if(!(PORTA & 0x08) &&  !(PORTA & 0x04)){
                    PORTC=0x30;
                }
                else if(PORTA & 0x08 &&  PORTA & 0x04){
                         PORTC=0x48;
                }
                else if(PORTA & 0x08){
                  PORTC=0x20;

                }
                else if(PORTA & 0x04){
                  PORTC=0x10;

                }

        }


    PORTE=PORTE&0xFE;   //Turn Noise Buzzer off
   //Turn Motors off

    PORTC=0x00;
    CCPR1L= 0;
    CCPR2L= 0;
    CCP1CON = 0x00;//disable PWM for CCP1
    CCP2CON = 0x00;//disable PWM for CCP2

    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1,1,"GOOD MORNING!");
    myDelay_ms(2000);
    Lcd_Out(2,1,"Happy Day!");
    myDelay_ms(2000);
    Lcd_Cmd(_LCD_CLEAR);
    }

}