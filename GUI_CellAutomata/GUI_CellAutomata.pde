import oscP5.*;
import netP5.*;


int numberOfPhoto = 32;
PImage[] photoImages = new PImage[numberOfPhoto];
PImage button_NextPage, button_InitGPEngine, button_InitPop, button_Reproduction, button_InitSounds, button_PlayStop;
PImage label_Harmony, label_Percussion, label_Melodies, label_Parents, label_Offspring, label_Storage;
PImage keyBoard1, keyBoard2, keyBoard3, timpani, snareDrum, cowbell, e_bass;
int[][] photoSizes = new int[numberOfPhoto][2];
int currentDisplayPage = 0; //0 or 1
int currentPlayingPosition = 0;
int[][] chromosomeArea = new int[34][4];
color[] chromosomeAreaColor = new color[34];
boolean[] chromosomeAreaHasChromosome = new boolean[34];
int onMouseBox = -1;
int draggingChromosome = -1;
color draggingChromosomeColor;
int[][] distanceFromReleasePointToTargetBox = new int[15][2];

int targetChromosomeAreaOfDrag = -1;
int releaseTimeCounter = 0;

int cellAutomataSize = 64;
int cellAutomata[][];
String[] cellAutomataStateStringArray = new String[cellAutomataSize];

float[][] analizedPhotoData = new float[6][numberOfPhoto/2];
//rPerc0, rPerc1, gPerc0, gPerc2, bPerc0, bPerc1

OscP5 oscP5;
NetAddress gpEngineAddr;
NetAddress soundEngineAddr;

int[] nextPageButton = new int[4];
int[] initSoundEngineButton = new int[4];
int[] initChildrenButton = new int[4];
int[] reproductButton = new int[4];
int[] initGPButton = new int[4];
int[] playSoundButton = new int[4];

int appliedChromosomeAsRule = -1;

//ForTest
int drawTimeCounter = 0;

void setup(){

    size(1100, 600, P2D);
    background(255);
    colorMode(RGB, 256);
    noStroke();
    frameRate(10);
    loadImages();
    
    
    imageMode(CORNER);
    makeChromosomeArea();
    
    cellAutomata = new int[cellAutomataSize][cellAutomataSize];
    for(int i=0; i<cellAutomataSize; i++){
      String currentString = 
        new String("0101101010101010100101001001010100101010101001101001010110110101");      
      cellAutomataStateStringArray[i] = currentString;
    }
    
    oscP5 = new OscP5(this, 12000);
    gpEngineAddr = new NetAddress("localhost", 57120);
    soundEngineAddr = new NetAddress("localhost", 57120);
    initGPEngine();
    
}

void draw(){
    background(255);
    drawFrame();
    drawCellAutomata();
    drawChromosomeFrame();
    drawControlButton();
    drawLabel();
    drawMovingBox();
 }


void drawFrame(){
    //Control Space
    fill(30, 50, 80);
    rect(430, 0, 670, 600);
    //PhotoSpace
    fill(0,0,0);
    rect(0,0, 430, 600);
}

void drawCellAutomata(){
 fill(30, 30, 30);
 rect(0, 0, 512, 512);

  for(int column=0; column<cellAutomataSize; column++){
    String stateString = cellAutomataStateStringArray[column];
    for(int i=0; i<cellAutomataSize; i++){
        cellAutomata[column][i] = 
            Integer.parseInt(String.valueOf(stateString.charAt(i)));
      }
  }

 int cellUnitSize = 512 / cellAutomataSize;
 int xoffset = 0, yoffset = 0;

 for(int i=0; i<cellAutomataSize; i++){
   for(int j=0; j<cellAutomataSize; j++){

     if(cellAutomata[i][j] == 1)
       fill(255,255,255);
     else
       fill(0, 0, 0);
     rect(xoffset, yoffset, cellUnitSize, cellUnitSize);     
     xoffset += cellUnitSize;
   }
   xoffset = 0;
   yoffset += cellUnitSize;
 }
}

