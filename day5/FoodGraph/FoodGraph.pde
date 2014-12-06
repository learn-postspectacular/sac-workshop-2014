import toxi.geom.*;
import toxi.color.*;
import toxi.processing.*;

import java.util.*;

HashMap<String, Person> foodies = new HashMap<String, Person>();
HashMap<String, Category> cats = new HashMap<String, Category>();

ToxiclibsSupport gfx;

int GRAPH_RADIUS = 180;

void setup() {
  size(1280, 720);
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
    Vec2D startPoint = cats.get("people").getPositionFor(person.name);
    gfx.stroke(person.col);
    for (Vec2D ep : endPoints) {
      gfx.line(startPoint, ep);
    }
  }
}

HashMap<String, Person> parseCSV(String path) {
  HashMap<String, Person> index = new HashMap<String, Person>();
  String[] lines = loadStrings(path);
  for (int i = 1; i < lines.length; i++) {
    String l = lines[i];
    String[] columns = split(l, ",");
    Person p = new Person();
    p.name = columns[0].toLowerCase();
    p.isFemale = columns[11].equalsIgnoreCase("f");
    p.country = columns[12];
    p.col = TColor.newHex(columns[13].substring(1));
    for (int j = 1; j < 11; j++) {
      p.food.add(columns[j].toLowerCase().trim());
    }
    index.put(p.name, p);
  }
  return index;
}

Set<String> uniqueFoodChoices() {
  Set<String> all = new HashSet<String>();
  for (Person p : foodies.values ()) {
    all.addAll(p.food);
  }
  println("total food likes: "+all);
  return all;
}

Set<String> uniqueCountries() {
  Set<String> all = new HashSet<String>();
  for (Person p : foodies.values ()) {
    all.add(p.country);
  }
  println("unique countries: " + all);
  return all;
}

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

