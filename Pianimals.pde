//Pianimals
/* William Chou
   Marlon Twyman
   Gaby Anton
   Lucy Henninsgard 
   Cameron MacArthur
*/

// import the TUIO library
import TUIO.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Map;
import java.lang.Object;
import java.util.Arrays;

// import keyboard listeners (testing things when you don't have the time to mess w/ reactivision)
import java.awt.KeyEventDispatcher;
import java.awt.KeyboardFocusManager;
import java.awt.event.KeyEvent;

// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
int visibleCount = 0; 
int startTime; 
int elapsedTime;
int currentNote = 1;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

PImage displayed_img, alligator_img, bear_img, calf_img, cow_img, dog_img, elephant_img, frog_img, giraffe_img;
PImage cat_face, alligator_face, bear_face, calf_face, cow_face, dog_face, elephant_face, frog_face, giraffe_face;
PImage empty_staff, piano_note, barn, currentNoteImg;
Minim minim;
AudioPlayer pianoA, pianoB, pianoC, pianoD, pianoE, pianoF, pianoG, pianohighC;
HashMap<Integer, AudioPlayer> notes = new HashMap<Integer, AudioPlayer>();
HashMap<Integer, PImage> imgs = new HashMap<Integer, PImage>();
HashMap<Integer, Integer> xLoc = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> yLoc = new HashMap<Integer, Integer>();
HashMap<Integer, PImage> faces = new HashMap<Integer, PImage>();
HashMap<Integer, Integer> img_sizeX = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> img_sizeY = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> face_sizeX = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> face_sizeY = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> xLocFace = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> yLocFace = new HashMap<Integer, Integer>();

boolean titleScreen = true; 
boolean freePlay = false; 
boolean learnSong = false; 

int freeButtonX, freeButtonY;
int learnButtonX, learnButtonY;
int backButtonX, backButtonY;
int buttonSizeX = 120;
int buttonSizeY = 30; 
color freeButtonColor, learnButtonColor, backButtonColor;
color freeButtonHighlight, learnButtonHighlight, backButtonHighlight;
boolean freeButtonOver = false; 
boolean learnButtonOver = false; 
boolean backButtonOver = false;

