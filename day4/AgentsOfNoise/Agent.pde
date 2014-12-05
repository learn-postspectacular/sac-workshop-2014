class Agent extends Vec2D {

  Vec3D currNormal = new Vec3D(0, 1, 0);
  Vec3D pos, prev;
  Vec3D spL, spR;

  IsectData3D isec;

  TColor col;

  float currTheta;
  float targetTheta;
  float targetSpeed;
  float speed;

  FloatRange elRange;
  float targetElevation;

  float steer, defaultSteer;
  float weight;
  int steerLock;

  Agent(float x, float z, FloatRange el) {
    super(x, z);
    pos = new Vec3D(x, 0, z);
    prev = pos.copy();
    targetTheta = random(-1, 1) * TWO_PI;
    targetSpeed = SPEED_RANGE.pickRandom();
    elRange = el;
    pickNewTargetElevation();
    steer = random(0.3, 0.35);
    defaultSteer = (random(1) < 0.5 ? -1 : 1) * 0.4;
    weight = random(0.5, 2);
  }

  void steer(float t) {
    targetTheta += t;
  }

  void pickNewTargetElevation() {
    targetElevation = elRange.pickRandom();
    float hue = USE_EL_HUE ? BASE_HUE + targetElevation / HUE_COMPRESS + random(0.14) : BASE_HUE + random(0.14);
    col = TColor.newHSV(hue, random(0.25, 0.9), random(0.1));
  }

  Vec3D scan(float scanTheta) {
    Vec2D scanDir = Vec2D.fromTheta(currTheta+scanTheta).scaleSelf(SCAN_DIST);
    Vec2D scanPos = pos.to2DXZ().add(scanDir);
    IsectData3D isec = terra.intersectAtPoint(scanPos.x, scanPos.y);
    if (isec.isIntersection) {
      return isec.pos.add(0, 10, 0);
    }
    return null;
  }

  void update() {
    if (steerLock == 0) {
      spL = scan(SCAN_THETA);
      spR = scan(-SCAN_THETA);
      if (spL != null && spR != null) {
        float dL = Math.abs(spL.y - targetElevation);
        float dR = Math.abs(spR.y - targetElevation);
        if (dL < dR) {
          steer(steer);
        } else {
          steer(-steer);
        }
        if (Math.min(dL, dR) < 1) {
          pickNewTargetElevation();
        }
      } else {
        steer(defaultSteer);
        if (random(1)<0.1) {
          pickNewTargetElevation();
        }
      }
    } else {
    }
    // interpolate steering & speed
    currTheta += (targetTheta - currTheta) * 0.2f;
    speed += (targetSpeed - speed) * 0.1f;
    // update position
    addSelf(Vec2D.fromTheta(currTheta).scaleSelf(speed));
    // constrain position to terrain size in XZ plane
    AABB b = terrainMesh.getBoundingBox();
    constrain(new Rect(b.getMin().to2DXZ(), b.getMax().to2DXZ()).scale(0.99f));
    // compute intersection point on terrain surface
    isec = terra.intersectAtPoint(x, y);
    if (isec.isIntersection) {
      // smoothly update normal
      currNormal.interpolateToSelf(isec.normal, 0.25f);
      // move bot slightly above terrain
      prev.set(pos);
      pos = isec.pos.add(0, 10, 0);
    }
  }

  void draw2D() {
    stroke(col.toARGB());
    strokeWeight(weight);
    line(prev.x, prev.z, pos.x, pos.z);
  }

  void draw3D() {
    // create an axis aligned box and convert to mesh
    TriangleMesh box = (TriangleMesh)new AABB(new Vec3D(), new Vec3D(5, 2, 2)).toMesh();
    // align to terrain normal
    box.pointTowards(currNormal);
    // rotate into direction of movement
    box.rotateAroundAxis(currNormal, currTheta);
    // move to correct position
    box.translate(pos);
    fill(255, 0, 0);
    // and draw
    gfx.mesh(box);
    // draw feelers
    strokeWeight(1);
    if (spL != null) {
      stroke(0, 0, 255);
      gfx.line(pos, spL);
      fill(0, 0, 255);
      noStroke();
      gfx.sphere(new Sphere(spL, 3), 6);
    }
    if (spR != null) {
      stroke(0, 255, 0);
      gfx.line(pos, spR);
      fill(0, 255, 0);
      noStroke();
      gfx.sphere(new Sphere(spR, 3), 6);
    }
  }
}