void drawChromosomeFrame(){
  //Gray Frame
  fill(127, 127, 127);
    for(int i=0; i<34; i++)
      rect(chromosomeArea[i][0], chromosomeArea[i][1], 60, 60);
    
    colorMode(HSB, 255);
    //Colored Chromosome if the frame has chromosome
    for(int i=0; i<34; i++)
	drawOneBox(chromosomeArea[i][0], chromosomeArea[i][1], i);
    colorMode(RGB, 255);
    
    tint(100,100,100, 127);
    image(snareDrum, chromosomeArea[4][0], chromosomeArea[4][1], 60, 60);
    image(timpani, chromosomeArea[5][0], chromosomeArea[5][1], 60, 60);
    image(cowbell, chromosomeArea[6][0], chromosomeArea[6][1], 60, 60);
    image(cowbell, chromosomeArea[7][0], chromosomeArea[7][1], 60, 60);
    
    image(keyBoard1, chromosomeArea[8][0], chromosomeArea[8][1], 60, 60);
    image(keyBoard3, chromosomeArea[9][0], chromosomeArea[9][1], 60, 60);
    image(keyBoard2, chromosomeArea[10][0], chromosomeArea[10][1], 60, 60);
    image(e_bass, chromosomeArea[11][0], chromosomeArea[11][1], 60, 60);
    noTint();
}

void drawOneBox(int xPos, int yPos, int boxIndex){

  if(chromosomeAreaHasChromosome[boxIndex]){
    int colorOffset = 0;
    if(onMouseBox == boxIndex)
	colorOffset = 30;
    fill(red(chromosomeAreaColor[boxIndex]) + colorOffset,
	 green(chromosomeAreaColor[boxIndex]) + colorOffset,
	 blue(chromosomeAreaColor[boxIndex]) + colorOffset);
    rect(xPos, yPos, 60, 60);
  }
}

void drawPlayingPosition(){
    fill(255, 255, 255);
    rect(0, (currentPlayingPosition * 150), 430, 150);
    
    //For Test
    /*
    drawTimeCounter++;
    if(drawTimeCounter >= 15){
	currentPlayingPosition++;
	if(currentPlayingPosition >= 4)
	    currentPlayingPosition = 0;
	drawTimeCounter = 0;
    }
    */

}

void drawPhotos(){
    imageMode(CORNER);
    for(int i=0; i<4; i++){//y axis
	for(int j=0; j<2; j++){//x axis
	    int currentPhotoIndex = currentDisplayPage * 8 + i * 2 + j;
	    //System.err.println(currentPhotoIndex);
	    float magnifyingPower = (float)200 /
		(float)photoSizes[currentPhotoIndex][0]; 
	    //200 : max width of the photo in the GUI
	    //150 : max height of the photo in the GUI
	    
	    image(photoImages[currentPhotoIndex], 
		  j*210 + 10 , i*150, 
		  (int)
		  (photoImages[currentPhotoIndex].width * magnifyingPower), 
	    	  (int)
		  (photoImages[currentPhotoIndex].height * magnifyingPower));
	}
    }
}