void setup()
{
  // GUI setup
  size(displayWidth,displayHeight);
  noStroke();
  fill(0);
  
  //set the colors for the interface
  freeButtonColor = color(255);
  freeButtonHighlight = color(204);
  freeButtonX = (width/2)-60;
  freeButtonY = (height/2)-100;
  
  learnButtonColor = color(255);
  learnButtonHighlight = color(204);
  learnButtonX = (width/2) - 60;
  learnButtonY = (height/2)-60;
  
  backButtonColor = color(255);
  backButtonHighlight = color(204);
  backButtonX = 20; 
  backButtonY = 20;
  
  //load all image files
  alligator_img = loadImage("imgs/alligator.png");
  bear_img = loadImage("imgs/bear.png");
  calf_img = loadImage("imgs/calf.png");
  cow_img = loadImage("imgs/cow.png");
  dog_img = loadImage("imgs/dog.png");
  elephant_img = loadImage("imgs/elephant.png");
  frog_img = loadImage("imgs/frog.png");
  giraffe_img = loadImage("imgs/giraffe.png");
  
  alligator_face = loadImage("imgs/alligatorFace.png");
  bear_face = loadImage("imgs/bearFace.png");
  calf_face = loadImage("imgs/calfFace.png");
  cow_face = loadImage("imgs/cowFace.png");
  dog_face = loadImage("imgs/dogFace.png");
  elephant_face = loadImage("imgs/elephantFace.png");
  frog_face = loadImage("imgs/frogFace.png");
  giraffe_face = loadImage("imgs/giraffeFace.png");
  
  empty_staff = loadImage("imgs/emptystaff.png");
  piano_note = loadImage("imgs/wholenote.png");
  barn = loadImage("imgs/barn2.png");
  currentNoteImg = elephant_img;
  
  //load all sound files
  minim = new Minim(this);
  pianoC = minim.loadFile("notes/pianoC.mp3");
  pianoD = minim.loadFile("notes/pianoD.mp3");
  pianoE = minim.loadFile("notes/pianoE.mp3");
  pianoF = minim.loadFile("notes/pianoF.mp3");
  pianoG = minim.loadFile("notes/pianoG.mp3");
  pianoA = minim.loadFile("notes/pianoA.mp3");
  pianoB = minim.loadFile("notes/pianoB.mp3");
  pianohighC = minim.loadFile("notes/pianohighC.mp3");
  
  //setup a hash table of the notes to play
  notes.put(0, pianoC);
  notes.put(1, pianoD); 
  notes.put(2, pianoE); 
  notes.put(3, pianoF);
  notes.put(4, pianoG);
  notes.put(5, pianoA);
  notes.put(6, pianoB);
  notes.put(7, pianohighC);
  
  //setup the hash table of the imgs to display
  imgs.put(0, cow_img); 
  imgs.put(1, dog_img);
  imgs.put(2, elephant_img);
  imgs.put(3, frog_img);
  imgs.put(4, giraffe_img);
  imgs.put(5, alligator_img);
  imgs.put(6, bear_img);
  imgs.put(7, calf_img);
  
  //setup the hash table of the faces to display
  faces.put(0, cow_face);
  faces.put(1, dog_face);
  faces.put(2, elephant_face);
  faces.put(3, frog_face);
  faces.put(4, giraffe_face);
  faces.put(5, alligator_face);
  faces.put(6, bear_face);
  faces.put(7, calf_face);
  
  //setup the x location of the note to display
  xLoc.put(0, 0*width/9);
  xLoc.put(1, 1*width/9); 
  xLoc.put(2, 2*width/9); 
  xLoc.put(3, 3*width/9); 
  xLoc.put(4, 4*width/9);
  xLoc.put(5, 5*width/9);
  xLoc.put(6, 6*width/9);
  xLoc.put(7, 7*width/9); 
  
  //setup the y location of the note to display
  yLoc.put(0, 6*height/10); 
  yLoc.put(1, 6*height/10); 
  yLoc.put(2, 6*height/10); 
  yLoc.put(3, 6*height/10); 
  yLoc.put(4, 6*height/10); 
  yLoc.put(5, 6*height/10); 
  yLoc.put(6, 6*height/10);
  yLoc.put(7, 6*height/10);
  
  img_sizeX.put(0, cow_img.width/4);
  img_sizeX.put(1, 3*dog_img.width/4);
  img_sizeX.put(2, 3*elephant_img.width/4);
  img_sizeX.put(3, 4*frog_img.width/4);
  img_sizeX.put(4, giraffe_img.width/4);
  img_sizeX.put(5, alligator_img.width/4);
  img_sizeX.put(6, bear_img.width/2);
  img_sizeX.put(7, calf_img.width/4);
  
  img_sizeY.put(0, cow_img.height/4);
  img_sizeY.put(1, 3*dog_img.height/4);
  img_sizeY.put(2, 3*elephant_img.height/4);
  img_sizeY.put(3, 3*frog_img.height/4);
  img_sizeY.put(4, giraffe_img.height/4);
  img_sizeY.put(5, alligator_img.height/4);
  img_sizeY.put(6, bear_img.height/2);
  img_sizeY.put(7, calf_img.height/4);
  
  face_sizeX.put(0, 3*cow_face.width/4);
  face_sizeX.put(1, dog_face.width/2);
  face_sizeX.put(2, elephant_face.width/3);
  face_sizeX.put(3, frog_face.width/2);
  face_sizeX.put(4, 3*giraffe_face.width/16);
  face_sizeX.put(5, alligator_face.width/4);
  face_sizeX.put(6, bear_face.width/4);
  face_sizeX.put(7, calf_face.width/7);
  
  face_sizeY.put(0, 3*cow_face.height/4);
  face_sizeY.put(1, dog_face.height/2);
  face_sizeY.put(2, elephant_face.height/3);
  face_sizeY.put(3, frog_face.height/2);
  face_sizeY.put(4, 3*giraffe_face.height/16);
  face_sizeY.put(5, alligator_face.height/4);
  face_sizeY.put(6, bear_face.height/4);
  face_sizeY.put(7, calf_face.height/7);
  
  xLocFace.put(0, 300);
  xLocFace.put(1, 375); 
  xLocFace.put(2, 475);
  xLocFace.put(3, 575); 
  xLocFace.put(4, 650); 
  xLocFace.put(5, 750); 
  xLocFace.put(6, 800); 
  xLocFace.put(7, 900); 
  
  yLocFace.put(0, 250); //C
  yLocFace.put(1, 215); //D
  yLocFace.put(2, 195); //E
  yLocFace.put(3, 185); //F
  yLocFace.put(4, 150); //G
  yLocFace.put(5, 135); //A
  yLocFace.put(6, 110); //B
  yLocFace.put(7, 80);  //C
  
  
  
  // periodic updates
  if (!callback) {
    frameRate(60); //<>//
    loop();
  } else noLoop(); // or callback updates 
  
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

// within the draw method we retrieve an ArrayList of type <TuioObject>, <TuioCursor> or <TuioBlob>
// from the TuioProcessing client and then loops over all lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  
  update();
  
  //code for displaying the title screen
  if(titleScreen){
    fill(0);
    textSize(42); 
    text("Welcome to Pianimals!" , (width/2)-200, (height/2)-200); 
    textSize(36); 
    text("Select an option below", (width/2)-200, (height/2)-150);
    
    if(freeButtonOver){
      fill(freeButtonHighlight);
    }
    else {
      fill(freeButtonColor);
    }
    stroke(0);
    rect(freeButtonX, freeButtonY, buttonSizeX, buttonSizeY); 
    fill(0);
    textSize(20);
    text("Free Play", freeButtonX, freeButtonY+20);
    
    if(learnButtonOver) {
      fill(learnButtonHighlight);
    }
    else {  
      fill(learnButtonColor);
    }
    stroke(0);
    rect(learnButtonX, learnButtonY, buttonSizeX, buttonSizeY);
    fill(0);
    textSize(20);
    text("Learn A Song", learnButtonX, learnButtonY+20);

  }
  
  //code for displaying the freeplay mode
  if(freePlay) {
    //draw the barn and the empty staff
    image(empty_staff, 0, 0, width, 4*height/10);
    image(barn, 0, 4*height/10, width, 6*height/10);
//    
//    visibleCount = 0; 
//    boolean[] visibleIDS = new boolean[8];
//    ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
//    for (int i=0;i<tuioObjectList.size();i++) {
//       TuioObject tobj = tuioObjectList.get(i);
//       visibleIDS[tobj.getSymbolID()] = true;
//       visibleCount++;
//     }
//     
//    for(int k = 0; k<visibleIDS.length; k++){
//       stroke(0);
//       fill(0,0,0);
//       pushMatrix();
//       //check for which note does not appear
//       if(visibleIDS[k] == false && visibleCount!=0){
//         //if it doesnt appear, play the corresponding note
//         print(k);
//         notes.get(k).rewind();
//         notes.get(k).play();
//         displayed_img = imgs.get(k);
//         image(displayed_img, xLoc.get(), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
//         image(faces.get(k), xLoc.get(k), yLoc.get(k), piano_note.width/6, piano_note.height/6);
//        }
//        popMatrix();
//        fill(255);
//     }
//     Arrays.fill(visibleIDS, false);
//     if(backButtonOver){
//       fill(backButtonHighlight);
//     }
//     else {
//       fill(backButtonColor);
//     }
//     stroke(0);
//     rect(backButtonX, backButtonY, buttonSizeX, buttonSizeY);
//     fill(0);
//     textSize(20);
//     text("Back to Menu", backButtonX, backButtonY+20);
//     
//     delay(500);   

      for(int i=0; i<8; i++){
        
        image(imgs.get(i), xLoc.get(i), yLoc.get(i), img_sizeX.get(i), img_sizeY.get(i));
        image(faces.get(i), xLocFace.get(i), yLocFace.get(i), face_sizeX.get(i), face_sizeY.get(i));
      }
  }
  
  //code for displaying the learn song mode
  if(learnSong) {
    elapsedTime = (millis() - startTime)/1000;
    //draw the barn and the empty staff
    image(empty_staff, 0, 0, width, 4*height/10);
    image(barn, 0, 4*height/10, width, 6*height/10);
    
    visibleCount = 0; 
    boolean[] visibleIDS = new boolean[8];
    ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
    for (int i=0;i<tuioObjectList.size();i++) {
       TuioObject tobj = tuioObjectList.get(i);
       visibleIDS[tobj.getSymbolID()] = true;
       visibleCount++;
     }
     
    for(int k = 0; k<visibleIDS.length; k++){
       stroke(0);
       fill(0,0,0);
       pushMatrix();
       //check for which note does not appear
       if(visibleIDS[k] == false && visibleCount!=0){
         //if it doesnt appear, play the corresponding note
         print(k);
         notes.get(k).rewind();
         notes.get(k).play();
         displayed_img = imgs.get(k);
         image(displayed_img, xLoc.get(k), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
         image(faces.get(k), xLoc.get(k), yLoc.get(k), piano_note.width/6, piano_note.height/6);
        }
        popMatrix();
        fill(255);
     }
      
    if(currentNote==1 && !visibleIDS[2]){
      //play E
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(2).rewind();
      notes.get(2).play();
      currentNote++;
      currentNoteImg = dog_img;
    }
    else if(currentNote==2 && !visibleIDS[1]){
      //play D
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(1).rewind();
      notes.get(1).play();
      currentNote++;
      currentNoteImg = cow_img; 
    }
    else if(currentNote==3 && !visibleIDS[0]){
      //play C
      displayed_img = imgs.get(0);
      image(displayed_img, xLoc.get(0), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(0).rewind();
      notes.get(0).play();
      currentNote++;
      currentNoteImg = dog_img;
    }
    else if(currentNote==4 && !visibleIDS[1]){
      //play D
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(1).rewind();
      notes.get(1).play();
      currentNote++;
      currentNoteImg = elephant_img;
    }
    else if(currentNote>=5 && currentNote<=7 && !visibleIDS[2]){
      //play E 3 times
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(2).rewind();
      notes.get(2).play();
      currentNote++;
      if(currentNote==8){
        currentNoteImg = dog_img;
      }
    }
    else if(currentNote>=8 && currentNote<=10 && !visibleIDS[1]){
      //play D 3 times
      notes.get(1).rewind();
      notes.get(1).play();
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      if (currentNote==11){
        currentNoteImg = elephant_img;
      }      
    }
    else if(currentNote==11 && !visibleIDS[2]){
      //play E
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = giraffe_img;
    }
    else if (currentNote>=12 && currentNote<=13 && !visibleIDS[4]){
      //play G 2 times
      notes.get(4).rewind();
      notes.get(4).play();
      displayed_img = imgs.get(4);
      image(displayed_img, xLoc.get(4), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      if(currentNote==14){
        currentNoteImg = elephant_img;
      }
    }
    else if(currentNote==14 && !visibleIDS[2]){
      //play E
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = dog_img;
    }
    else if(currentNote==15 && !visibleIDS[1]){
      //play D
      notes.get(1).rewind();
      notes.get(1).play();
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = cow_img;
    }
    else if(currentNote==16 && !visibleIDS[0]){
      //play C
      notes.get(0).rewind();
      notes.get(0).play();
      displayed_img = imgs.get(0);
      image(displayed_img, xLoc.get(0), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = dog_img;
    }
    else if(currentNote==17 && !visibleIDS[1]){
      //play D
      notes.get(1).rewind();
      notes.get(1).play();
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = elephant_img;
    }
    else if(currentNote>=18 && currentNote<=21 && !visibleIDS[2]){
      //play E 4 times
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      if(currentNote==22){
        currentNoteImg = dog_img;
      }
    }
    else if(currentNote>=22 && currentNote<=23 && !visibleIDS[1]){
      //play D 2 times
      notes.get(1).rewind();
      notes.get(1).play();
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      if(currentNote==24){
        currentNoteImg = elephant_img;
      }
    }
    else if(currentNote==24 && !visibleIDS[2]){
      //play E
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, xLoc.get(2), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = dog_img;
    }
    else if(currentNote==25 && !visibleIDS[1]){
      //play D
      notes.get(1).rewind();
      notes.get(1).play();
      displayed_img = imgs.get(1);
      image(displayed_img, xLoc.get(1), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
      currentNoteImg = cow_img;
    }
    else if(currentNote==26 && !visibleIDS[0]){
      //play C
      notes.get(0).rewind();
      notes.get(0).play();
      displayed_img = imgs.get(0);
      image(displayed_img, xLoc.get(0), (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      currentNote++;
    }
    else {
      if (currentNote != 27) {
        image(currentNoteImg, 300, (height/2)+50, currentNoteImg.width/2, currentNoteImg.height/2);
        print(currentNote);
      }
    }
     
     
     Arrays.fill(visibleIDS, false);
     if(backButtonOver){
       fill(backButtonHighlight);
     }
     else {
       fill(backButtonColor);
     }
     stroke(0);
     rect(backButtonX, backButtonY, buttonSizeX, buttonSizeY);
     fill(0);
     textSize(20);
     text("Back to Menu", backButtonX, backButtonY+20);
     
     delay(700);   
  }
}

void update(){
  if (overButton(freeButtonX, freeButtonY, buttonSizeX, buttonSizeY)){
    freeButtonOver = true; 
    learnButtonOver = false; 
  }
  else if (overButton(learnButtonX, learnButtonY, buttonSizeX, buttonSizeY)){
    learnButtonOver = true; 
    freeButtonOver = false; 
  }
  else {
    freeButtonOver = learnButtonOver = false; 
  }
   
  if(overButton(backButtonX, backButtonY, buttonSizeX, buttonSizeY)){
    backButtonOver = true; 
  }
  else {
    backButtonOver = false; 
  }
}

boolean overButton(int x, int y, int width, int height){
  if (mouseX >= x && mouseX <= x+width &&
      mouseY >= y && mouseY <= y+height) {
    return true;  
  }
  else {
    return false; 
  }
}

//boolean overLearnSong(int x, int y, int width, int height){
//  if (mouseX >= x && mouseX <= x+width &&
//      mouseY >= y && mouseY <= y+height) {
//    return true;  
//  }
//  else {
//    return false; 
//  }
//}

void mousePressed() {
  if(freeButtonOver){
    freePlay = true; 
    titleScreen = false; 
    learnSong = false; 
  }
  if(learnButtonOver) {
    learnSong = true; 
    titleScreen = false; 
    freePlay = false;
    startTime = millis();
  }
  if(backButtonOver){
    titleScreen = true; 
    learnSong = false;
    freePlay = false; 
  }
}

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
          +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}

void mouseClicked(){
  println("mouseX: " + mouseX); 
  println("mouseY: " + mouseY);
}

//Event listener class for keystrokes 
public void keyPressed(KeyEvent e) {
    int keyCode = e.getKeyCode();
    switch( keyCode ) { 
        case KeyEvent.VK_A:
            pianoA.rewind();
            pianoA.play();
            break;
        case KeyEvent.VK_B:
            pianoB.rewind();
            pianoB.play(); 
            break;
        case KeyEvent.VK_C:
            pianoC.rewind();
            pianoC.play();
            break;
        case KeyEvent.VK_D :
            pianoD.rewind();
            pianoD.play();
            break;
        case KeyEvent.VK_E :
            pianoE.rewind();
            pianoE.play();
            break;
        case KeyEvent.VK_F :
            pianoF.rewind();
            pianoF.play();
            break;
        case KeyEvent.VK_G :
            pianoG.rewind();
            pianoG.play();
            break;
     }
} 
