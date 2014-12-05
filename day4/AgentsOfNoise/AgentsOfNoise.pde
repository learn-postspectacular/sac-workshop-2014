import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import toxi.color.*;
import toxi.util.*;
import toxi.util.datatypes.*;
import toxi.math.*;
import toxi.math.noise.*;

import java.util.*;
import javax.media.opengl.GL;

int IMG_SIZE = 100;
FloatRange NOISE_SCALE = new FloatRange(0.03, 0.08);

int NUM_AGENTS = 500;
FloatRange SPEED_RANGE = new FloatRange(1, 3);
float SCAN_DIST = 20;

float EL_BAND_SIZE = 2;
boolean USE_EL_HUE = true;
float HUE_COMPRESS = 20000;
float BASE_HUE = 0.0;

PImage img;

Terrain terra;
TriangleMesh terrainMesh;

ToxiclibsSupport gfx;

List<Agent> agents = new ArrayList<Agent>();

boolean draw3D;// = true;

void setup() {
  size(1280, 720, OPENGL);
  smooth(8);
  gfx = new ToxiclibsSupport(this);
  img = new PImage(IMG_SIZE, IMG_SIZE);
  //randomizeTerrain();
  terrainFromImage("gis2.jpg");
  randomizeAgents();
  background(0);
}

void draw() {
  for (Agent a : agents) {
    a.update();
  }
  if (draw3D) {
    background(0);
    image(img, 0, 0);
    lights();
    noStroke();
    translate(width/2, height/2, 0);
    rotateX(TWO_PI/3);
    rotateY(mouseX*0.01);
    scale(2, 1, 2);
    fill(255);
    gfx.mesh(terrainMesh, false);
    for (Agent a : agents) {
      a.draw3D();
    }
  } else {
    PGL pgl = ((PGraphicsOpenGL)g).pgl;
    pgl.blendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
    translate(width/2, height/2);
    //scale(1.5);
    for (Agent a : agents) {
      a.draw2D();
    }
  }
}

void randomizeTerrain() {
  Vec2D offset = new Vec2D(random(100), random(100));
  float s = NOISE_SCALE.pickRandom();
  float[] el = new float[img.width*img.height];
  for (int y = 0, idx = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      float n = (float)SimplexNoise.noise(offset.x+x*s, offset.y+y*s);
      float c = constrain(map(n, -1, 1, 0, 255), 0, 255);
      img.set(x, y, color(c));
      el[y * img.width + x] = c;
      //el[idx] = c; idx++;
    }
  }
  terra = new Terrain(img.width, img.height, 4);
  terra.setElevation(el);
  terrainMesh = (TriangleMesh)terra.toMesh();
}

void terrainFromImage(String path) {
  img = loadImage(path);
  float[] el = new float[img.pixels.length];
  for (int i = 0; i < el.length; i++) {
    el[i] = img.pixels[i] & 255;
  }
  terra = new Terrain(img.width, img.height, 4);
  terra.setElevation(el);
  terrainMesh = (TriangleMesh)terra.toMesh();
}

FloatRange makeElevationRange(float el) {
  return new FloatRange(el, el + EL_BAND_SIZE);
}

void randomizeAgents() {
  agents.clear();
  GenericSet<FloatRange> elOpts = new GenericSet<FloatRange>();
  for (int i=0; i<255; i+=10) {
    elOpts.add(makeElevationRange(i));
  }
  for (int i=0; i < NUM_AGENTS; i++) {
    agents.add(new Agent(random(-1, 1)*img.width*4/2, random(-1, 1)*img.width*4/2, elOpts.pickRandom()));
    //agents.add(new Agent(0, 0, elOpts.pickRandom()));
  }
}

void keyPressed() {
  if (key == 'r') {
    randomizeTerrain();
    randomizeAgents();
    background(0);
  }
  if (key == 'a') {
    randomizeAgents();
    background(0);
  }
  if (key == '3') {
    draw3D = !draw3D;
    background(0);
  }
  if (key == ' ') {
    saveFrame(DateUtils.timeStamp()+".png");
  }
}

