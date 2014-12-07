class Person {
  String name;
  HashSet<String> food = new HashSet<String>();
  boolean isFemale;
  String country;
  TColor col;
  
  HashSet<String> getItemsForCategory(String cat) {
     if (cat.equalsIgnoreCase("food")) {
        return food;
     }
     else if (cat.equalsIgnoreCase("countries")) {
        HashSet<String> items = new HashSet<String>();
        items.add(country);
        return items;
     }
     else if (cat.equalsIgnoreCase("gender")) {
        HashSet<String> items = new HashSet<String>();
        items.add(isFemale ? "female" : "male");
        return items;
     }
     return null;
  }
}

