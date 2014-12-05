// Very much the same as FieldLineAgents demo bundled w/ toxiclibs
// Only extended to export image as PDF

// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LPGL3 licensed

/**
 * FieldLineAgents is a simulation of agents tracing field lines within
 * a cluster of randomly charged dipoles. Agents are spawned in uniform
 * directions from each pole and collect their trajectory in a list.
 * Agents stop evaluating the field once they reach another pole or leave
 * the bounding rect of the simulation.
 *
 * The agent behavior can be modified using the SELF_AVOIDANCE flag, which
 * when true ensures that agents *always* travel away from their parent pole.
 *
 * Usage:
 *
 * click on poles to toggle their charge (positive/negative)
 * r: reset & randomize simulation
 * a: toggle agent self avoidance
 *
 * (c) 2012 Karsten Schmidt // LGPL licensed
 */
import processing.opengl.*;
import processing.pdf.*;

import toxi.geom.*;
import toxi.color.*;
import toxi.math.*;
import toxi.util.*;
import toxi.processing.*;
import java.util.*;

int SPEED = 5;
int NUM_POLES = 10;
int NUM_AGENTS = 20;
boolean SELF_AVOIDANCE = false;

List<Pole> poles=new ArrayList<Pole>();
List<Agent> agents = new ArrayList<Agent>();

Rect bounds;

ToxiclibsSupport gfx;
boolean doSave;

void setup() {
  size(1280, 720, OPENGL);
  initSimulation();
  bounds=new Rect(0, 0, width, height);
  gfx=new ToxiclibsSupport(this);
}

void draw() {
  if (doSave) {
    beginRecord(PDF, DateUtils.timeStamp() + ".pdf");
  }
  background(255);
  noFill();
  stroke(0);
  //strokeWeight(0.25);
  for (Agent a : agents) {
    a.update(poles);
    // ignore agents which do not manage to leave parent pole
    if (a.path.size()>3) {
      stroke(a.isAlive ? color(255,0,0) : color(0,0,255));
      beginShape();
      for(Vec2D p : a.path) {
        vertex(p.x, p.y);
      }
      endShape();
    }
  }
  if (doSave) {
    endRecord();
    doSave = false;
  }
}

void keyPressed() {
  if (key=='r') {
    initSimulation();
  }
  if (key=='a') {
    SELF_AVOIDANCE = !SELF_AVOIDANCE;
    resetAgents();
  }
  if (key==' ') {
    doSave=true;
  }
}

void mousePressed() {
  Vec2D m=new Vec2D(mouseX,mouseY);
  for(Pole p : poles) {
    if (p.distanceToSquared(m) < 400) {
      p.charge *= -1;
      resetAgents();
      return;
    }
  }
}

void initSimulation() {
  poles.clear();
  for (int i = 0; i < NUM_POLES; i++) {
    poles.add(new Pole(new Circle(width/2, height/2, height/2).getRandomPoint(), makeCharge(5)));
  }
  resetAgents();
}

void resetAgents() {
  agents.clear();
  for (Pole p : poles) {
    for (int i = 0; i < NUM_AGENTS; i++) {
      agents.add(new Agent(p, i*(TWO_PI / NUM_AGENTS), SPEED));
    }
  }
}

float makeCharge(float c) {
  if (MathUtils.flipCoin()) c = -c;
  return c;
}

class Pole extends Vec2D {
  float charge;

  Pole(Vec2D p, float c) {
    super(p);
    charge = c;
  }
}

class Agent {
  Pole parent;
  Vec2D pos;
  float targetDist;
  float speed;
  boolean isAlive = true;

  List<Vec2D> path = new LinkedList<Vec2D>();

  Agent(Pole p, float theta, float speed) {
    path.add(p.copy());
    this.pos=p.add(new Vec2D(speed, theta).toCartesian());
    this.targetDist = sq(speed * 0.9);
    this.speed = speed;
    this.parent = p;
  }

  void update(List<Pole> poles) {
    if (isAlive) {
      Vec2D dir = new Vec2D();
      Vec2D target = null;
      for (Pole p : poles) {
        Vec2D d = pos.sub(p);
        float mag = d.magSquared();
        if (mag < targetDist) {
          isAlive=false;
          target=p;
          break;
        }
        if (p!=parent || !SELF_AVOIDANCE) {
          dir.addSelf(d.scaleSelf(p.charge / mag));
        } 
        else {
          dir.addSelf(d.scaleSelf(abs(p.charge) / mag));
        }
      }
      dir.normalize();
      if (isAlive) {
        path.add(pos.copy());
        pos.addSelf(dir.scale(speed));
        isAlive=pos.isInRectangle(bounds);
      } 
      else {
        if (target != null) path.add(target.copy());
      }
    }
  }
}
