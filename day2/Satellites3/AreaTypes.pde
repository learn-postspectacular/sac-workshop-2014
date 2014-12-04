class AreaType extends VerletParticle2D {
  float size;
  float elevation;
  color col;

  AreaType(float x, float y) {
    super(x, y);
  }

  TriangleMesh getMesh(int res) {
    TriangleMesh m = (TriangleMesh)new ZAxisCylinder(new Vec3D(x,y,0), size, elevation).toMesh(res, 0);
    m.transform(new Matrix4x4().translate(0, 0, elevation / 2));
    return m;
  }
  
  void render() {
    fill(col);
    gfx.mesh(getMesh(15));
  }
}

class ResidentialArea extends AreaType {

  ResidentialArea(float x, float y) {
    super(x, y);
    size = random(20, 50);
    elevation = random(2, 5);
    col = color(255, 230, 230);
  }
}

class IndustrialArea extends AreaType {

  IndustrialArea(float x, float y) {
    super(x, y);
    size = random(20, 50);
    elevation = random(5, 15);
    col = color(230, 230, 255);
  }
}

class BusinessArea extends AreaType {

  BusinessArea(float x, float y) {
    super(x, y);
    size = random(20, 50);
    elevation = random(50, 100);
    col = 0xffd8b63b;
  }
}

class GreenArea extends AreaType {

  GreenArea(float x, float y) {
    super(x, y);
    size = random(20, 50);
    elevation = random(1, 10);
    col = color(200, 255, 200);
  }
}

