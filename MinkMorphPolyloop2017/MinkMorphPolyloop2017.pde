//*****************************************************************************
// Minkowski Morph of Polyloop, Jarek Rossignac, Oct 2006, revised Oct 2017 for P4 in CS6491
//*****************************************************************************
import processing.pdf.*;    // to save screen shots as PDFs
boolean snapPic=false;
int pictureCounter=0;
String PicturesOutputPath="data/PDFimages";
void snapPicture() {saveFrame("data/JPGimages/P"+nf(pictureCounter++,3)+".jpg"); }
Boolean scribeText=true; // toggle for displaying of help text
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
Boolean debug=true;

int cap=64;                    // max number of vertices
pt[] P = new pt [cap];          // vertices of the editable curve
pt[] Q = new pt [cap];          // vertices of the other curve
pt[] PQ = new pt [cap];          // vertices of the other curve
//int nP=4, nQ=12, nPQ;           // numbers of vertices in the two curves
int nP=3, nQ=6, nPQ;           // numbers of vertices in the two curves
int bi=-1;                      // index of selected mouse-vertex, -1 if none selected
pt Mouse = new pt(0,0);         // current mouse position
pt Last = new pt(0,0);          // last point drawn
float t=0.50, dt=0.01;           // current time amd time increment
color red = color(200, 10, 10), blue = color(10, 10, 200),  green = color(0, 150, 0), orange = color(250, 150, 5); // COLORS
boolean showDots=true, animating=false, showFrames=false;
int pic=0;

void setup() 
  {   
  size(1600, 600, P2D);  // open window
  for (int i=0; i<cap; i++) {P[i]=new pt(0,0); Q[i]=new pt(0,0); PQ[i]=new pt(0,0); };  // create all vertices, just in case
  for (int i=0; i<nP; i++) {P[i].setTo(-sin((i+0.29)*TWO_PI/nP)*(height*0.28)+height/3.0,cos((i+0.39)*TWO_PI/nP)*(height*0.28)+height/2.0);};
  for (int i=0; i<nQ; i++) {Q[i].setTo(-sin((i)*TWO_PI/nQ)*(height*0.1)+(width-height/3.0),cos((i)*TWO_PI/nQ)*(height*0.2)+height/2.0);};
  PFont font = loadFont("ArialMT-24.vlw"); textFont(font, 16);      // load font for writing on the canvas
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  smooth();  strokeCap(ROUND);
  }   
 
void draw() 
  { 
  background(255); 
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture
  fill(0); if(scribeText) displayHeader();
  if (bi!= -1) {P[bi].setToMouse();};                    // snap selected vertex to mouse position during dragging
  strokeWeight(2);
  stroke(green); drawCurve(P,nP);                    // draw P curve and its vertices in green
  stroke(red); drawCurve(Q,nQ);                      // draw Q curve in red
  if (showDots) drawDots();                          // draw control points of P
  if (animating) {  t+=dt; if ((t>=1)||(t<=0)) dt=-dt; } // shange time during animation to go back & forth
  drawMorph(t); // draw morphing curve
  if (showFrames) // show a series of 9 frames of the animation
    {                  
    float dtt=1.0/8;
    for (float tt=dtt; tt<1; tt+=dtt) drawMorph(tt);  // draw each frame using both colors
    }                  
  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen
  if(scribeText) displayFooter(); // shows title, menu, and my face & name 
  }
  
void drawCurve(pt[] P, int nP) {beginShape();  for (int i=0; i<nP; i++) {P[i].vert(); };  endShape(CLOSE); };    
 
void drawDots() {for (int i=0; i<nP; i++) {P[i].show(5);};};    

void drawTri(pt A, pt B, pt C) {beginShape(); A.vert(); B.vert(); C.vert(); endShape(CLOSE);};    
 
void drawMorph(float t) 
   {       
   int ne=0;
   stroke(green); // show green edges on morph
   for (int i=0; i<nP; i++) 
       for (int j=0; j<nQ; j++)  // for all vertex sequences A, B in P, for all vertices C, D, E in Q
           {  
           pt A = P[i]; pt B = P[in(i)]; pt C = Q[jp(j)]; pt D = Q[j]; pt E = Q[jn(j)];  
           if (dot(A.vecTo(B).left(),D.vecTo(C)) > 0 && dot(A.vecTo(B).left(),D.vecTo(E)) > 0 && dot(C.vecTo(D).left(),D.vecTo(E)) > 0)                 
             {strokeWeight(3); ne++; morph(A,B,D,t);} // morph edge(A,B) of P with vertex D of Q
           if (dot(A.vecTo(B).left(),D.vecTo(C)) < 0 && dot(A.vecTo(B).left(),D.vecTo(E)) < 0 && dot(C.vecTo(D).left(),D.vecTo(E)) < 0)    
             {strokeWeight(1); ne++; morph(A,B,D,t);} 
           }
   stroke(red); 
   for (int i=0; i<nP; i++) 
       for (int j=0; j<nQ; j++) 
           {        // for all vertices A in Q, for all vertices D in P
           pt A = Q[j]; pt B = Q[jn(j)]; pt C = P[ip(i)]; pt D = P[i]; pt E = P[in(i)];  // B=A.n; C=D.p; E=D.n;
           if (dot(A.vecTo(B).left(),D.vecTo(C)) > 0 && dot(A.vecTo(B).left(),D.vecTo(E)) > 0 && dot(C.vecTo(D).left(),D.vecTo(E)) > 0)                 
             {strokeWeight(3); ne++; morph(A,B,D,1-t); } //else  {stroke(orange); strokeWeight(1);}
             if (dot(A.vecTo(B).left(),D.vecTo(C)) < 0 && dot(A.vecTo(B).left(),D.vecTo(E)) < 0 && dot(C.vecTo(D).left(),D.vecTo(E)) < 0)    
             {stroke(red); strokeWeight(1); ne++; morph(A,B,D,1-t); } //else  {stroke(orange); strokeWeight(1);}
           }
    }    
   