void drawControlButton(){
    //Next Page Button
    //fill(0, 0, 0);
    //rect(440, 550, 100, 30); //(440, 10) to (790, 40)    
    int offsetX = 480;
    int offsetY = 550;
    
    fill(100, 100, 0);
    rect(offsetX+0, offsetY, 100, 30);
    image(button_NextPage,offsetX+0, offsetY, 100, 30);
    nextPageButton[0] = offsetX+0; nextPageButton[1] = offsetY;
    nextPageButton[2] = nextPageButton[0] + 100; 
    nextPageButton[3] = nextPageButton[1] + 30;

    //Generate Initial Generation
    fill(0, 100, 100);
    rect(offsetX+120, offsetY, 100, 30);
    image(button_InitPop, offsetX+120, offsetY, 100, 30);
    initChildrenButton[0] = offsetX+110; initChildrenButton[1] = offsetY;
    initChildrenButton[2] = initChildrenButton[0] + 100;
    initChildrenButton[3] = initChildrenButton[1] + 30;

    //Initial GP Button
    fill(100, 0, 0);
    rect(offsetX+240, offsetY, 100, 30);
    image(button_InitGPEngine, offsetX+240, offsetY, 100, 30);
    initGPButton[0] = offsetX+220; initGPButton[1] = offsetY;
    initGPButton[2] = initGPButton[0] + 100;
    initGPButton[3] = initGPButton[1] + 30;

  //Init SoundEngine
  fill(0, 100, 0);
  rect(offsetX+360, offsetY, 100, 30);
  image(button_InitSounds, offsetX+360, offsetY, 100, 30);
  initSoundEngineButton[0] = offsetX+330; initSoundEngineButton[1] = offsetY;
  initSoundEngineButton[2] = initSoundEngineButton[0] + 100;
  initSoundEngineButton[3] = initSoundEngineButton[1] + 30;

  //Play or Stop Sound
  fill(0, 0, 100);
  rect(offsetX+480, offsetY, 100, 30);
  image(button_PlayStop, offsetX+480, offsetY, 100, 30);
  playSoundButton[0] = offsetX+440; playSoundButton[1] = offsetY;
  playSoundButton[2] = playSoundButton[0] + 100;
  playSoundButton[3] = playSoundButton[1] + 30;

    
    //Reproduction
    fill(100, 50, 50);
    rect(615, 270, 130, 60);
    image(button_Reproduction, 635, 285, 100, 30);
    reproductButton[0] = 615; reproductButton[1] = 270;
    reproductButton[2] = reproductButton[0] + 130;
    reproductButton[3] = reproductButton[1] + 60;
 
    
}

void drawLabel(){
    tint(255,255,255,127);
    image(label_Harmony, chromosomeArea[0][0]+19, chromosomeArea[0][1], 240, 60);
    image(label_Percussion, chromosomeArea[4][0]+15, chromosomeArea[4][1], 240, 60);
    image(label_Melodies, chromosomeArea[8][0]+18, chromosomeArea[8][1], 240, 60);
    noTint();
    
    image(label_Parents, 470, 240, 100, 30);
    image(label_Offspring, 475, 340, 100, 30);
    
    image(label_Storage, 790, 340, 100, 30);
}

void drawMovingBox(){
    if(draggingChromosome >= 0 && releaseTimeCounter == 0){
	//通常のドラッグ中
	fill(draggingChromosomeColor);
	rect(mouseX - 30, mouseY -30, 60, 60);
    }
    else if(draggingChromosome >= 0  && releaseTimeCounter > 0){
	//ドラッグを話して正しい位置にアイコンが移動中の時
	releaseTimeCounter--;
	if(releaseTimeCounter == 0){
	    //Targetに到着したとき
	    //終了処理．
	    chromosomeAreaColor[targetChromosomeAreaOfDrag] = 
		draggingChromosomeColor;
	    chromosomeAreaHasChromosome[targetChromosomeAreaOfDrag] = true;

            //Indexを解除
	    targetChromosomeAreaOfDrag = -1;
	    draggingChromosome = -1;

	}
	else{//移動中のとき
	    fill(draggingChromosomeColor);
	    rect(chromosomeArea[targetChromosomeAreaOfDrag][0] - 
		 distanceFromReleasePointToTargetBox[releaseTimeCounter][0], 
		 chromosomeArea[targetChromosomeAreaOfDrag][1] - 
		 distanceFromReleasePointToTargetBox[releaseTimeCounter][1],
		 60, 60);
	}
    }
}

