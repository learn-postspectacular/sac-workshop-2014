float a=1.4, b=1.5, c=2.4, d=-2.1;

float dejongX(float x, float y) {
  return sin(a * y) - cos(b * x);
}

float dejongY(float x, float y) {
  return sin(c * x) - cos(d * y);
}

void setup() {
  size(800, 800);
  background(255);
}

void draw() {
  float x = random(-3, 3);
  float y = random(-3, 3);
  for (int i = 0; i < 1000; i++) {
    // first compute X & Y for next iteration
    float xx = dejongX(x, y);
    float yy = dejongY(x, y);
    // calculate distance from center/origin
    float d = 1+sqrt(xx * xx + yy * yy);
    // scale dist exponentially
    d = pow(d, 2);
    // map xx & yy to screen coordinates
    float sx = xx * width * 0.24 + width/2;
    float sy = yy * height * 0.24 + height/2;
    // draw dot with alpha/transparency
    // modulate size based on distance (Depth of Field effect)
    fill(0, 5);
    noStroke();
    ellipse(sx, sy, d, d);
    // propagate results to next iteration
    x = xx;
    y = yy;
  }
  // fin, the end, kraj
}

