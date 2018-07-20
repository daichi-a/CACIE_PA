import oscP5.*;
import netP5.*;


int harmonyPitchDegreeToHeightArray[] = new int[29]; //3 octave
int melodyPitchDegreeToHeightArray[] = new int[29];
int harmonyNoteYOffset = 200;
int melodyNoteYOffset = 460;
int noteXOffset = 40;
int currentPlayingBoxYOffset = harmonyNoteYOffset + 20;
int currentPlayingBoxInEsXOffset = 80;
int currentPlayingBoxInBXOffset = 580;
int currentPlayingBoxWidth = 100;

PImage label_GCref, label_Sharp, label_Flat, label_C_Major;
PImage label_C_HarmonicMinor, label_C_WholeTone;
String currentScale = "C Major";

int temporarySharp[] = new int[29];
int temporaryFlat[] = new int[29];

int noteOffsetFlag[] = new int[29];

OscP5 oscP5_Score;
int currentPlayingPosition = 0;

int harmonyPitchDegreeInC[][] = new int[4][4];
int harmonyPitchDegreeInEs[][] = new int[4][4];
int harmonyPitchDegreeInB[][] = new int[4][4];

int harmonyNoteInEsXOffset = currentPlayingBoxInEsXOffset + (currentPlayingBoxWidth / 2);
int harmonyNoteInBXOffset = currentPlayingBoxInBXOffset + (currentPlayingBoxWidth / 2);

PFont font;
String scaleMode = "C Harmonic Minor";

void setup(){
  size(1000, 500);
  background(255);
  font = loadFont("Monaco-14.vlw");
  textFont(font, 14);
  
  for(int i=0; i<29; i++){
    harmonyPitchDegreeToHeightArray[i] = harmonyNoteYOffset - i * 10;
    melodyPitchDegreeToHeightArray[i] = melodyNoteYOffset - i * 10;
  }
  label_GCref = loadImage("Label_GCref.gif");
  label_Sharp = loadImage("Label_Sharp.gif");
  label_Flat = loadImage("Label_Flat.gif");
  
  for(int i=0; i<7; i++){
    for(int j=0; j<4; j++){
      temporarySharp[i*3+j] = 0;
      temporaryFlat[i*3+j] = 0;
    }
  }
  temporarySharp[28] = 0;
  temporarySharp[28] = 0;
  
  
  for(int i=0; i<4; i++){
   harmonyPitchDegreeInC[i][0] = 0;
   harmonyPitchDegreeInC[i][1] = 2;
   harmonyPitchDegreeInC[i][2] = 4;
   harmonyPitchDegreeInC[i][3] = 6; 
  }
  calcHarmonyPitchDegreeToDisplay();
  oscP5_Score = new OscP5(this, 12001);
  for(int i=0; i<28; i++)
    noteOffsetFlag[i] = 0;
    
  label_C_Major = loadImage("icon/Label_Scale_C_Major.png");
  label_C_HarmonicMinor = loadImage("icon/Label_Scale_C_HarmonicMinor.png");
  label_C_WholeTone = loadImage("icon/Label_Scale_C_WholeTone.png");
}

void draw(){
  background(255);
  drawGCrefAndSharp();
  drawCurrentPlayingBar();
  draw5Lines();
  drawWholeNote();
  drawLabels();
}

void drawLabels(){
  
    //Scale Mode
    //C Major
    if(scaleMode.equals("C Major"))
       fill(255, 255, 255); 
    else
      fill(20, 20, 20);
    rect(10, 270, 100, 60);
    image(label_C_Major, 10, 270, 100, 60);
    //scaleSelectButton[0][0] = 780; scaleSelectButton[0][1] = 270;
    //scaleSelectButton[0][2] = scaleSelectButton[0][0] + 100;
    //scaleSelectButton[0][3] = scaleSelectButton[0][1] + 60;
    
    if(scaleMode.equals("C Harmonic Minor"))
       fill(255, 255, 255); 
    else
      fill(20, 20, 20);
    rect(110, 270, 100, 60);
    image(label_C_HarmonicMinor, 110, 270, 100, 60);
    //scaleSelectButton[1][0] = 880; scaleSelectButton[1][1] = 270;
    //scaleSelectButton[1][2] = scaleSelectButton[1][0] + 100;
    //scaleSelectButton[1][3] = scaleSelectButton[1][1] + 60;
    
    if(scaleMode.equals("C WholeTone"))
       fill(255, 255, 255); 
    else
      fill(20, 20, 20);
    rect(210, 270, 100, 60);
    image(label_C_WholeTone, 210, 270, 100, 60);
    //scaleSelectButton[2][0] = 980; scaleSelectButton[2][1] = 270;
    //scaleSelectButton[2][2] = scaleSelectButton[2][0] + 100;
    //scaleSelectButton[2][3] = scaleSelectButton[2][1] + 60;  
}