void mouseReleased(){
    if(draggingChromosome > 0){
	//マウスの先端がエリアの中に入っている時は，targetとして離しても移動し続ける
	//そうでない場合は元の場所に戻る
	if(detectMouseOnBox() >= 0){
	    targetChromosomeAreaOfDrag = detectMouseOnBox();

	    //draggingChromosomeをtargetChromosomeAreaOfDragに移動したという
	    //OSC送信
             OscMessage message = new OscMessage("/CACIE_PA/GPEngine/copyIndividual");
             message.add(targetChromosomeAreaOfDrag);
             message.add(draggingChromosome);
             oscP5.send(message, gpEngineAddr);
            //println("copyIndividual message sending is done.");
        }
	else
	    targetChromosomeAreaOfDrag = draggingChromosome;
	releaseTimeCounter = 15;
	//離してから移動する座標を作ってておく．
	int[] oneCount = new int[2] ;
	oneCount[0] = 
	    (chromosomeArea[targetChromosomeAreaOfDrag][0] - mouseX) / 15;
	oneCount[1] = 
	    (chromosomeArea[targetChromosomeAreaOfDrag][1] - mouseY) / 15;

	for(int i=0; i<2; i++)
	    distanceFromReleasePointToTargetBox[0][i] = oneCount[i];
	for(int i=1; i<15; i++){
	    for(int j=0; j<2; j++)
	    distanceFromReleasePointToTargetBox[i][j] = 
		oneCount[j] + distanceFromReleasePointToTargetBox[i-1][j];
	}
    }
}

void applyCellAutomataStepRule(){
    OscMessage message = 
      new OscMessage("/CACIE_PA/CellAutomata/Controller/applyCellAutomataStepRule");
    message.add(appliedChromosomeAsRule);
    oscP5.send(message, soundGPEngineAddr);
}

void mousePressed(){
  if(mouseButton == RIGHT){
    appliedChromosomeAsRule = detectMouseOnBox(); 
    applyCellAutomataStepRule();
  }
  else{


    //Control Buttons

    //Increase Page
    if(mouseX >= nextPageButton[0] &&
      mouseX <= nextPageButton[2] && 
      mouseY >= nextPageButton[1] && 
      mouseY <= nextPageButton[3]){
	incrementPages();
    }
    else if(mouseX >= initGPButton[0] && //Init All
	    mouseX <= initGPButton[2] &&
	    mouseY >= initGPButton[1] &&
	    mouseY <= initGPButton[3]){
	initGPEngine();
    }
    else if(mouseX >= initChildrenButton[0] && //Init Children Area
	    mouseX <= initChildrenButton[2] &&
	    mouseY >= initChildrenButton[1] &&
	    mouseY <= initChildrenButton[3]){
	initChildren();
    }
    else if(mouseX >= reproductButton[0] && //Reproduction
            mouseX <= reproductButton[2] &&
            mouseY >= reproductButton[1] &&
            mouseY <= reproductButton[3]){
        reproduction();
    }
    else if(mouseX >= playSoundButton[0] && //Reproduction
            mouseX <= playSoundButton[2] &&
            mouseY >= playSoundButton[1] &&
            mouseY <= playSoundButton[3]){
        playSound();
    }
    else if(mouseX >= initSoundEngineButton[0] && //Reproduction
            mouseX <= initSoundEngineButton[2] &&
            mouseY >= initSoundEngineButton[1] &&
            mouseY <= initSoundEngineButton[3]){
        initSoundEngine();
    }
    else if(detectMouseOnBox() >= 0 && 
	    chromosomeAreaHasChromosome[detectMouseOnBox()]){
	//ChromosomeBoxのドラッグの開始

	//Chromosome Dragging
	draggingChromosome = detectMouseOnBox();
	draggingChromosomeColor = chromosomeAreaColor[draggingChromosome];
    }
  }
}

void mouseMoved(){
    //onMouseBox = detectMouseOnBox();
}

