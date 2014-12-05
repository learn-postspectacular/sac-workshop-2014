// Sequential/recursive mesh subdivisions using
// a random cylinder as seed mesh and different
// subdivision strategies
// Subdiv DNA seq can be randomized and result
// meshes can be exported as STL

// Controls:
// r - randomize subdiv DNA
// space - save as STL
// mousewheel - adjust zoom

// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // ASL2 licensed

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.mesh.subdiv.*;
import toxi.processing.*;
import toxi.util.*;

ToxiclibsSupport gfx;

WETriangleMesh mesh;

SubdivisionStrategy[] subdivs = new SubdivisionStrategy[] {
  new MidpointSubdivision(), 
  new MidpointDisplacementSubdivision(new Vec3D(), 0.25), 
  new MidpointDisplacementSubdivision(new Vec3D(), -0.25), 
  new NormalDisplacementSubdivision(0.25f),
  new DualSubdivision()
};

int CYLINDER_RES = 3;

int[] dna = new int[] {
  //3, 2, 0, 1, 3
  2, 1, 2, 3, 3, 2
  //4,3,4,3,2,0,1
};

int[] dnaBackup = dna.clone();

float zoom = 1;

void setup() {
  size(800, 600, P3D);
  smooth(8);
  gfx=new ToxiclibsSupport(this);
  dnaSubDivide();
}

void draw() {
  background(255);
  lights();
  translate(width / 2, height / 2, 0);
  rotateX(mouseY * 0.01);
  rotateY(mouseX * 0.01);
  scale(zoom);
  strokeWeight(0.25 / zoom);
  gfx.mesh(mesh, false);
}

void randomizeDNA() {
  CYLINDER_RES = (int)random(3, 20);
  dnaBackup = dna;
  int dnaLen = (int)random(5, 8);
  dna = new int[dnaLen];
  for (int i = 0; i < dnaLen; i++) {
    dna[i] = (int)random(0, subdivs.length);
  }
}

void dnaSubDivide() {
  try {
    mesh = new WETriangleMesh(); 
    new Cone(new Vec3D(), new Vec3D(0, 1, 0), 0, 200, 400).toMesh(mesh, CYLINDER_RES, 0, true, true);
    for (int i = 0; i < dna.length; i++) {
      println(dna[i]);
      SubdivisionStrategy s = subdivs[dna[i]];
      mesh.subdivide(s);
      WETriangleMesh mesh2 = new WETriangleMesh();
      mesh2.addMesh(mesh);
      mesh = mesh2;
    }
  } 
  catch(Exception e) {
    e.printStackTrace();
    println("eeek!");
    //dna = dnaBackup;
    //dnaSubDivide();
  }
}

void keyPressed() {
  if (key == 'r') {
    randomizeDNA();
    println(dna);
    dnaSubDivide();
  }
  if (key == ' ') {
    mesh.saveAsSTL(sketchPath(DateUtils.timeStamp()+".stl"));
  }
  if (key == 's') {
    new LaplacianSmooth().filter(mesh, 1);
  }
}

void mouseWheel(MouseEvent e) {
  zoom += map(e.getCount(), -5, 5, 0.1, -0.1);
  zoom = constrain(zoom, 0.1, 4);
}

