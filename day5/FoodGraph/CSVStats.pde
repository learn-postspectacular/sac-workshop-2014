HashMap<String, Person> parseCSV(String path) {
  HashMap<String, Person> index = new HashMap<String, Person>();
  String[] lines = loadStrings(path);
  for (int i = 1; i < lines.length; i++) {
    String l = lines[i];
    String[] columns = split(l, ",");
    Person p = new Person();
    p.name = columns[0].toLowerCase().trim();
    p.isFemale = columns[11].equalsIgnoreCase("f");
    p.country = columns[12].toLowerCase().trim();
    p.col = TColor.newHex(columns[13].substring(1).trim());
    for (int j = 1; j < 11; j++) {
      p.food.add(columns[j].toLowerCase().trim());
    }
    index.put(p.name, p);
  }
  return index;
}

Set<String> uniqueFoodChoices() {
  Set<String> unique = new HashSet<String>();
  for (Person p : foodies.values()) {
    unique.addAll(p.food);
  }
  println("unique food: " + unique);
  return unique;
}

Set<String> uniqueCountries() {
  Set<String> unique = new HashSet<String>();
  for (Person p : foodies.values()) {
    unique.add(p.country);
  }
  println("unique countries: " + unique);
  return unique;
}