int detectMouseOnBox(){
    int returnValue = -1;
    for(int i=0; i<34; i++){
	if(mouseX >= chromosomeArea[i][0] &&
	   mouseX <= chromosomeArea[i][2] &&
	   mouseY >= chromosomeArea[i][1] &&
	   mouseY <= chromosomeArea[i][3]){
	    returnValue = i;
	    break;
	}
    }
    return returnValue;
}

void loadImages(){
  //Photos
  /*
  for(int i=0; i<numberOfPhoto; i++){
	photoImages[i] = loadImage("photo_ex" + i + ".jpg");
	photoSizes[i][0] = photoImages[i].width;
	photoSizes[i][1] = photoImages[i].height;
    }
   */
    
  //Control Buttons
  button_NextPage = loadImage("icon/Button_NextPage.png");
  button_InitGPEngine = loadImage("icon/Button_InitGP.png");
  button_InitPop = loadImage("icon/Button_InitPop.png");
  button_Reproduction = loadImage("icon/Button_Reproduction.png");
  button_InitSounds = loadImage("icon/Button_InitSounds.png");
  button_PlayStop = loadImage("icon/Button_PlayStop.png");

  //icons
  timpani = loadImage("icon/timpani.gif");
  snareDrum = loadImage("icon/snaredrum.gif");
  cowbell = loadImage("icon/cowbell.gif");
  keyBoard1 = loadImage("icon/e_piano.gif");
  keyBoard2 = loadImage("icon/keyboard.gif");
  keyBoard3 = loadImage("icon/shoulderkeyboard.gif");
  e_bass = loadImage("icon/e_bass.png");
  
  //labels
  label_Harmony = loadImage("icon/Label_Harmony.png");
  label_Percussion = loadImage("icon/Label_Percussion.png");
  label_Melodies = loadImage("icon/Label_Melodies.png");
  label_Parents = loadImage("icon/Label_Parents.png");
  label_Offspring = loadImage("icon/Label_Offspring.png");
  label_Storage = loadImage("icon/Label_Storage.png");

}

void makeChromosomeArea(){

    //page increse button occupies y:10 - 50
    // box size : 60 x 60
    // margin among each box is 10 : one box 70 x 70
    //X Center of Control Space is X:615
    int yOffset = 20;
    int xOffset = 475;

    // Assing Filed 4 x 3
    int areaCounter = 0;
    for(int i=0; i<3; i++){
	for(int j=0; j<4; j++){
	    chromosomeArea[areaCounter][0] = xOffset + j * 60 + 10 * j;
	    chromosomeArea[areaCounter][1] = yOffset + 10 * i;
	    chromosomeArea[areaCounter][2] = 
	    chromosomeArea[areaCounter][0] + 60;
	    chromosomeArea[areaCounter][3] = 
	    chromosomeArea[areaCounter][1] + 60;
	    chromosomeAreaColor[areaCounter] = color(100, 100, 100);
	    chromosomeAreaHasChromosome[areaCounter] = false;
	    areaCounter++;
	}
	yOffset += 60;
    }

    yOffset += 60;

    // Parents Field 2 x 1
    for(int i=0; i<2; i++){
	chromosomeArea[areaCounter][0] = xOffset + i * 60 + 10 * i;
	chromosomeArea[areaCounter][1] = yOffset + 10;
	chromosomeArea[areaCounter][2] = 
	    chromosomeArea[areaCounter][0] + 60;
	chromosomeArea[areaCounter][3] = 
	    chromosomeArea[areaCounter][1] + 60;
	chromosomeAreaColor[areaCounter] = color(100, 100, 100);
	chromosomeAreaHasChromosome[areaCounter] = false;
	areaCounter++;
    }
    yOffset += 120;

    // Children Filed 4 x 2
    for(int i=0; i<2; i++){
	for(int j=0; j<4; j++){
	    chromosomeArea[areaCounter][0] = xOffset + j * 60 + 10 * j;
	    chromosomeArea[areaCounter][1] = yOffset + 10 * i;
	    chromosomeArea[areaCounter][2] = 
		chromosomeArea[areaCounter][0] + 60;
	    chromosomeArea[areaCounter][3] = 
		chromosomeArea[areaCounter][1] + 60;
	    chromosomeAreaColor[areaCounter] = color(random(127), random(127), random(127));
	    chromosomeAreaHasChromosome[areaCounter] = true;
	    areaCounter++;
	}
	yOffset += 60;
    }

    yOffset -= 120;
    xOffset += 320;
    
    // Genome Storage 4 x 2
    for(int i=0; i<2; i++){
	for(int j=0; j<4; j++){
	    chromosomeArea[areaCounter][0] = xOffset + j * 60 + 10 * j;
	    chromosomeArea[areaCounter][1] = yOffset + 10 * i;
	    chromosomeArea[areaCounter][2] = 
		chromosomeArea[areaCounter][0] + 60;
	    chromosomeArea[areaCounter][3] = 
		chromosomeArea[areaCounter][1] + 60;
	    chromosomeAreaColor[areaCounter] = color(100, 100, 100);
	    chromosomeAreaHasChromosome[areaCounter] = false;
	    areaCounter++;
	}
	yOffset += 60;
    }
    
}