void drawGCrefAndSharp(){
  image(label_GCref, -40, 63, 160, 160);
  image(label_GCref, 460, 63, 160, 160);


  if(currentScale.equals("C Major")){
    //In Es :
    image(label_Sharp, 50, harmonyPitchDegreeToHeightArray[11]-5, 30, 30);  
    image(label_Sharp, 60, harmonyPitchDegreeToHeightArray[8]-5, 30, 30); 
    image(label_Sharp, 70, harmonyPitchDegreeToHeightArray[12]-5, 30, 30);
    //In B
    image(label_Sharp, 550, harmonyPitchDegreeToHeightArray[11]-5, 30, 30);  
    image(label_Sharp, 560, harmonyPitchDegreeToHeightArray[8]-5, 30, 30); 

    //Temporary Sharp and Flat
    for(int i=0; i<23; i++){
      temporarySharp[i] = 0; temporaryFlat[i] = 0;
    }
  }
  else if(currentScale.equals("C Harmonic Minor")){
    //In Es :

    //In B
    image(label_Flat, 550, harmonyPitchDegreeToHeightArray[7]-5, 30, 30);
    
  //TemporarySharp And Flat
  for(int i=0; i<3; i++){
    for(int j=0; j<7; j++){
      if(j==4){
        temporarySharp[i*7+j] = 1;
          temporaryFlat[i*7+j] = 0;
      }
      else{
         temporarySharp[i*7+j] = 0;
          temporaryFlat[i*7+j] = 0;
      }
     }
   }
   temporarySharp[22] = 0;
   temporaryFlat[22] = 0;
  }
  else if(currentScale.equals("C WholeTone")){
   //In Es la si do# re# fa so la
  for(int i=0; i<3; i++)
    for(int j=0; j<7; j++)
      if(j==0 || j==1)
        temporarySharp[i*7+j] = 1;
      else
        temporarySharp[i*7+j] = 0;
  
    //In B  re mi fa# so# ra# do re
    for(int i=0; i<3; i++)
      for(int j=0; j<7; j++)
        if(j==3 || j==4 || j==5)
          temporarySharp[i*7+j] = 1;
        else
          temporarySharp[i*7+j] = 0;
    
  }


}

void drawCurrentPlayingBar(){
  colorMode(RGB);
  
  stroke(100,100,100);
  fill(0,0,0);
  strokeWeight(2);
  //In Es
  line(currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    10, 
    currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    currentPlayingBoxYOffset);
  line(currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    currentPlayingBoxYOffset,
    currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1), 
    currentPlayingBoxYOffset);
  line(currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1), 
    currentPlayingBoxYOffset,
    currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1),
    10);
  line(currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1),
    10,
    currentPlayingBoxInEsXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    10);
    
  
  
  //In B
    line(currentPlayingBoxInBXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    10, 
    currentPlayingBoxInBXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    currentPlayingBoxYOffset);
  line(currentPlayingBoxInBXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    currentPlayingBoxYOffset,
    currentPlayingBoxInBXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1), 
    currentPlayingBoxYOffset);
  line(currentPlayingBoxInBXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1), 
    currentPlayingBoxYOffset,
    currentPlayingBoxInBXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1),
    10);
  line(currentPlayingBoxInBXOffset + currentPlayingBoxWidth * (currentPlayingPosition+1),
    10,
    currentPlayingBoxInBXOffset + currentPlayingBoxWidth * currentPlayingPosition, 
    10);
}

void draw5Lines(){
  colorMode(RGB);
  color(0, 0, 0);
  stroke(0);
  strokeWeight(3);
  
  //Harmony
  //In Es
  line(10, 100, 490, 100);
  line(10, 120, 490, 120);
  line(10, 140, 490, 140);
  line(10, 160, 490, 160);
  line(10, 180, 490, 180); 

  //In B
  line(510, 100, 990, 100);
  line(510, 120, 990, 120);
  line(510, 140, 990, 140);
  line(510, 160, 990, 160);
  line(510, 180, 990, 180); 

  //Melody A In C
  line(5, 360, 245, 360);
  line(5, 380, 245, 380);
  line(5, 400, 245, 400);
  line(5, 420, 245, 420);
  line(5, 440, 245, 440); 
  
  //Melody B In C
  line(255, 360, 495, 360);
  line(255, 380, 495, 380);
  line(255, 400, 495, 400);
  line(255, 420, 495, 420);
  line(255, 440, 495, 440); 
  
  //Arpeggio
  line(505, 360, 745, 360);
  line(505, 380, 745, 380);
  line(505, 400, 745, 400);
  line(505, 420, 745, 420);
  line(505, 440, 745, 440); 
  
  //Bass
  line(750, 360, 995, 360);
  line(750, 380, 995, 380);
  line(750, 400, 995, 400);
  line(750, 420, 995, 420);
  line(750, 440, 995, 440); 

  
}

