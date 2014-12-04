void exportCityMesh() {
  TriangleMesh combined = new TriangleMesh();
  for (Vec2D p : physics.particles) {
    AreaType atype = (AreaType)p;
    combined.addMesh(atype.getMesh(40));
  }
  combined.saveAsSTL(sketchPath("clusters.stl"));
}