void oscEvent(OscMessage theOscMessage){
  if(theOscMessage.checkAddrPattern("/CACIE_PA/GPEngine/copyIndividual") == true){
     //For Test: CopyIndividualの時 
     int firstValue = theOscMessage.get(0).intValue();
     int secondValue = theOscMessage.get(1).intValue();
     println("copyIndividual: " + secondValue + " to " + firstValue);
    
  }
  else if(theOscMessage.checkAddrPattern("/CACIE_PA/GUI/currentPlayingPosition") == true){
      //print(" addrpattern: "+theOscMessage.addrPattern());
      //println(" typetag: "+theOscMessage.typetag());
      currentPlayingPosition = (int)theOscMessage.get(0).floatValue();
      //println("currentPlayingPosition is : " + currentPlayingPosition);
  }
  else if(theOscMessage.checkAddrPattern("/CACIE_PA/GUI/childrenChromosomeInformations") == true){
      setChildrenChromosomeColor
	  (theOscMessage.get(0).intValue(), theOscMessage.get(1).intValue(),
	   theOscMessage.get(2).intValue(), theOscMessage.get(3).intValue());
  }
  else if(theOscMessage.checkAddrPattern("/CACIE_PA/CellAutomataGUI/cellAutomataState") == true){
  
    //String stringSequence = theOscMessage.get(1).stringValue();
    //System.err.print(theOscMessage.get(0).intValue() + ",");
    //System.err.println(theOscMessage.get(1).stringValue());
    cellAutomataStateStringArray[theOscMessage.get(0).intValue()] = 
      theOscMessage.get(1).stringValue().toString();

  /*
  for(int i=0; i<cellAutomataSize; i++){
      cellAutomataStateStringArray[i] = 
        stringSequence.substring(i*cellAutomataSize, (i+1)*cellAutomataSize);
  }
  */
  
    //int column = theOscMessage.get(0).intValue();
    //cellAutomataStateStringArray[column] = theOscMessage.get(1).stringValue();
    //System.err.println(stateString);
    
  }
  else{
     println("Worng type of OSC message comes: " + 
       theOscMessage.addrPattern());
  }
}

void sendAnalizedInfo(){

    //OscMessage message = new OscMessage("/copyIndividual");
    //message.add(targetChromosomeAreaOfDrag);
    //message.add(draggingChromosome);
    //oscP5.send(message, soundGPEngineAddr);

    OscMessage message = new OscMessage("/CACIE_PA/PhotoMusic/Controller/setPhotoInformation");
    for(int i=currentDisplayPage*4; i<currentDisplayPage*4+4; i++)
	for(int j=0; j<6; j++)
	    message.add(analizedPhotoData[j][i]);
    oscP5.send(message, gpEngineAddr);
}
  
