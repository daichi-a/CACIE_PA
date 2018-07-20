import processing.core.*; 
import processing.xml.*; 

import oscP5.*; 
import netP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class GUI_PhotoMusic extends PApplet {





PImage[] photoImages = new PImage[16];
int[][] photoSizes = new int[16][2];
int currentDisplayPage = 0; //0 or 1
int numberOfPhoto = 16;
int currentPlayingPosition = 0;
int[][] chromosomeArea = new int[34][4];
int[] chromosomeAreaColor = new int[34];
boolean[] chromosomeAreaHasChromosome = new boolean[34];
int onMouseBox = -1;
int draggingChromosome = -1;
int draggingChromosomeColor;
int[][] distanceFromReleasePointToTargetBox = new int[15][2];

int targetChromosomeAreaOfDrag = -1;
int releaseTimeCounter = 0;

float[][] analizedPhotoData = new float[6][4];
//rPerc0, rPerc1, gPerc0, gPerc2, bPerc0, bPerc1

OscP5 oscP5;
NetAddress soundGPEngineAddr;

//ForTest
int drawTimeCounter = 0;

public void setup(){

    size(800, 600, P2D);
    background(255);
    colorMode(RGB, 256);
    noStroke();
    frameRate(10);
    loadImages();
    imageMode(CORNER);
    makeChromosomeArea();
    oscP5 = new OscP5(this, 12000);
    soundGPEngineAddr = new NetAddress("localhost", 57120);
}

public void draw(){
    background(255);
    drawFrame();
    drawChromosomeFrame();
    drawPlayingPosition();
    drawPhotos();
    drawControlButton();
    drawMovingBox();
 }


public void drawFrame(){
    //Control Space
    fill(30, 50, 80);
    rect(430, 0, 370, 600);
    //PhotoSpace
    fill(0,0,0);
    rect(0,0, 430, 600);
}

public void drawChromosomeFrame(){
    fill(127, 127, 127);
    for(int i=0; i<34; i++)
	drawOneBox(chromosomeArea[i][0], chromosomeArea[i][1], i);

}

public void drawOneBox(int xPos, int yPos, int boxIndex){
    int colorOffset = 0;
    if(onMouseBox == boxIndex)
	colorOffset = 30;
    fill(red(chromosomeAreaColor[boxIndex]) + colorOffset,
	 green(chromosomeAreaColor[boxIndex]) + colorOffset,
	 blue(chromosomeAreaColor[boxIndex]) + colorOffset);
    rect(xPos, yPos, 60, 60);
}

public void drawPlayingPosition(){
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

public void drawPhotos(){
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

public void drawControlButton(){
    //Next Page Button
    fill(0, 0, 0);
    rect(440, 10, 350, 30); //(440, 10) to (790, 40)    

    //Initial All Button
    

    //Generate Initial Generation

}


public void drawMovingBox(){
    if(draggingChromosome >= 0 && releaseTimeCounter == 0){
	//\u901a\u5e38\u306e\u30c9\u30e9\u30c3\u30b0\u4e2d
	fill(draggingChromosomeColor);
	rect(mouseX - 30, mouseY -30, 60, 60);
    }
    else if(draggingChromosome >= 0  && releaseTimeCounter > 0){
	//\u30c9\u30e9\u30c3\u30b0\u3092\u8a71\u3057\u3066\u6b63\u3057\u3044\u4f4d\u7f6e\u306b\u30a2\u30a4\u30b3\u30f3\u304c\u79fb\u52d5\u4e2d\u306e\u6642
	releaseTimeCounter--;
	if(releaseTimeCounter == 0){
	    //Target\u306b\u5230\u7740\u3057\u305f\u3068\u304d
	    //\u7d42\u4e86\u51e6\u7406\uff0e
	    chromosomeAreaColor[targetChromosomeAreaOfDrag] = 
		draggingChromosomeColor;
	    chromosomeAreaHasChromosome[targetChromosomeAreaOfDrag] = true;

            //Index\u3092\u89e3\u9664
	    targetChromosomeAreaOfDrag = -1;
	    draggingChromosome = -1;

	}
	else{//\u79fb\u52d5\u4e2d\u306e\u3068\u304d
	    fill(draggingChromosomeColor);
	    rect(chromosomeArea[targetChromosomeAreaOfDrag][0] - 
		 distanceFromReleasePointToTargetBox[releaseTimeCounter][0], 
		 chromosomeArea[targetChromosomeAreaOfDrag][1] - 
		 distanceFromReleasePointToTargetBox[releaseTimeCounter][1],
		 60, 60);
	}
    }
}

public void mouseReleased(){
    if(draggingChromosome > 0){
	//\u30de\u30a6\u30b9\u306e\u5148\u7aef\u304c\u30a8\u30ea\u30a2\u306e\u4e2d\u306b\u5165\u3063\u3066\u3044\u308b\u6642\u306f\uff0ctarget\u3068\u3057\u3066\u96e2\u3057\u3066\u3082\u79fb\u52d5\u3057\u7d9a\u3051\u308b
	//\u305d\u3046\u3067\u306a\u3044\u5834\u5408\u306f\u5143\u306e\u5834\u6240\u306b\u623b\u308b
	if(detectMouseOnBox() >= 0){
	    targetChromosomeAreaOfDrag = detectMouseOnBox();

	    //draggingChromosome\u3092targetChromosomeAreaOfDrag\u306b\u79fb\u52d5\u3057\u305f\u3068\u3044\u3046
	    //OSC\u9001\u4fe1
             OscMessage message = new OscMessage("/copyIndividual");
             message.add(targetChromosomeAreaOfDrag);
             message.add(draggingChromosome);
             oscP5.send(message, soundGPEngineAddr);
            //println("copyIndividual message sending is done.");
        }
	else
	    targetChromosomeAreaOfDrag = draggingChromosome;
	releaseTimeCounter = 15;
	//\u96e2\u3057\u3066\u304b\u3089\u79fb\u52d5\u3059\u308b\u5ea7\u6a19\u3092\u4f5c\u3063\u3066\u3066\u304a\u304f\uff0e
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

public void mousePressed(){
    //Control Buttons

    //Increase Page
    if(mouseX <= 790 && mouseX >= 440 && mouseY >= 10 && mouseY <= 40){
	incrementPages();
    }
    else if(detectMouseOnBox() >= 0 && 
	    chromosomeAreaHasChromosome[detectMouseOnBox()]){
	//ChromosomeBox\u306e\u30c9\u30e9\u30c3\u30b0\u306e\u958b\u59cb

	//Chromosome Dragging
	draggingChromosome = detectMouseOnBox();
	draggingChromosomeColor = chromosomeAreaColor[draggingChromosome];
    }
}

public void mouseMoved(){
    //onMouseBox = detectMouseOnBox();
}

public int detectMouseOnBox(){
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

public void loadImages(){
    for(int i=0; i<16; i++){
	photoImages[i] = loadImage("photo_ex" + i + ".jpg");
	photoSizes[i][0] = photoImages[i].width;
	photoSizes[i][1] = photoImages[i].height;
    }
}

public void makeChromosomeArea(){

    //page increse button occupies y:10 - 50
    // box size : 60 x 60
    // margin among each box is 10 : one box 70 x 70
    //X Center of Control Space is X:615
    int yOffset = 60;
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

    yOffset += 20;

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
    yOffset += 80;

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

    yOffset += 20;
    
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

public int incrementPages(){
    int maxPage = numberOfPhoto / 8;
    currentDisplayPage++;
    if(currentDisplayPage > maxPage-1)
	currentDisplayPage = 0;
    return currentDisplayPage;
}

public void oscEvent(OscMessage theOscMessage){
  if(theOscMessage.checkAddrPattern("/copyIndividual") == true){
     //For Test: CopyIndividual\u306e\u6642 
     int firstValue = theOscMessage.get(0).intValue();
     int secondValue = theOscMessage.get(1).intValue();
     println("copyIndividual: " + secondValue + " to " + firstValue);
    
  }
  else if(theOscMessage.checkAddrPattern("/currentPlayingPosition") == true){
   print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
      currentPlayingPosition = (int)theOscMessage.get(0).floatValue();
      //println("currentPlayingPosition is : " + currentPlayingPosition);
  }
  else{
     println("Worng type of OSC message comes: " + 
       theOscMessage.addrPattern());
  }
}
  
public void analyzePhotos(){
      //initialize
      for(int i=0; i<4; i++)
	  for(int j=0; j<6; j++)
	      analizedPhotoData[j][i] = 0.0f;

      //Analyze
      for(int i=currentDisplayPage*8; i<currentDisplayPage*8+8; i+=2){
	  //Make Dates, rPerc0, rPerc1, gPerc0, gPerc2, bPerc0, bPerc1
	  for(int j=0; j<2; j++){
	      //ratio of colors

	      float sumOfRedValue = 0.f;
	      float sumOfGreenValue = 0.f;
	      float sumOfBlueValue = 0.f;
              PImage currentImage = photoImages[i+j];

	      for(int currentPixelY=0; currentPixelY<currentImage.height; currentPixelY++){
                for(int currentPixelX=0; currentPixelX<currentImage.width; currentPixelX++){
  		  sumOfRedValue += red(currentImage.get(currentPixelX, currentPixelY));
		  sumOfGreenValue += green(currentImage.get(currentPixelX, currentPixelY));
		  sumOfBlueValue += blue(currentImage.get(currentPixelX, currentPixelY));
                }
	      }

	      float sumOfAllPixels = sumOfRedValue + sumOfGreenValue + sumOfBlueValue;
	      analizedPhotoData[j][i] = sumOfRedValue / sumOfAllPixels;
	      analizedPhotoData[j+2][i] = sumOfGreenValue / sumOfAllPixels;
	      analizedPhotoData[j+4][i] = sumOfBlueValue /sumOfAllPixels;
	  }
	  
      }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "GUI_PhotoMusic" });
  }
}
