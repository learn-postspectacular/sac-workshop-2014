class Category {
  String name;
  int numItems;
  float startTheta;
  float endTheta;
  float itemTheta;
  Set<String> uniques;
  List<String> sorted;

  Category(String name, int num, float start, float it) {
    this.name = name;
    numItems = num;
    startTheta = start;
    itemTheta = it;
    endTheta = startTheta + numItems * itemTheta;
  }

  Category setValues(Set<String> vals) {
    uniques = vals;
    sorted = new ArrayList<String>();
    sorted.addAll(vals);
    Collections.sort(sorted);
    return this;
  }

  void draw(float radius, float radius2) {
    noFill();
    stroke(255);
    // draw boundary polygon of section
    gfx.polygon2D(createArc(radius, radius2));
    // draw item dividers & item labels
    for (int i=0; i < numItems; i++) {
      float r2 = (i == 0) ? radius2 + 50 : radius2;
      gfx.line(
      new Vec2D(radius, startTheta + i * itemTheta).toCartesian(), 
      new Vec2D(r2, startTheta + i * itemTheta).toCartesian()
        );
      drawLabel(new Vec2D(radius2 + 10, startTheta + (i + 0.5) * itemTheta), sorted.get(i));
    }
    // draw category label
    drawLabel(new Vec2D(radius2 + 100, (startTheta + endTheta) * 0.5), name);
  }

  void drawLabel(Vec2D lp, String label) {  
    Vec2D lc = lp.copy().toCartesian();
    pushMatrix();
    translate(lc.x, lc.y);
    rotate(lp.y);
    fill(255);
    text(label, 0, 0);
    popMatrix();
  }

  Polygon2D createArc(float r1, float r2) {
    Polygon2D arc = new Polygon2D();
    for (int i = 0; i <= numItems; i++) {
      Vec2D p = new Vec2D(r1, startTheta + i * itemTheta).toCartesian();
      arc.add(p);
    }
    for (int i = numItems; i >= 0; i--) {
      Vec2D p = new Vec2D(r2, startTheta + i * itemTheta).toCartesian();
      arc.add(p);
    }
    return arc;
  }
  
  Vec2D getPositionFor(String itemName) {
    if (uniques.contains(itemName)) {
      for(int i = 0; i < numItems; i++) {
        if (itemName.equalsIgnoreCase(sorted.get(i))) {
          return new Vec2D(GRAPH_RADIUS, startTheta + (i + 0.5) * itemTheta).toCartesian();
        }
      }
    }
    return null;
  }
}

