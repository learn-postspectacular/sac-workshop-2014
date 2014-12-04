import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;
import toxi.util.datatypes.*;
import toxi.processing.*;
import toxi.math.*;

import java.util.*;

float radius = 50;

VerletPhysics2D physics;

AttractionBehavior2D attractor;

HashMap<String, List<AreaType>> clusterMap = new HashMap<String, List<AreaType>>();

ToxiclibsSupport gfx;

void createAndAddClusterLists(String key, AreaType t) {
  if (clusterMap.get(key) == null) {
    List<AreaType> group = new ArrayList<AreaType>();
    group.add(t);
    clusterMap.put(key, group);
  } else {
    clusterMap.get(key).add(t);
  }
}

void setup() {
  size(1000, 600, P3D);
  ellipseMode(RADIUS);
  gfx=new ToxiclibsSupport(this);
  
  WeightedRandomSet<String> areaTypes = new WeightedRandomSet<String>();
  areaTypes.add("green", 20);
  areaTypes.add("res", 50);
  areaTypes.add("ind", 70);
  areaTypes.add("biz", 15);

  physics = new VerletPhysics2D();
  physics.setDrag(0.05);
  Polygon2D poly=new Circle(0, 0, height/2).toPolygon2D(6);
  physics.addConstraint(new PolygonConstraint(poly, true));
  //physics.setWorldBounds(new Rect(50, 50, 600, height-100));
  //physics.addBehavior(new GravityBehavior2D(new Vec2D(0, 0.15f)));
  for (int i=0; i < 80; i++) {
    AreaType p = null;
    String type = areaTypes.getRandom();
    if (type.equals("res")) {
      p = new ResidentialArea(random(width), random(height));
      createAndAddClusterLists("res", p);
    } else if (type.equals("ind")) {
      p = new IndustrialArea(random(width), random(height));
      createAndAddClusterLists("ind", p);
    } else if (type.equals("green")) {
      p = new GreenArea(random(width), random(height));
      createAndAddClusterLists("green", p);
    } else if (type.equals("biz")) {
      p = new BusinessArea(random(width), random(height));
      createAndAddClusterLists("biz", p);
    }
    AttractionBehavior2D ap = new AttractionBehavior2D(p, p.size * 3, -0.5, 0.1);
    physics.addParticle(p); 
    physics.addBehavior(ap);
  }
  
  for(String group : clusterMap.keySet()) {
    List<AreaType> items = clusterMap.get(group);
    int num = items.size();
    for(int i=0; i < num; i++) {
      VerletSpring2D s = new VerletSpring2D(items.get(MathUtils.random(num)), items.get(i), 60, 0.0001);
      physics.addSpring(s);
    }
  }
  attractor = new AttractionBehavior2D(new Vec2D(), 100, 1);
  physics.addBehavior(attractor);
}

void draw() {
  physics.update();
  background(255);
  translate(width/2, height/2, 0);
  rotateX(PI/3);
  Vec2D apos = attractor.getAttractor();
  apos.set(mouseX, mouseY);
  stroke(0);
  noFill();
  ellipse(apos.x, apos.y, 100, 100);
  fill(0);
  for (Vec2D p : physics.particles) {
    AreaType atype = (AreaType)p;
    atype.render();
  }
  // visualize spring
  for (VerletSpring2D s : physics.springs) {
    line(s.a.x, s.a.y, s.b.x, s.b.y);
  }
  fill(0);
  text("frame: "+frameCount, 20, 20);
}

void keyPressed() {
  if (key == ' ') {
    exportCityMesh();
  }
}
