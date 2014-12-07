import toxi.geom.*;
import toxi.color.*;
import toxi.processing.*;
import java.util.*;

HashMap<String, Person> foodies = new HashMap<String, Person>();
HashMap<String, Category> cats = new HashMap<String, Category>();

ToxiclibsSupport gfx;

int GRAPH_RADIUS = 160;
boolean SHOW_SEGMENTS = false;
float LABEL_THETA_OFFSET = 0.02;
float CAT_GAP = 0.02;
float CURVATURE = 0.6666;

void setup() {
  size(1280, 720);
  smooth();
  gfx = new ToxiclibsSupport(this);
  foodies = parseCSV("20141206-sac-foodies - Sheet1.csv");
  cats = createCategories();
}

void draw() {
  background(51);
  translate(width/2, height/2);
  for (Category c : cats.values ()) {
    c.draw(GRAPH_RADIUS, GRAPH_RADIUS + 50);
  }
  for (Person person : foodies.values ()) {
    List<Vec2D> endPoints = matchingFood(person, cats.get("food"));
    Vec2D sp = cats.get("people").getPositionFor(person.name);
    Vec2D spc = sp.scale(1.0-CURVATURE);
    gfx.stroke(person.col.setAlpha(0.5));
    noFill();
    for (Vec2D ep : endPoints) {
      Vec2D epc = ep.scale(1.0-CURVATURE);
      bezier(sp.x, sp.y, spc.x, spc.y, epc.x, epc.y, ep.x, ep.y);
    }
  }
  //saveFrame("foo.png");
  //exit();
}

List<Vec2D> matchingFood(Person p, Category dest) {
  List<Vec2D> matches = new ArrayList<Vec2D>();
  for (String f : p.food) {
    Vec2D ip = dest.getPositionFor(f);
    if (ip != null) {
      matches.add(ip);
    }
  }
  return matches;
} 

