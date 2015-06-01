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

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

PImage displayed_img, alligator_img, bear_img, calf_img, dog_img, elephant_img, frog_img, giraffe_img;
PImage cat_face, alligator_face, bear_face, calf_face, dog_face, elephant_face, frog_face, giraffe_face;
PImage empty_staff, piano_note, barn;
Minim minim;
AudioPlayer pianoA, pianoB, pianoC, pianoD, pianoE, pianoF, pianoG;
HashMap<Integer, AudioPlayer> notes = new HashMap<Integer, AudioPlayer>();
HashMap<Integer, PImage> imgs = new HashMap<Integer, PImage>();
HashMap<Integer, Integer> xLoc = new HashMap<Integer, Integer>();
HashMap<Integer, Integer> yLoc = new HashMap<Integer, Integer>();
HashMap<Integer, PImage> faces = new HashMap<Integer, PImage>();

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
  //noCursor();
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
  alligator_img = loadImage("alligator.png");
  bear_img = loadImage("bear.png");
  calf_img = loadImage("calf.png");
  dog_img = loadImage("dog.png");
  elephant_img = loadImage("elephant.png");
  frog_img = loadImage("frog.png");
  giraffe_img = loadImage("giraffe.png");
  
  alligator_face = loadImage("alligatorFace.png");
  bear_face = loadImage("bearFace.png");
  calf_face = loadImage("calfFace.png");
  dog_face = loadImage("dogFace.png");
  elephant_face = loadImage("elephantFace.png");
  frog_face = loadImage("frogFace.png");
  giraffe_face = loadImage("giraffeFace.png");
  
  empty_staff = loadImage("emptystaff.png");
  piano_note = loadImage("wholenote.png");
  barn = loadImage("barn.png");
  
  //load all sound files
  minim = new Minim(this);
  pianoA = minim.loadFile("pianoA.wav");
  pianoB = minim.loadFile("pianoB.wav");
  pianoC = minim.loadFile("pianoC.wav");
  pianoD = minim.loadFile("pianoD.wav");
  pianoE = minim.loadFile("pianoE.wav");
  pianoF = minim.loadFile("pianoF.wav");
  pianoG = minim.loadFile("pianoG.wav");
  
  //setup a hash table of the notes to play
  notes.put(0, pianoA);
  notes.put(1, pianoB); 
  notes.put(2, pianoC); 
  notes.put(3, pianoD);
  notes.put(4, pianoE);
  notes.put(5, pianoF);
  notes.put(6, pianoG);
  
  //setup the hash table of the imgs to display
  imgs.put(0, alligator_img); 
  imgs.put(1, bear_img);
  imgs.put(2, calf_img);
  imgs.put(3, dog_img);
  imgs.put(4, elephant_img);
  imgs.put(5, frog_img);
  imgs.put(6, giraffe_img);
  
  //setup the hash table of the faces to display
  faces.put(0, alligator_face);
  faces.put(1, bear_face);
  faces.put(2, calf_face);
  faces.put(3, dog_face);
  faces.put(4, elephant_face);
  faces.put(5, frog_face);
  faces.put(6, giraffe_face);
  
  //setup the x location of the note to display
  xLoc.put(0, 475);
  xLoc.put(1, 475); 
  xLoc.put(2, 475); 
  xLoc.put(3, 475); 
  xLoc.put(4, 475);
  xLoc.put(5, 475);
  xLoc.put(6, 475);
  
  //setup the y location of the note to display
  yLoc.put(0, 350); 
  yLoc.put(1, 310); 
  yLoc.put(2, 290); 
  yLoc.put(3, 240); 
  yLoc.put(4, 240); 
  yLoc.put(5, 240); 
  yLoc.put(6, 240);
  
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
    image(empty_staff, 0, 0, width, height/2);
    image(barn, 0, height/2, width, height/2);
    
    visibleCount = 0; 
    boolean[] visibleIDS = new boolean[7];
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
         image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
         image(faces.get(k), xLoc.get(k), yLoc.get(k), piano_note.width/6, piano_note.height/6);
        }
        popMatrix();
        fill(255);
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
     
     delay(500);   
  }
  
  //code for displaying the learn song mode
  if(learnSong) {
    elapsedTime = (millis() - startTime)/1000;
    //draw the barn and the empty staff
    image(empty_staff, 0, 0, width, height/2);
    image(barn, 0, height/2, width, height/2);
    
    if(elapsedTime >= 0.25 && elapsedTime<=1){
      //play E
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(4).rewind();
      notes.get(4).play();
    }
    else if(elapsedTime>1 && elapsedTime<=2){
      //play D
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(3).rewind();
      notes.get(3).play();
    }
    else if(elapsedTime>2 && elapsedTime<=3){
      //play C
      displayed_img = imgs.get(2);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(2).rewind();
      notes.get(2).play();
    }
    else if(elapsedTime>3 && elapsedTime <=4){
      //play D
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(3).rewind();
      notes.get(3).play();
    }
    else if(elapsedTime>4 && elapsedTime<=7){
      //play E 3 times
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
      notes.get(4).rewind();
      notes.get(4).play();
    }
    else if(elapsedTime>8 && elapsedTime<=11){
      //play D 3 times
      notes.get(3).rewind();
      notes.get(3).play();
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>12 && elapsedTime<=13){
      //play E
      notes.get(4).rewind();
      notes.get(4).play();
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if (elapsedTime>13 && elapsedTime<=15){
      //play G 2 times
      notes.get(6).rewind();
      notes.get(6).play();
      displayed_img = imgs.get(6);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>16 && elapsedTime<=17){
      //play E
      notes.get(4).rewind();
      notes.get(4).play();
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>17 && elapsedTime<=18){
      //play D
      notes.get(3).rewind();
      notes.get(3).play();
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>18 && elapsedTime<=19){
      //play C
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>19 && elapsedTime<=20){
      //play D
      notes.get(3).rewind();
      notes.get(3).play();
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>20 && elapsedTime<=24){
      //play E 4 times
      notes.get(4).rewind();
      notes.get(4).play();
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>24 && elapsedTime<=26){
      //play D 2 times
      notes.get(3).rewind();
      notes.get(3).play();
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>26 && elapsedTime<=27){
      //play E
      notes.get(4).rewind();
      notes.get(4).play();
      displayed_img = imgs.get(4);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>27 && elapsedTime<=28){
      //play D
      notes.get(3).rewind();
      notes.get(3).play();
      displayed_img = imgs.get(3);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    else if(elapsedTime>28 && elapsedTime<=29){
      //play C
      notes.get(2).rewind();
      notes.get(2).play();
      displayed_img = imgs.get(2);
      image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
    }
    
    visibleCount = 0; 
    boolean[] visibleIDS = new boolean[7];
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
         image(displayed_img, 300, (height/2)+50, displayed_img.width/2, displayed_img.height/2);
         image(faces.get(k), xLoc.get(k), yLoc.get(k), piano_note.width/6, piano_note.height/6);
        }
        popMatrix();
        fill(255);
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
