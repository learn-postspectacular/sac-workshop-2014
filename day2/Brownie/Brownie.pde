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
    ellipse(x, y, 50, 50);
  }
  
  String toString() {
    return x+";"+y;
  }
}


class ColoredDot extends V2D {

  color col;
  float size;

  ColoredDot(float x, float y, color c) {
    super(x, y);
    this.col = c;
  }

  void render() {
    fill(col);
    super.render();
    line(x-10, y, x+10, y);
    line(x, y-10, x, y+10);
  }
  
  String toString() {
    return super.toString()+" color: "+col;
  }
}

class ColoredSquare extends V2D {
  color col;
  
  ColoredSquare(float x, float y, color c) {
     super(x,y);
     this.col = c;
  }
}

List<V2D> points = new ArrayList<V2D>();

void setup() {
  println(this);
  size(600, 600);
  for (int i=0; i < 100; i++) {
    color col = color(random(255), random(255), random(255));
    points.add(new ColoredSquare(width / 2, height / 2, col));
  }
}

void draw() {
  for (V2D p : points) {
    p.randomize();
    p.render();
  }
}

void mousePressed() {
  ColoredDot p = new ColoredDot(mouseX, mouseY, 0xff000000);
  points.add(p);
  println(p);
}

