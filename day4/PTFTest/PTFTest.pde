import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.mesh.subdiv.*;
import toxi.processing.*;
import toxi.util.*;

import java.util.*;

int RES = 400;

int K1 = 2;
int K2 = 7;
float K3 = 2.5;

TriangleMesh mesh;
ToxiclibsSupport gfx;

void setup() {
  size(600, 600, P3D);
  gfx = new ToxiclibsSupport(this);
  List<Vec3D> points = new ArrayList<Vec3D>();
  for (int i=0; i<RES; i++) {
    points.add(cinquefoil((float)i/RES, 100));
  }
  PTFGen ptf = new PTFGen(points, true);
  ptf.alignFrames();
  //mesh = ptf.sweepProfile(new Circle(40).toPolygon2D(6).vertices);
  List<TriangleMesh> meshes = ptf.sweepStrands(40, 12, 7, new Circle(10).toPolygon2D(18).vertices);
  mesh = new TriangleMesh();
  for (TriangleMesh m : meshes) {
     mesh.addMesh(m); 
  }
  mesh.saveAsSTL(sketchPath(DateUtils.timeStamp()+".stl"));
}

void draw() {
  background(51);
  lights();
  noStroke();
  translate(width/2, height/2, 0);
  rotateX(mouseY * 0.01);
  rotateY(mouseX * 0.01);
  gfx.mesh(mesh, false);
}

Vec3D cinquefoil(float t, float s) {
  t *= TWO_PI;
  float pt = K1 * t;
  float qt = K2 * t;
  float qc = K3 + cos(qt);
  return new Vec3D(cos(pt) * qc, sin(pt) * qc, sin(qt)).scaleSelf(s);
}

// Parallel Transport Frames
// ported from thi.ng/geom
// https://github.com/thi-ng/geom/blob/master/geom-types/src/ptf.org

class PTF {
  Vec3D n, bn;

  PTF(Vec3D n, Vec3D bn) {
    this.n = n;
    this.bn = bn;
  }
}

class PTFGen {
  List<Vec3D> points;
  List<Vec3D> tangents;
  List<PTF> frames;
  boolean isClosed;

  PTFGen(List<Vec3D> points, boolean isClosed) {
    this.points = points;
    this.isClosed = isClosed;
    computeFrames();
  }

  List<Vec3D> computeTangents() {
    int num = points.size();
    tangents = new ArrayList<Vec3D>(num);
    for (int i = 1; i < num; i++) {
      tangents.add(points.get(i).sub(points.get(i-1)).normalize());
    }
    if (isClosed) {
      tangents.add(points.get(0).sub(points.get(num-1)).normalize());
    } else {
      tangents.add(tangents.get(tangents.size()-1));
    }
    return tangents;
  }

  PTF computeFirstFrame() {
    Vec3D t = tangents.get(0).getAbs();
    int i = t.x < t.y ? 0 : 1;
    i = t.z < t.getComponent(i) ? 2 : i;
    Vec3D n = new Vec3D().setComponent(i, 1);
    n = t.cross(t.cross(n).normalize());
    return new PTF(n, t.cross(n));
  }

  PTF computeFrame(int i) {
    int ii = i - 1;
    Vec3D p = tangents.get(ii);
    Vec3D q = tangents.get(i);
    Vec3D a = p.cross(q);
    Vec3D n = frames.get(ii).n;
    if (abs(a.magSquared()) > 1e-5) {
      float theta = acos(constrain(p.dot(q), -1.0, 1.0));
      n = n.getRotatedAroundAxis(a.normalize(), theta).normalize();
    }
    return new PTF(n, q.cross(n));
  }

  List<PTF> computeFrames() {
    computeTangents();
    int num = tangents.size();
    frames = new ArrayList<PTF>();
    frames.add(computeFirstFrame());
    for (int i = 1; i < num; i++) {
      frames.add(computeFrame(i));
    }
    return frames;
  }

  void alignFrames() {
    int num = tangents.size();
    Vec3D a = frames.get(0).n;
    Vec3D b = frames.get(num-1).n;
    float theta = acos(constrain(a.dot(b), -1.0, 1.0)) / (num - 1);
    if (tangents.get(0).dot(a.cross(b)) > 0.0) {
      theta *= -1;
    }
    for (int i=1; i < num; i++) {
      Vec3D t = tangents.get(i);
      Vec3D n = frames.get(i).n.getRotatedAroundAxis(t, theta * i).normalize();
      frames.get(i).n = n;
      frames.get(i).bn = t.cross(n);
    }
  }

  Vec3D sweepPoint(Vec3D p, PTF frame, Vec2D profile) {
    return new Vec3D(
    profile.x * frame.n.x + profile.y * frame.bn.x + p.x, 
    profile.x * frame.n.y + profile.y * frame.bn.y + p.y, 
    profile.x * frame.n.z + profile.y * frame.bn.z + p.z
      );
  }

  List<Vec3D> sweepProfilePoints(List<Vec2D> profile, PTF frame, Vec3D p) {
    List<Vec3D> tx = new ArrayList<Vec3D>(profile.size());
    for (Vec2D q : profile) {
      tx.add(sweepPoint(p, frame, q));
    }
    return tx;
  }

  void buildFaces(Mesh3D mesh, List<Vec3D> prev, List<Vec3D> curr, int n) {
    for (int j = 0; j < n; j++) {
      mesh.addFace(prev.get(j), curr.get(j+1), prev.get(j+1));
      mesh.addFace(prev.get(j), curr.get(j), curr.get(j+1));
    }
  }

  TriangleMesh sweepProfile(List<Vec2D> profile) {
    int num = points.size();
    int nump = profile.size();
    TriangleMesh mesh = new TriangleMesh();
    List<Vec3D> prev = null;
    for (int i=0; i<num; i++) {
      List<Vec3D> curr = sweepProfilePoints(profile, frames.get(i), points.get(i));
      curr.add(curr.get(0));
      if (prev != null) {
        buildFaces(mesh, prev, curr, nump);
      }
      prev = curr;
    }
    if (isClosed) {
      List<Vec3D> curr = sweepProfilePoints(profile, frames.get(0), points.get(0));
      curr.add(curr.get(0));
      buildFaces(mesh, prev, curr, nump);
    }
    return mesh;
  }

  TriangleMesh sweepStrand(float r, float theta, float delta, List<Vec2D> profile) {
    int num = points.size();
    List<Vec3D> strand = new ArrayList<Vec3D>();
    for (int i=0; i < num; i++) {
      Vec2D p = new Vec2D(r+sin(i*delta*2)*30, i * delta + theta).toCartesian();
      strand.add(sweepPoint(points.get(i), frames.get(i), p));
    }
    PTFGen ptf = new PTFGen(strand, isClosed);
    ptf.alignFrames();
    return ptf.sweepProfile(profile);
  } 

  List<TriangleMesh> sweepStrands(float r, int nums, int twists, List<Vec2D> profile) {
    List<TriangleMesh> strands = new ArrayList<TriangleMesh>();
    float delta = twists * TWO_PI / (points.size() - 1);
    for(int i = 0; i < nums; i++) {
      strands.add(sweepStrand(r, i*TWO_PI/nums, delta, profile));
    }
    return strands;
  }
}

