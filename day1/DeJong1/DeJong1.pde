// Introduction to iterative functions/processes:
// Compute & visualize the DeJong strange attractor
// For each step we compute the distance of the point
// from the center and use that to create a fake
// depth-of-field effect by manipulating the size of
// the dot drawn
//
// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LGPLv3 licensed

// DeJong configuration
float A = 1.4, B = 1.5, C = 2.4, D = -2.1;

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
}

void draw() {
  float x = random(-3, 3);
  float y = random(-3, 3);
  for (int i = 0; i < 1000; i++) {
    // first compute X & Y for next iteration
    float xx = dejongX(x, y);
    float yy = dejongY(x, y);
    // calculate distance from center/origin
    float d = 1 + sqrt(xx * xx + yy * yy);
    // scale dist exponentially
    d = pow(d, 2);
    // map xx & yy to screen coordinates
    float sx = xx * width * 0.24 + width/2;
    float sy = yy * height * 0.24 + height/2;
    // draw dot with alpha/transparency
    // modulate size based on distance (Depth of Field effect)
    fill(255, 5);
    noStroke();
    ellipse(sx, sy, d, d);
    // propagate results to next iteration
    x = xx;
    y = yy;
  }
  // fin, the end, kraj
}