void drawWholeNote(){
  //harmonyPitchDegreeInEs[4][4], harmonyPitchDegreeInB[4][4]
  //harmonyNoteInEsXOffset, harmonyNoteInBXOffset
  //harmonyPitchDegreeToHeight[23]
  //temporarySharp[23], temporaryFlat[23];

  stroke(100,100,100);
  fill(255,255,255);
  strokeWeight(2);
  ellipseMode(CENTER);
  for(int i=0; i<4; i++){
    for(int t=0; t<29; t++)
      noteOffsetFlag[t] = 0;
      
    for(int j=0; j<4; j++){
      stroke(100, 100, 100);
      strokeWeight(2);
      
      
      //Note x offset for neighbor note
      int noteXOffset = 0;
      if(j!=0){
        for(int p=0; p<4; p++){
          if(harmonyPitchDegreeInEs[i][p] -1 == harmonyPitchDegreeInEs[i][j]){
            noteXOffset = 20;
            noteOffsetFlag[j] = 1;
            break;
          }
        }
      }
      
      //in Es 
      ellipse(harmonyNoteInEsXOffset + i * currentPlayingBoxWidth + noteXOffset,
       harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInEs[i][j]],
        20, 20);
      //Temporary Sharp and Flat
      if(temporarySharp[harmonyPitchDegreeInEs[i][j]] == 1){
        image(label_Sharp, 
        harmonyNoteInEsXOffset + i * currentPlayingBoxWidth - 40, 
        harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInEs[i][j]]-15, 
        30, 30);
      }
      if(temporaryFlat[harmonyPitchDegreeInEs[i][j]] == 1){
        image(label_Flat, 
        harmonyNoteInEsXOffset + i * currentPlayingBoxWidth - 40,
        harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInEs[i][j]]-15, 
        30, 30);        
      }

      //in B
      ellipse(harmonyNoteInBXOffset + i * currentPlayingBoxWidth+noteXOffset,
        harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInB[i][j]],
        20, 20);
      //Temporary Sharp and Flat
      if(temporarySharp[harmonyPitchDegreeInB[i][j]] == 1){
        image(label_Sharp, 
        harmonyNoteInBXOffset + i * currentPlayingBoxWidth - 40,
        harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInB[i][j]]-15, 
        30, 30);
      }
      if(temporaryFlat[harmonyPitchDegreeInB[i][j]] == 1){
        image(label_Flat, 
        harmonyNoteInBXOffset + i * currentPlayingBoxWidth - 40,
        harmonyPitchDegreeToHeightArray[harmonyPitchDegreeInB[i][j]]-15, 
        30, 30);        
      }
      
      //Under or Upper 5lines, adding support line for note
      //Es
      if(harmonyPitchDegreeInEs[i][j] <= 0 || 
          harmonyPitchDegreeInEs[i][j] >= 12){
         stroke(100, 100, 100);
         strokeWeight(1);         
         if(harmonyPitchDegreeInEs[i][j] == 0){
            // Under 5Line Case
           line(harmonyNoteInEsXOffset + i * currentPlayingBoxWidth+noteXOffset -10,
             harmonyPitchDegreeToHeightArray[0],
             harmonyNoteInEsXOffset+ i * currentPlayingBoxWidth+noteXOffset + 30,
             harmonyPitchDegreeToHeightArray[0]);
         }
         else{
            // Upper 5Line Case
            for(int p=12; p<=harmonyPitchDegreeInEs[i][j]; p++){
               if(p % 2 == 0){
                 line(harmonyNoteInEsXOffset + i * currentPlayingBoxWidth -10,
                 harmonyPitchDegreeToHeightArray[p],
                 harmonyNoteInEsXOffset+ i * currentPlayingBoxWidth + 30,
                 harmonyPitchDegreeToHeightArray[p]);
               }
            }
         }
        }
        //B
        if(harmonyPitchDegreeInB[i][j] <= 0 || 
          harmonyPitchDegreeInB[i][j] >= 12){
          stroke(100, 100, 100);
          strokeWeight(1);         
          if(harmonyPitchDegreeInB[i][j] == 0){
            // Under 5Line Case
           line(harmonyNoteInBXOffset + i * currentPlayingBoxWidth+noteXOffset -10,
             harmonyPitchDegreeToHeightArray[0],
             harmonyNoteInBXOffset+ i * currentPlayingBoxWidth+noteXOffset + 30,
             harmonyPitchDegreeToHeightArray[0]);
           }
           else{
            // Upper 5Line Case
            for(int p=12; p<=harmonyPitchDegreeInB[i][j]; p++){
               if(p % 2 == 0){
                 line(harmonyNoteInBXOffset + i * currentPlayingBoxWidth -10,
                 harmonyPitchDegreeToHeightArray[p],
                 harmonyNoteInBXOffset+ i * currentPlayingBoxWidth + 30,
                 harmonyPitchDegreeToHeightArray[p]);
               }
            }
           }
         }
      }
    }
}