void analyzePhotos(){
      //initialize
      for(int i=0; i<numberOfPhoto/2; i++)
	  for(int j=0; j<6; j++)
	      analizedPhotoData[j][i] = 0.0;

      //Analyze
      for(int i=0; i<numberOfPhoto/2; i++){
	  //Make Dates, rPerc0, rPerc1, gPerc0, gPerc2, bPerc0, bPerc1
	  for(int j=0; j<2; j++){
	      //ratio of colors

	      float sumOfRedValue = 0.;
	      float sumOfGreenValue = 0.;
	      float sumOfBlueValue = 0.;
              PImage currentImage = photoImages[i+j];

	      for(int currentPixelY=0; 
		  currentPixelY<currentImage.height; currentPixelY++){
                for(int currentPixelX=0; 
		    currentPixelX<currentImage.width; currentPixelX++){
  		  sumOfRedValue 
		      += red(currentImage.get(currentPixelX, currentPixelY));
		  sumOfGreenValue 
		      += green(currentImage.get(currentPixelX, currentPixelY));
		  sumOfBlueValue 
		      += blue(currentImage.get(currentPixelX, currentPixelY));
                }
	      }

	      float sumOfAllPixels = 
		  sumOfRedValue + sumOfGreenValue + sumOfBlueValue;
	      analizedPhotoData[j][i] = sumOfRedValue / sumOfAllPixels;
	      analizedPhotoData[j+2][i] = sumOfGreenValue / sumOfAllPixels;
	      analizedPhotoData[j+4][i] = sumOfBlueValue /sumOfAllPixels;
	  }
      }

      for(int i=0; i<numberOfPhoto/2; i++){
	  for(int j=0; j<6; j++)
	      System.err.print(analizedPhotoData[j][i] + " ");
	  System.err.println(" ");
      }
}

void initGPEngine(){
    for(int i=0; i<chromosomeAreaHasChromosome.length; i++)
	chromosomeAreaHasChromosome[i] = false;
    OscMessage message = new OscMessage("/CACIE_PA/PhotoMusic/Controller/init/GPEngine");   
    oscP5.send(message, gpEngineAddr);

    initChildren();
    sendAnalizedInfo();
}

void initChildren(){
    OscMessage message = new OscMessage("/CACIE_PA/PhotoMusic/Controller/init/children");   
    oscP5.send(message, gpEngineAddr);    

    //After This Process
    //setChildrenChromosomeColor is called automatically by oscEvent
}

void initSoundEngine(){
  for(int i=0; i<12; i++)
    chromosomeAreaHasChromosome[i] = false;
  OscMessage message = new OscMessage("/CACIE_PA/SoundEngine/initSoundEngine");
  oscP5.send(message, soundEngineAddr);
}

void playSound(){
  OscMessage message = new OscMessage("/CACIE_PA/SoundEngine/playSound");
  oscP5.send(message, soundEngineAddr);
}

void setChildrenChromosomeColor
    (int indexInChildren, int numOfNodes,
     int numOfTerminalNodes, int numOfFunctionNodes){
  //System.err.println(indexInChildren + " " + numOfNodes + " " 
  //+ numOfTerminalNodes + " " + numOfFunctionNodes);
       
    chromosomeAreaHasChromosome[indexInChildren+14] = true;
    colorMode(HSB, 255);
    color newColor = 
	color((int)((float)numOfTerminalNodes / (float)numOfNodes * 255.), 
	      (int)((float)numOfFunctionNodes / (float)numOfNodes * 255.));
    chromosomeAreaColor[indexInChildren+14] = newColor;
    colorMode(RGB, 255);

}

void reproduction(){
 
    if(chromosomeAreaHasChromosome[12] ||
      chromosomeAreaHasChromosome[13]){
      OscMessage message = new OscMessage("/CACIE_PA/GPEngine/reproduction");
      oscP5.send(message, gpEngineAddr);
    }
    else
      System.err.println("No Parents in parents area");
}
