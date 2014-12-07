HashMap<String, Category> createCategories() {
  Set<String> uniqueFood = uniqueFoodChoices();
  Set<String> uniqueCountries = uniqueCountries();
  Set<String> genders = new HashSet<String>();
  genders.add("female");
  genders.add("male");
  // compute category sizes & total number of items
  int numPeople = people.size();
  int numCountries = uniqueCountries.size();
  int numFood = uniqueFood.size();
  int numGenders = 2;
  int total = numPeople + numCountries + numFood + numGenders;
  // item size in radians
  float itemTheta = radians(360.0 / total);
  // create categories and arrange around circle
  Category catFood = new Category("food", numFood, 0, itemTheta).setValues(uniqueFood);
  Category catPeople = new Category("people", numPeople, catFood.endTheta, itemTheta).setValues(people.keySet());
  Category catCountries = new Category("countries", numCountries, catPeople.endTheta, itemTheta).setValues(uniqueCountries);
  Category catGenders = new Category("gender", numGenders, catCountries.endTheta, itemTheta).setValues(genders);
  // store categories in own index map
  HashMap<String, Category> cats = new HashMap<String, Category>();
  cats.put(catFood.name, catFood);
  cats.put(catPeople.name, catPeople);
  cats.put(catCountries.name, catCountries);
  cats.put(catGenders.name, catGenders);
  return cats;
}

class Category {
  String name;
  int numItems;
  float startTheta;
  float endTheta;
  float itemTheta;
  List<String> sorted;
  Polygon2D poly;

  Category(String name, int num, float start, float it) {
    this.name = name;
    numItems = num;
    startTheta = start;
    itemTheta = it;
    endTheta = startTheta + numItems * itemTheta;
    startTheta += CAT_GAP;
    itemTheta = (endTheta - CAT_GAP - startTheta) / numItems;
    poly = createArc(R1, R2);
  }

  Category setValues(Set<String> vals) {
    sorted = new ArrayList<String>(vals);
    Collections.sort(sorted);
    return this;
  }

  void draw() {
    noStroke();
    gfx.fill(COL_CATEGORY);
    // draw boundary polygon of section
    gfx.polygon2D(poly);
    // draw item dividers & item labels
    for (int i=0; i < numItems; i++) {
      if (SHOW_SEGMENTS) {
        gfx.stroke(COL_BG);
        gfx.line(
        new Vec2D(R1, startTheta + i * itemTheta).toCartesian(), 
        new Vec2D(R2, startTheta + i * itemTheta).toCartesian()
          );
      }
      drawLabel(new Vec2D(R2 + 10, startTheta + (i + 0.5) * itemTheta), sorted.get(i));
    }
    // draw category label and outer arc
    float labelRadius = R2 + 110;
    noFill();
    gfx.stroke(COL_LABEL);
    arc(0, 0, labelRadius * 2, labelRadius * 2, startTheta, endTheta);
    gfx.line(
    new Vec2D(labelRadius-10, startTheta).toCartesian(), 
    new Vec2D(labelRadius, startTheta).toCartesian());
    gfx.line(
    new Vec2D(labelRadius-10, endTheta).toCartesian(), 
    new Vec2D(labelRadius, endTheta).toCartesian());
    drawLabel(new Vec2D(labelRadius + 10, (startTheta + endTheta) * 0.5), name);
  }

  void drawLabel(Vec2D lp, String label) {    
    pushMatrix();
    // if label/angle in left half of circle
    // draw label rotated for better legibility
    if (lp.y > HALF_PI && lp.y < PI + HALF_PI) {
      lp.y -= LABEL_THETA_OFFSET;
      Vec2D lc = lp.copy().toCartesian();
      translate(lc.x, lc.y);
      rotate(lp.y);
      scale(-1);
      textAlign(RIGHT);
    } else {
      lp.y += LABEL_THETA_OFFSET;
      Vec2D lc = lp.copy().toCartesian();
      translate(lc.x, lc.y);
      rotate(lp.y);
      textAlign(LEFT);
    }
    gfx.fill(COL_LABEL);
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
    for (int i = 0; i < numItems; i++) {
      if (itemName.equalsIgnoreCase(sorted.get(i))) {
        return new Vec2D(R1 - 2, startTheta + (i + 0.5) * itemTheta).toCartesian();
      }
    }
    return null;
  }
}

