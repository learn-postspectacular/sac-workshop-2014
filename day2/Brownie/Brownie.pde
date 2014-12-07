// Introductory example to OOP & basic inheritance
// Defines a simple 2D vector class and some methods
// Also defines sub-class of V2D to demonstrate OOP concepts
// Simulates Brownian motion
//
// Controls:
// click to add new particle
//
// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LGPL3 licensed

import toxi.color.*;
import java.util.*;

class V2D {
  float x, y;

  V2D(float xx, float yy) {
    x = xx;
    y = yy;
  }

  void randomize() {
    x += random(-5, 5); // same x = x + .... 
    y += random(-5, 5);
  }

  void render() {
    fill(255);
    ellipse(x, y, 10, 10);
  }

  String toString() {
    return x + ";" + y;
  }
}

// a specialization of the above V2D class
// supplements vector w/ size & color
class ColoredDot extends V2D {

  color col;
  float size;

  ColoredDot(float x, float y, float s, color c) {
    // call to "super" means call V2D's constructor
    // this must *always* come first or else compiler will complain
    super(x, y);
    this.size = s;
    this.col = c;
  }

  void render() {
    float s2 = size / 2;
    fill(col);
    ellipse(x, y, size, size);
    line(x - s2, y, x + s2, y);
    line(x, y - s2, x, y + s2);
  }

  String toString() {
    return super.toString() + " color: "+col;
  }
}

// List is supertype of ArrayList
// V2D is supertype of ColoredDot, hence list can store both types
List<V2D> points = new ArrayList<V2D>();

void setup() {
  // our sketch also is just a sub-class of PApplet
  // "this" here refers to this applet/sketch itself
  println(this);
  size(600, 600);
  background(128);
  for (int i = 0; i < 100; i++) {
    points.add(new V2D(width / 2, height / 2));
  }
}

void draw() {
  for (V2D p : points) {
    p.randomize();
    p.render();
  }
}

void mousePressed() {
  color col = color(random(255), random(255), random(255));
  ColoredDot p = new ColoredDot(mouseX, mouseY, random(5, 20), col);
  points.add(p);
  println(p);
}

