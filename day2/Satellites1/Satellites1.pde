import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import java.util.*;

float radius = 50;

VerletPhysics2D physics;

AttractionBehavior2D attractor;

void setup() {
  size(600,600);
  ellipseMode(RADIUS);
  
  physics = new VerletPhysics2D();
  physics.setWorldBounds(new Rect(0,0, width, height));
  physics.addBehavior(new GravityBehavior2D(new Vec2D(0, 0.15f)));
  for(int i=0; i<200; i++) {
    physics.addParticle(new VerletParticle2D(random(width),random(height))); 
  }
  attractor = new AttractionBehavior2D(new Vec2D(), 200, 2);
  physics.addBehavior(attractor);
}

void draw() {
  physics.update();
  background(255);
  fill(0);
  Vec2D attractor.getAttractor();
  .set(mouseX, mouseY);
  ellipse(attractor.x, attractor.y, radius, radius);
  for(Vec2D s : physics.particles) {
    ellipse(s.x, s.y, 10, 10);
  }
}
