float a=1.4, b=-2.3, c=2.4, d=-2.1;

int w2,h2;
float scalex, scaley;

float dejongX(float x, float y) {
  return sin(a * y) - cos(b * x);
}

float dejongY(float x, float y) {
  return sin(c * x) - cos(d * y);
}

void setup() {
  size(800, 800);
  background(0);
  w2 = width / 2;
  h2 = height / 2;
  scalex = width * 0.24;
  scaley = height * 0.24;
}

void draw() {
  // pick random start position for DeJong
  float x = random(-3, 3);
  float y = random(-3, 3);
  // initialize pixel buffer
  loadPixels();
  // repeat 1000x per frame
  for (int i = 0; i < 1000; i++) {
    // first compute X & Y for next iteration
    float xx = dejongX(x, y);
    float yy = dejongY(x, y);
    // calculate distance from center/origin
    float d = sqrt(xx * xx + yy * yy);
    // map xx & yy to screen coordinates
    int sx = (int)(xx * scalex) + w2;
    int sy = (int)(yy * scaley) + h2;
    // calculate index of pixel in array (2D -> 1D projection)
    int index = sy * width + sx;
    // check if pixel is within bounds
    if (index >= 0 && index < pixels.length) {
      int col = pixels[index];
      // compute new RGB values based on distance of current pixel
      int r = constrain((int)(red(col) + 10.0 * pow(d, 1.2)), 0, 255); 
      int g = constrain((int)(green(col) + 10.0 * pow(d, 1.5)), 0, 255);
      int b = constrain((int)(blue(col) + 15.0 * pow(d, 1.8)), 0, 255);
      // update pixel
      pixels[index] = color(r, g, b);
    }
    // propagate results to next iteration (feedback)
    x = xx;
    y = yy;
  }
  // trigger pixel buffer update
  updatePixels();
  // fin, the end, kraj
}

void keyPressed() {
  if (key == ' ') {
    saveFrame(System.currentTimeMillis()+".png");
  } else if (key == 'r') {
    a = random(-3, 3);
    b = random(-3, 3);
    c = random(-3, 3);
    d = random(-3, 3);
    background(0);
  }
}

