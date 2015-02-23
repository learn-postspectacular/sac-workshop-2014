class AreaType extends VerletParticle2D {
  float size;
  color col;
  
  AreaType(float x, float y) {
    super(x,y);
  }
  
  void render() {
    fill(col);
    ellipse(x, y, size, size);
  }
}

class ResidentialArea extends AreaType {
  
  ResidentialArea(float x, float y) {
    super(x,y);
    size = random(20, 50);
    col = color(255, 230, 230);
  }
}

class IndustrialArea extends AreaType {
  
  IndustrialArea(float x, float y) {
    super(x,y);
    size = random(20,50);
    col = color(230, 230, 255);
  }
}

class GreenArea extends AreaType {
  
  GreenArea(float x, float y) {
    super(x,y);
    size = random(20,50);
    col = color(200, 255, 200);
  }
}

