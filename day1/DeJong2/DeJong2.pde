// Introduction to iterative functions/processes:
// Compute & visualize the DeJong strange attractor
// In this version we also started discussing/implementing
// simple color theory and pixel manipulations
//
// Key controls:
// space - export screenshot (in sketch folder)
// r - randomize attractor parameters
//
// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LGPLv3 licensed

// DeJong configuration
float A = 1.4, B = -2.3, C = 2.4, D = -2.1;

int w2,h2;
float scalex, scaley;

// Computes next X coordinate of attractor
float dejongX(float x, float y) {
  return sin(A * y) - cos(B * x);
}

// Computes next Y coordinate of attractor
float dejongY(float x, float y) {
  return sin(C * x) - cos(D * y);
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
    A = random(-3, 3);
    B = random(-3, 3);
    C = random(-3, 3);
    D = random(-3, 3);
    background(0);
  }
}

