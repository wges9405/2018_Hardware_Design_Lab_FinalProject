// example: DIY_LAB_360 Degree Servo Control test2.ino 利用數字鍵控制360度連續旋轉舵機正反轉及轉速(利用函式庫計算脈寬)
// Copyright © 2016 DIY_LAB All rights reserved

/*---------------- The following edited by DIY_LAB --------------

//• 360度連續旋轉舵機的控制說明：

   本舵機和一般舵機的控制大同小異，差別在一般舵機是利用PWM脈衝寬度來控制旋轉角度，
   而此360度連續旋轉舵機則是利用PWM脈衝寬度來控制正反轉、轉速和停止，詳細說明如下：

   輸入50Hz(週期20ms)方波信號，然後控制信號週期的高電位脈衝寬度時間(占空比duty cycle)，就可以控制速度、正反轉和停止。
   脈衝高電位持續時間(占空比duty cycle)對應轉速如下：
   1) 高電位在 1.0〜1.5 ms，舵機正轉（脈衝寬度在1ms時正轉速最快，越接近1.5ms越慢，在1.5ms時舵機停止）
   2) 高電位在 1.5〜2.0 ms，舵機反轉（脈衝寬度在2ms時反轉速最快，越接近1.5ms越慢，在1.5ms時舵機停止)

   本舵機具有可調電位器（需要打開外殼）可做歸零調整，調整時先設定好一個1.5ms寬的高電位脈衝給舵機，觀察它是否正常停止。
   若不是，請調節電位器，直到舵機停止為止。

   
//•實驗說明：
   請下載 DIY_LAB_360 Degree Servo Control test2.ino 範例程式，編譯完後,按upload進行上傳即可。
   按serial monitor進行觀察時，monitor右下角要設成 9600 baud，否則可能會出現亂碼。
   
   在serial monitor上方輸入數字1~9 將可看到舵機正反轉及轉速變化，對應轉速表如下：
   輸入(1~9)：1(正轉最快)~2(正轉)~3(正轉)~4(正轉最慢)~5(停)~6(反轉最慢)~7(反轉)~8(反轉)~9(反轉最快)
   
   *注意：
   1) 本範例是利用函式庫來計算脈寬，將存在著些許誤差，若輸入數字 5 舵機未完全停止而仍有微微振動或轉動，
   此乃脈寬誤差所致，可利用舵機內部電位器（需要打開外殼）做歸零調整。
   2) 本範例輸入數字1-9所對應正反轉速脈寬是依比例計算，有些段位轉速可能不明顯，請自行修正程式來改善。

   
//•模組引腳連接如下：
  【360度舵機】   與      【Arduino UNO R3】
      綜線       <-->        GND
      紅線       <-->        +5V (建議接外部電源)
      黃線       <-->        P9

	  
  *注意：
   360度舵機 建議用外接電源(電壓:5V 電流:1A)，因 Arduino 系統的供電能力有限，
   在舵機負載大或堵轉時(需要較大扭力)舵機電流會忽然增大常常超過Arduino能提供的最大電流。

----------------------------------------------------------------*/

#include <Servo.h> 
Servo myservo;            // 建立伺服機物件(用來控制伺服機,最多可建立8個)
int myNum;                // 輸入(1~9); 1(正轉最快)~2(正轉)~3(正轉)~4(正轉最慢)~5(停)~6(反轉最慢)~7(反轉)~8(反轉)~9(反轉最快) 
int pos;                  // 用來存伺服機位置的變數 
 
void setup() { 
    myservo.attach(9);    // 定義舵機介面（Pin9、10 均可，最多只能控制2組舵機）
    Serial.begin(9600);   // 連接到串行端口，鮑率為9600
    Serial.println("=== 360 Degree Servo Control test2 by DIY_LAB ===" ) ;
	
    myNum=5;              // 初始化=1.5ms,即一開始讓舵機停止
    setServo();           // 設定舵機轉速stop
} 
 
 
void loop() {
  // 讀取鍵盤輸入0~9字元當作正反轉速控制
  if (Serial.available() ) {
    myNum=Serial.read();                 // 讀取串行端口的值(由鍵盤輸入1~9並按enter鍵)
    if(myNum>'0'&& myNum<='9'){
      myNum=myNum-'0';                   // 將ASCII code轉化為數值(1-9)
      setServo();                        // 設定舵機正反轉轉速(將數值1-9轉為輸出脈寬1ms~2ms)
    }
  } 
}


void setServo() {
      pos = map(myNum, 1, 9,50, 150);      // 數字1-9 對映到 50(1ms)~100(1.5ms)~150(2ms),若有些段位轉速不明顯，請自行修正參數來改善。
	  myservo.write(pos);                  // 依照pos變數值,使Pin9輸出脈寬=1ms~2ms 
      Serial.print("#"); 
      Serial.print(myNum);                 // 印出按下哪個數字
      Serial.print("  pos : "); 
      Serial.print( pos,DEC); 
      Serial.print("  pulseWidth : "); 
      Serial.print( 1000+(pos-50)*10,DEC); // 印出脈寬
      Serial.println("us");
}