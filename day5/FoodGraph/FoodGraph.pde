// CSV based chord graph of workshop participants, their food likes, gender and
// country of origin
// Demonstrates how to parse CSV files, basic data cleanup, aggregate unique values
// and of course how to visualize connections in the form of the standard chord graph
//
// Example also served as typical usecase for working with HashMaps & Sets and much of
// the key functionality is based on extensive use of these data structures
//
// Key controls:
// space - export screenshot (in sketch folder)
// 1 - 3 - only show connections to selected category
// any other key - display all connections
//
// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LGPLv3 licensed

import toxi.geom.*;
import toxi.color.*;
import toxi.processing.*;
import toxi.util.*;
import java.util.*;

HashMap<String, Person> people = new HashMap<String, Person>();
HashMap<String, Category> categories = new HashMap<String, Category>();
Set<String> displayCategories = null;

ToxiclibsSupport gfx;

float R1 = 160;
float R2 = R1 + 50;
boolean SHOW_SEGMENTS = true;
float LABEL_THETA_OFFSET = 0.02;
float CAT_GAP = 0.02;
float CURVATURE = 0.3333;

TColor COL_BG = TColor.newGray(0.2);
TColor COL_CATEGORY = TColor.newGray(0.8);
TColor COL_STROKE = TColor.newGray(1);
TColor COL_LABEL = TColor.newGray(1);

void setup() {
  size(1280, 720);
  smooth();
  gfx = new ToxiclibsSupport(this);
  people = parseCSV("20141206-sac-foodies - Sheet1.csv");
  categories = createCategories();
  // configure drawing of connections for all categories
  displayCategories = new HashSet<String>(categories.keySet());
  displayCategories.remove("people");  
}

void draw() {
  background(COL_BG.toARGB());
  translate(width/2, height/2);
  // draw categories
  for (Category c : categories.values ()) {
    c.draw();
  }
  // draw connections to all currently active categories
  noFill();
  Category peopleCat = categories.get("people");
  for (Person person : people.values ()) {
    for (String catID : displayCategories) {
      List<Vec2D> endPoints = computeConnectionEndPoints(person, catID);
      if (endPoints != null) {
        gfx.stroke(person.col.setAlpha(0.5));
        // Define 1st two control points of bezier curve
        Vec2D sp = peopleCat.getPositionFor(person.name);
        Vec2D spc = sp.scale(1.0 - CURVATURE);
        for (Vec2D ep : endPoints) {
          // compute 3rd bezier control point (last one is end point)
          Vec2D epc = ep.scale(1.0 - CURVATURE);
          bezier(sp.x, sp.y, spc.x, spc.y, epc.x, epc.y, ep.x, ep.y);
        }
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    saveFrame("foodgraph-" + DateUtils.timeStamp() + ".png");
  } else {
    displayCategories = new HashSet<String>(categories.keySet());
    displayCategories.remove("people");
    if (key >= '1' && key < '1' + displayCategories.size()) {
      List<String> ids = new LinkedList<String>(displayCategories);
      for (int i=0; i < ids.size (); i++) {
        if (i != (key - '1')) {
          displayCategories.remove(ids.get(i));
        }
      }
    }
  }
}

List<Vec2D> computeConnectionEndPoints(Person p, String catID) {
  List<Vec2D> endPoints = new ArrayList<Vec2D>();
  HashSet<String> items = p.getItemsForCategory(catID);
  // check if category is actually valid
  if (items != null) {
    Category cat = categories.get(catID);
    // collect positions for all valid items (should be all, but check just to be safe...)
    for (String i : items) {
      Vec2D pos = cat.getPositionFor(i);
      if (pos != null) {
        endPoints.add(pos);
      }
    }
    return endPoints;
  }
  return null;
} 