void calcHarmonyPitchDegreeToDisplay(){
  //Change PitchDegree to in Es and B
  for(int i=0; i<4; i++){
    for(int j=0; j<4; j++){
      harmonyPitchDegreeInEs[i][j] = harmonyPitchDegreeInC[i][j] +5;
      if(harmonyPitchDegreeInEs[i][j] > 15)
        harmonyPitchDegreeInEs[i][j] %= 14;
      harmonyPitchDegreeInB[i][j] = harmonyPitchDegreeInC[i][j] + 1;
      if(harmonyPitchDegreeInB[i][j] > 15)
        harmonyPitchDegreeInB[i][j] %= 14;
    }
  }
  /*
  if(scaleMode.equals("C WholeTone")){
    //convert wholetone degree to normal diatonic scale 
    for(int i=0; i<4; i++){
      for(int j=0; j<4; j++){
        //in Es la si do# re# fa so la
        if(harmonyPitchDegreeInEs[i][j] >= 4 && 
          harmonyPitchDegreeInEs[i][j] < 10)
            harmonyPitchDegreeInEs[i][j] += 1;
        else if(harmonyPitchDegreeInEs[i][j] >= 10)
          harmonyPitchDegreeInEs[i][j] += 2;
         
        //in B re mi fa# so# ra# do re
        if(harmonyPitchDegreeInB[i][j]  >= 5 &&
          harmonyPitchDegreeInB[i][j] < 11)
            harmonyPitchDegreeInB[i][j] += 1;
        else if(harmonyPitchDegreeInB[i][j] >= 11)
          harmonyPitchDegreeInB[i][j] += 2;
        
      }
    }   
  }*/
}

void oscEvent(OscMessage oscMessage){
  if(oscMessage.checkAddrPattern("/CACIE_PA/GUI/harmonyInformation") == true){
    //System.err.print("harmonyInformation:");
    println(" typetag: "+ oscMessage.typetag().trim().substring(0,1));
    String typetag = oscMessage.typetag().trim();  
    
    int changeBar = (int)oscMessage.get(0).intValue();
    if(typetag.substring(1,2).equals("i"))
      harmonyPitchDegreeInC[changeBar][0] = (int)oscMessage.get(1).intValue();
    else
      harmonyPitchDegreeInC[changeBar][0] = (int)oscMessage.get(1).floatValue();

    if(typetag.substring(2,3).equals("i"))
      harmonyPitchDegreeInC[changeBar][1] = (int)oscMessage.get(2).intValue();
    else
      harmonyPitchDegreeInC[changeBar][1] = (int)oscMessage.get(2).floatValue();

    if(typetag.substring(3,4).equals("i"))
      harmonyPitchDegreeInC[changeBar][2] = (int)oscMessage.get(3).intValue();
    else
      harmonyPitchDegreeInC[changeBar][2] = (int)oscMessage.get(3).floatValue();

    if(typetag.substring(4,5).equals("i"))
      harmonyPitchDegreeInC[changeBar][3] = (int)oscMessage.get(4).intValue();
    else
      harmonyPitchDegreeInC[changeBar][3] = (int)oscMessage.get(4).floatValue();
 
    calcHarmonyPitchDegreeToDisplay();
  }
  else if(oscMessage.checkAddrPattern("/CACIE_PA/GUI/scaleInfomation") == true){
   currentScale = (String)oscMessage.get(0).toString(); 
  }
  else if(oscMessage.checkAddrPattern("/CACIE_PA/GUI/melodies") == true){

  }
  else if(oscMessage.checkAddrPattern("/CACIE_PA/GUI/currentPlayingPosition")
    == true){
       currentPlayingPosition = (int)oscMessage.get(0).floatValue();
  }
  else if(oscMessage.checkAddrPattern("/CACIE_PA/GUI/changeScale") == true){
    int changingScale = (int)oscMessage.get(0).intValue();
    if(changingScale == 0)
      currentScale = "C Major";
    else if(changingScale == 1)
      currentScale = "C Harmonic Minor";
    else if(changingScale == 2)
      currentScale = "C WholeTone";
    scaleMode = currentScale.trim();
    System.err.println(currentScale);
  }
  else{
    println("Worng type of OSC message comes: " + 
       oscMessage.addrPattern());
  }
}
