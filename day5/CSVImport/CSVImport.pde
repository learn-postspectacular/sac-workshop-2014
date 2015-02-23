// A more extensive explanation & working with HashMap datastructures
// Example shows how to parse a CSV file/spreadsheet into a hash map
// and then computes a couple of aggregate stats
// Used as basis for FoodGraph chord visualization example (see other sketch in same folder)
//
// Created during & for workshop at Städelschule Frankfurt
// (c) 2014 Karsten Schmidt // LGPLv3 licensed

import java.util.*;

HashMap<String, List<Integer>> areas = new HashMap<String, List<Integer>>();

void setup() {
  areas = parseCSV("od-cocaine.csv");
  AreaValue winner = getMaxValueArea();
  AreaValue loser = getMinValueArea();
  println("druglord is " + winner.name + " highscore: " + winner.value);
  println("drugloser is " + loser.name + " score: " + loser.value);
}

HashMap<String, List<Integer>> parseCSV(String path) {
  HashMap<String, List<Integer>> index = new HashMap<String, List<Integer>>();
  String[] lines = loadStrings(path);
  for (int i = 1; i < lines.length - 2; i++) {
    String l = lines[i];
    String[] cols = split(l, ",");
    if (cols.length > 3) {
      List<Integer> values = new ArrayList<Integer>();
      for (int j = 3; j < cols.length; j++) {
        values.add(int(cols[j]));
      }
      index.put(cols[2], values);
    }
  }
  return index;
}

int totalAreaSum(List<Integer> values) {
  int total = 0;
  for (Integer v : values) {
    total += v;
  }
  return total;
}

float avgAreaValue(List<Integer> values) {
  return totalAreaSum(values) / values.size();
}

AreaValue getMinValueArea() {
  int minV = 1000000;
  String minName = null;
  for (String name : areas.keySet()) {
    int sum = totalAreaSum(areas.get(name));
    if (sum < minV) {
      minV = sum;
      minName = name;
    }
  }
  return new AreaValue(minName, minV);
}

AreaValue getMaxValueArea() {
  int maxV = 0;
  String maxName = null;
  for (String name : areas.keySet ()) {
    int sum = totalAreaSum(areas.get(name));
    if (sum > maxV) {
      maxV = sum;
      maxName = name;
    }
  }
  return new AreaValue(maxName, maxV);
}

class AreaValue {
  String name;
  float value;

  AreaValue(String n, float v) {
    name = n;
    value = v;
  }
}

