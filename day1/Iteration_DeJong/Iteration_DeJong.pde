int EXPOSURE = 1;

float a, b, c, d;
float scale;

int w2, h2;

boolean doSave;

void setup() {
  size(1024, 1024);
  w2 = width / 2;
  h2 = height / 2;
  scale = width * 0.24;
  resetAll();
  //a=2.735146; b=-2.840466; c=2.8155098; d=2.2075872;
}

void draw() {
  loadPixels();
  for (int i = 0; i < 100; i++) {
    float x=random(-1, 1);
    float y=random(-1, 1);
    for (int k = 0; k < 2500; k++) {
      float xsq = x * x;
      float xx = sin(a * y) + cos(b * xsq);
      float yy = sin(c * xsq) + cos(d*y);
      int idx = (int)(scale * xx + w2) + (int)(scale * yy + h2) * width;
      int col = pixels[idx] & 0xff;
      if (col > 0) {
        col = max(col - EXPOSURE, 0);
        pixels[idx] = col << 16 | col << 8 | col;
      }
      x=xx;
      y=yy;
    }
  }
  updatePixels();
  if (doSave) {
    saveFrame(String.format("dejong_%1.5f_%1.5f_%1.5f_%1.5f.png", a, b, c, d));
    doSave=false;
  }
}

void resetAll() {
  background(255);
  a = random(-3f, 3f);
  b = random(-3f, 3f);
  c = random(-3f, 3f);
  d = random(-3f, 3f);
  println("a="+a+"; b="+b+"; c="+c+"; d="+d+";");
}

void keyPressed() {
  if (key==' ') {
    doSave=true;
  }
  if (key=='x') {
    resetAll();
  }
}

