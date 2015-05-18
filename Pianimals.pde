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

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

PImage displayed_img, frog_img, cow_img, elephant_img, goat_img, empty_staff, piano_note, barn;
Minim minim;
AudioPlayer pianoA, pianoB, pianoC, pianoD, pianoE, pianoF, pianoG;
HashMap<Integer, AudioPlayer> notes = new HashMap<Integer, AudioPlayer>();
HashMap<Integer, PImage> imgs = new HashMap<Integer, PImage>();
//Delay myDelay;


void setup()
{
  // GUI setup
  noCursor();
  size(displayWidth,displayHeight);
  noStroke();
  fill(0);

  cow_img = loadImage("cow.png");
  elephant_img = loadImage("elephant.png");
  frog_img = loadImage("frog.png");
  goat_img = loadImage("goat.jpg");
  empty_staff = loadImage("emptystaff.png");
  piano_note = loadImage("eighthnote.png");
  barn = loadImage("barn.png");
  
  minim = new Minim(this);
  pianoA = minim.loadFile("pianoA.wav");
  pianoB = minim.loadFile("pianoB.wav");
  pianoC = minim.loadFile("pianoC.wav");
  pianoD = minim.loadFile("pianoD.wav");
  pianoE = minim.loadFile("pianoE.wav");
  pianoF = minim.loadFile("pianoF.wav");
  pianoG = minim.loadFile("pianoG.wav");
  
  //setup a hash table of the notes to play
  notes.put(0, pianoC);
  notes.put(1, pianoE); 
  notes.put(2, pianoF); 
  notes.put(3, pianoG);
  
  //setup the hash table of the imgs to display
  imgs.put(0, cow_img); 
  imgs.put(1, elephant_img);
  imgs.put(2, frog_img);
  imgs.put(3, goat_img);
  
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
  
  image(empty_staff, 0, 0, width, height/2);
  image(barn, 0, height/2, width, height/2);
  
  boolean[] visibleIDS = new boolean[4];
  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = tuioObjectList.get(i);
     visibleIDS[tobj.getSymbolID()] = true;
     //print(tobj.getSymbolID());
//     stroke(0);
//     fill(0,0,0);
//     pushMatrix();
//     translate(tobj.getScreenX(width),tobj.getScreenY(height));
//     rotate(tobj.getAngle());
     //rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
//     if(tobj.getSymbolID()==0){
//       pianoF.play();
//       image(frog_img, -obj_size/2,-obj_size/2, frog_img.width/4, frog_img.height/4);
//     }
//     popMatrix();
//     fill(255);
//     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }
   
   for(int k = 0; k<visibleIDS.length; k++){
     stroke(0);
     fill(0,0,0);
     pushMatrix();
     //draw the barn and empty staff
     //image(empty_staff, 
     //check for which note does not appear
     if(visibleIDS[k] == false){
       //if it doesnt appear, play the corresponding note
       print(k);
       notes.get(k).rewind();
       notes.get(k).play();
       displayed_img = imgs.get(k);
       image(displayed_img, 300, (height/2)+50, displayed_img.width/4, displayed_img.height/4);
     }
     popMatrix();
     fill(255);
   }
   Arrays.fill(visibleIDS, false);
   delay(1000);   

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

//Event listener class for keystrokes (again, trying to build dynamic staff, not tryina reactivision rn)
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
