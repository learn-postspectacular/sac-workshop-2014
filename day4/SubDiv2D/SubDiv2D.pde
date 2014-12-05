// 2D Polygon subdivisions via configurable edge splitting
// and displacing of split points.
// Similar sequential approach as /day3/SubDiv example, but for 2D
// and DNA cyclic

// Controls:
// Click to apply next subdiv
// x - export extruded polygon as STL

// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LPGL3 licensed

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;

import java.util.*;

Polygon2D poly;
ToxiclibsSupport gfx;

List<Polygon2D> history = new LinkedList<Polygon2D>();

int iterCount = 0;

float[][] iterations = new float[][] {
  new float[] { 
    -20, 40, -20
  }
  , 
  new float[] { 
    10, -20, 10
  }
  , 
  new float[] { 
    -5, 10, -5
  }
  , 
  new float[] { 
    0, 5, 0
  }
};

void setup() {
  size(1680, 800);
  gfx = new ToxiclibsSupport(this);
  poly = new Circle(350).toPolygon2D(3);
  //poly = new Rect(0, 0, 400, 400).toPolygon2D().center();
  //poly.flipVertexOrder();
}

void draw() {
  background(255);
  fill(0);
  text(poly.vertices.size(), 20, 20);
  translate(width/2, height/2);
  noFill();
  stroke(0, 50);
  for (Polygon2D hp : history) {
    gfx.polygon2D(hp);
  }
  stroke(255, 0, 0);
  for (Line2D s : poly.getEdges ()) {
    line(s.a.x, s.a.y, s.b.x, s.b.y);
    //Vec2D m = s.getMidPoint();
    //fill(255, 0, 0);
    //ellipse(m.x, m.y, 5, 5);
    //fill(0, 255, 255);
    //Vec2D p = s.a.interpolateTo(s.b, 1/3.0);
    //Vec2D q = s.a.interpolateTo(s.b, 2/3.0);
    //ellipse(p.x, p.y, 5, 5);
    //ellipse(q.x, q.y, 5, 5);
    //Vec2D dir = s.getDirection();
    //Vec2D normal = dir.getPerpendicular().scale(100);
    //Vec2D end = m.add(normal);
    //line(m.x, m.y, end.x, end.y);
    //ellipse(end.x, end.y, 10, 10);
  }
}

List<Vec2D> subdivideEdge(Line2D e, float[] config) {
  float len = e.getLength();
  float amp = len/100.0;
  Vec2D m = e.getMidPoint();
  Vec2D p = e.a.interpolateTo(e.b, 1/3.0);
  Vec2D q = e.a.interpolateTo(e.b, 2/3.0);
  Vec2D normal = e.getDirection().getPerpendicular();
  p.addSelf(normal.scale(config[0] * amp));
  m.addSelf(normal.scale(config[1] * amp));
  q.addSelf(normal.scale(config[2] * amp));
  List<Vec2D> points = new ArrayList<Vec2D>();
  points.add(e.a);
  points.add(p);
  points.add(m);
  points.add(q);
  points.add(e.b);
  return points;
}

void subdividePolygon(float[] config) {
  Polygon2D newPoly = new Polygon2D();
  for (Line2D e : poly.getEdges ()) {
    newPoly.vertices.addAll(subdivideEdge(e, config));
  }
  newPoly.removeDuplicates(0.001);
  history.add(poly);
  poly = newPoly;
}

TriangleMesh extrudePath(float z) {
  TriangleMesh mesh = new TriangleMesh();
  int num = poly.vertices.size();
  for(int i = 0; i < num-1; i++) {
    float zz = sin(i * 0.1) * z/2 + z;
    Vec3D a = poly.get(i).to3DXY();
    Vec3D b = poly.get(i+1).to3DXY();
    Vec3D c = a.add(0, 0, zz);
    Vec3D d = b.add(0, 0, zz);
    mesh.addFace(a, b, c);
    mesh.addFace(b, d, c);
  }
  return mesh;
}

void keyPressed() {
  if (key == 'x') {
    extrudePath(100).saveAsSTL(sketchPath("foo.stl"));
  }
}

void mousePressed() {
  subdividePolygon(iterations[iterCount]);
  if (iterCount == iterations.length) {
    iterCount = 0;
  }
  //iterCount = (iterCount + 1) % iterations.length;
}

