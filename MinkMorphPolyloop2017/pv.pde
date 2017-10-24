//************************************************************************
//**** 2D POINTS AND VECTOR CLASSES, Jarek Rossignac, Oct 2005
//************************************************************************
class pt { float x,y; 

  // CREATE, COPY
  pt (float px, float py) {x = px; y = py;}
  pt (pt P) {x = P.x; y = P.y;}
  pt makeCopy() {return(new pt(x,y));}
  pt make() {return(new pt(x,y));};
  void setTo(float px, float py) {x = px; y = py;}
  void setTo(pt P) { x = P.x; y = P.y; }
  void setToMouse() { x = mouseX; y = mouseY; }

  // DISPLAY, PRINT 
  void vert() {vertex(x,y);}
  void show(int r) { ellipse(x, y, r, r); }
  void label(String s, vec D) {text(s, x+D.x,y+D.y);  }
  void label(String s, float dx, float dy) {text(s, x+dx,y+dy);  }
  void showLineTo (pt P) {line(x,y,P.x,P.y); }

  // DISPLACE
  void addVec(vec V) {x += V.x; y += V.y;}
  void subVec(vec V) {x -= V.x; y -= V.y;}
  void addScaledVec(float s, vec V) {x += s*V.x; y += s*V.y;}
  void moveTowards(pt P, float s) {x=x+s*(P.x-x);  y=y+s*(P.y-y); }

  // ADD, SUBTRACT, MULTIPLY
  void addPt(pt P) {x+=P.x; y+=P.y;}
  void subPt(pt P) {x-=P.x; y-=P.y;}
  void mul(float f) {x*=f; y*=f;}

  // TEST, MEASURE
  boolean isOut() {return(((x<0)||(x>width)||(y<0)||(y>height)));}
  float disTo(pt P) {return(sqrt(sq(P.x-x)+sq(P.y-y))); }
  
  // MAKE VECTOR
  vec vecTo(pt P) {return(new vec(P.x-x,P.y-y)); }
  vec vecToMid (pt P, pt Q) {return(new vec((P.x+Q.x)/2.0-x,(P.y+Q.y)/2.0-y)); }
 
  } 
   
pt average(pt A, pt B) {return(new pt((A.x+B.x)/2,(A.y+B.y)/2)); }
pt average(pt A, pt B, pt C) {return(new pt((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0)); }
pt s(pt A, float t, pt B) {return(new pt(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y))); }
pt Bezier(pt A, pt B, pt C, pt D, float t) {return( s( s( s(A,t,B) ,t, s(B,t,C) ) ,t, s( s(B,t,C) ,t, s(C,t,D) ) ) ); }
void drawBezier(pt A, pt B, pt C, pt D) { beginShape();  for (float t=0; t<=1; t+=0.02) {Bezier(A,B,C,D,t).vert(); };  endShape(); }
pt add3divide(pt A, pt B, pt C, float s) {return(new pt((A.x+B.x+C.x)/s,(A.y+B.y+C.y)/s)); };


vec V(float dx, float dy) {return new vec(dx,dy);}
vec V(pt A, pt B) {return new vec(B.x-A.x,B.y-A.y);}
class vec { float x,y; 

  // CREATE, COPY
  vec (float px, float py) {x = px; y = py;};
  vec makeCopy() {return(new vec(x,y));}; 
  vec make() {return(new vec(x,y));};
  void setFromValues(float px, float py) {x = px; y = py;}; 
  void setFromVec(vec V) { x = V.x; y = V.y; }; 
  
   // DISPLAY, PRINT 
  void show (pt P) { ellipse(P.x, P.y, 3, 3); line(P.x,P.y,P.x+x,P.y+y); }; 
  void write() {println("("+x+","+y+")");};
  
   // ADD, SUBTRACT, MULTIPLY, DIVIDE, NORMALIZE

  void mul(float m) {x *= m; y *= m;};
  void div(float m) {x /= m; y /= m;};
  void add(vec V) {x += V.x; y += V.y;};
  void addScaled(float m, vec V) {x += m*V.x; y += m*V.y;};
  void sub(vec V) {x -= V.x; y -= V.y;};
  
  // TEST, MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}; 
  boolean isZero() {return((abs(x)+abs(y)<0.000001));}; 

  // MAKE VECTOR 
  void unit() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;};};
  vec left() {return(new vec(-y,x));};
  void back() {x= -this.x; y= -this.y;};
  } 

vec average(vec U, vec V) {return(new vec((U.x+V.x)/2,(U.y+V.y)/2)); };
float dot(vec U, vec V) {return(U.x*V.x+U.y*V.y); };