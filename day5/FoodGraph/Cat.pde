HashMap<String, Category> createCategories() {
  Set<String> uniqueFood = uniqueFoodChoices();
  Set<String> uniqueCountries = uniqueCountries();
  Set<String> genderSet = new HashSet<String>();
  genderSet.add("female");
  genderSet.add("male");
  int numPeople = foodies.size();
  int numCountries = uniqueCountries.size();
  int numFood = uniqueFood.size();
  int numGenders = 2;
  int total = numPeople + numCountries + numFood + numGenders;
  float itemTheta = radians(360.0 / total);
  Category catFood = new Category("Food", numFood, 0, itemTheta).setValues(uniqueFood);
  Category catPeople = new Category("People", numPeople, catFood.endTheta, itemTheta).setValues(foodies.keySet());
  Category catCountries = new Category("Countries", numCountries, catPeople.endTheta, itemTheta).setValues(uniqueCountries);
  Category catGenders = new Category("Gender", numGenders, catCountries.endTheta, itemTheta).setValues(genderSet);
  HashMap<String, Category> cats = new HashMap<String, Category>();
  cats.put("food", catFood);
  cats.put("people", catPeople);
  cats.put("countries", catCountries);
  cats.put("gender", catGenders);
  return cats;
}

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
    startTheta += CAT_GAP;
    itemTheta = (endTheta - CAT_GAP - startTheta) / numItems;
  }

  Category setValues(Set<String> vals) {
    uniques = vals;
    sorted = new ArrayList<String>();
    sorted.addAll(vals);
    Collections.sort(sorted);
    return this;
  }

  void draw(float r1, float r2) {
    noFill();
    stroke(255);
    // draw boundary polygon of section
    gfx.polygon2D(createArc(r1, r2));
    // draw item dividers & item labels
    for (int i=0; i < numItems; i++) {
      if (SHOW_SEGMENTS) {
        gfx.line(
        new Vec2D(r1, startTheta + i * itemTheta).toCartesian(), 
        new Vec2D(r2, startTheta + i * itemTheta).toCartesian()
          );
      }
      drawLabel(new Vec2D(r2 + 10, startTheta + (i + 0.5) * itemTheta), sorted.get(i));
    }
    // draw category label
    float labelRadius = r2 + 110;
    noFill();
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
      for (int i = 0; i < numItems; i++) {
        if (itemName.equalsIgnoreCase(sorted.get(i))) {
          return new Vec2D(GRAPH_RADIUS - 2, startTheta + (i + 0.5) * itemTheta).toCartesian();
        }
      }
    }
    return null;
  }
}