void morph(pt pA, pt pB, pt C, float t) // draws edge (A,B) scaled by t towards C
  {
  pt A=pA.make(); A.moveTowards(C,t); 
  pt B=pB.make(); B.moveTowards(C,t); 
  A.showLineTo(B);
  }   
   
void copyPtoQ () {for (int i=0; i<nP; i++) {Q[i].setTo(P[i]);}; nQ=nP;}; // in case the user wants to copy P to Q by pressing c
void swapPandQ () {
  for (int i=0; i<nP; i++) {PQ[i].setTo(P[i]);}; nPQ=nP;
  for (int i=0; i<nQ; i++) {P[i].setTo(Q[i]);}; nP=nQ;
  for (int i=0; i<nPQ; i++) {Q[i].setTo(PQ[i]);}; nQ=nPQ;
 }; 

//**************************************
// **** GUI FOR EDITING THE CONTROL CURVE
//**************************************
void keyPressed() {  
  if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if(key=='~') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='!') snapPicture(); // make a picture of the canvas and saves as JPG image
  if (key=='c') copyPtoQ();            // replaces Q by a copy of P
  if (key=='s') swapPandQ();           // swap P and Q to let user edit Q
  if (key=='d') showDots=!showDots;
  if (key=='a') {animating=!animating; };    // reset time
  if (key=='f') {showFrames=!showFrames; if(!showFrames) t=0.5;};    // reset time
  if (key=='m') {t=0.5;};    // freeze time
  if (key==CODED) {if(keyCode==UP) dt*=2; if(keyCode==DOWN) dt/=2;}; // accelerate decelerate animation
  };       

void mouseDragged()                                                    // to do when mouse is pressed  
  {
  if(keyPressed && key=='t') for (int i=0; i<nP; i++) P[i].addVec(V(mouseX-pmouseX,mouseY-pmouseY));
  }
  
void mousePressed()                                                    // to do when mouse is pressed  
  {
  Mouse.setToMouse();                                                   // save current mouse location
  float bd=900;                                                     // init square of smallest distance to selected point
  for (int i=0; i<nP; i++) { if (d2(i)<bd) {bd=d2(i); bi=i;  };};       // select closeest vertex
  if (bd>10)                                                         // if closest vertex is too far
    {                                                         
    bd=600;                                                       // reinitilize distance squared
    for (int i=0; i<nP; i++) {if (dm(i)<bd) {bd=dm(i); bi=i;};};   // closest mid-edge point
    if (bd<20) 
      {  
      for (int i=nP-1; i>bi; i--) P[i+1].setTo(P[i]);                // shift down the rest 
      bi++;  P[bi].setTo(Mouse); nP++;                                  // insert new vertex at mouse position
      }
    else bi=-1;                                                 // nothing selected
    };
  }

float d(int j) {return sqrt(d2(j));};                     //  squared distance from mouse to vertex P[j]
float d2(int j) {return (Mouse.disTo(P[j]));};                     //  squared distance from mouse to vertex P[j]
float dm(int j) {return (Mouse.disTo(average(P[j],P[in(j)])));};   // squared distance from mouse to mid-edge point

void mouseReleased() // do this when mouse released
  {                                      
  if ( (bi!=-1) &&  P[bi].isOut() )  // if outside of port
    {                 
    for (int i=bi; i<nP; i++) P[i].setTo(P[in(i)]);        // shift up to delete selected vertex
    nP--; 
    println("deleted vertex "+bi);
    };                                           // reduce vertex vn
  bi= -1;   
  };
 
                                                          

//**************************************
//**** next and previous functions for polyloops P and Q
//**************************************
int in(int j) {  if (j==nP-1) {return (0);}  else {return(j+1);}  };  // next vertex in control loop
int ip(int j) {  if (j==0) {return (nP-1);}  else {return(j-1);}  };  // next vertex in control loop
int jn(int j) {  if (j==nQ-1) {return (0);}  else {return(j+1);}  };  // next vertex in control loop
int jp(int j) {  if (j==0) {return (nQ-1);}  else {return(j-1);}  };  // next vertex in control loop

//**************************************
//**** Title and help text
//**************************************
String title ="6491 2017 P4: Minkowski Morph of Smooth Piecewise-Circular Loops", 
       name ="Student: Abcdeefgh Ijklmnopqr",
       menu="?:(show/hide) help, a: animate, f:show frames, ~/!:snap PDF/JPG",
       guide="click and drag to edit green vertices / insert vertex at mid-edge / delete vertex by dragging it out, c: copy green to red, s:swap red/green, t:translate green"; // help info
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) { text(S,10,20+i*20); noFill();} // writes black at line i
void scribeHeaderRight(String S) {fill(0); text(S,width-8*S.length()-10,20); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }
    



  
 