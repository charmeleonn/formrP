import java.awt.Robot;
Robot ctr;

PImage map, grassy, darkgrass, trunk, trunktop, grass, dirt, meta;

int balltimer = 0;

PGraphics HUD;

float gridSize, wallHeight, rotX, rotY, rotZ, eyeX, eyeY, eyeZ, focusX, focusY, focusZ, lrAngle, udAngle;
boolean wKey, aKey, sKey, dKey, space, shift, pressed;

ArrayList<GameObj> objects;

void setup() {
  fullScreen(P3D);
 
  perspective(PI/3, float(width)/float(height), 1, height/2/tan(radians(30))*10.0);
  noCursor();
  noSmooth();

   HUD = createGraphics(width, height, P2D);

  try {
    ctr = new Robot();
  }
  catch (Exception e) {
    e.printStackTrace();
  }

  objects = new ArrayList<GameObj>();

  map = loadImage("map.png");
  grassy = loadImage("diamondBlock.png");
  darkgrass = loadImage("mStoneBricks.png");
  trunk = loadImage("oakLogSide.png");
  trunktop = loadImage("oakLogTop.png");
  grass = loadImage("grassTop.png");
  dirt = loadImage("dirt.png");
  meta = loadImage("metapod.png");
  
  textureMode(NORMAL);

  gridSize = 100;
  wallHeight = 3;
  eyeX = map.width/2*gridSize;
  eyeY = height-gridSize;
  eyeZ = map.height/2*gridSize;
  udAngle = radians(155);
  lrAngle = radians(180);

  for (int i = 0; i < 10; i++) {
    Bee bat = new Bee();
    objects.add(bat);
  }
  
  
  
  
}

void draw() {
  background(0);
  fill(255);
  //focus();
  lightFalloff(0.25, 0.00010, 0.00000001);
  ambientLight(220, 150, 150, eyeX, eyeY, eyeZ);




  ctr.mouseMove(width/2, height/2);
  moveCam();
  camera(eyeX, eyeY, eyeZ, focusX, focusY, focusZ, 0, 1, 0);

  drawPlatform(0, -1, 0, rotX, rotY, 0);
  drawPlatform(0, wallHeight, 0, rotX, rotY, 0);
  drawMap();

  for (int i = 0; i < objects.size(); i++) {
    GameObj obj = objects.get(i);
    obj.act();
    obj.show();
    if (obj.lives == 0) {
      objects.remove(i);
      i--;
    }
  }
  balltimer += 1;
  if (pressed) {
    if (balltimer > 100) {
    pokeball bull = new pokeball();
    pokeball w = new pokeball();
    pokeball e = new pokeball();
    pokeball r = new pokeball();
    pokeball t = new pokeball();
    pokeball y = new pokeball();
    objects.add(bull);
    objects.add(w);
    objects.add(e);
    objects.add(r);
    objects.add(t);
    objects.add(y);
    
    balltimer = 0;
    }
  }
  
  HUD.beginDraw();
  HUD.clear();
  drawCrosshair();
  drawMinimap();
  HUD.endDraw();
  image(HUD, 0, 0);
  
}

void focus() {
  pushMatrix();
  translate(focusX, focusY, focusZ);
  fill(255);
  sphere(5);
  popMatrix();
}

void mousePressed() {
  pressed = true;
}

void mouseReleased() {
  pressed = false;
}


class Bee extends GameObj {
  PVector dir, dirX, dirY, dirZ, dir2d;
  float moveDelay, temp;
  int mag;

  Bee() {
    super(random(gridSize, gridSize*map.width-gridSize*2), height, random(gridSize, gridSize*map.height-gridSize*2), 50);

    mag = 1;

    dir = new PVector(0, 0, 0);
    dir.setMag(5);
    dirX = new PVector(dir.x, 0, 0);
    dirY = new PVector(0, dir.y, 0);
    dirZ = new PVector(0, 0, dir.z);
    dir2d = new PVector(dir.x, dir.y);
    moveDelay = int(random(10, 50));
  }

  void act() {
    int hitXR, hitXL, hitZB, hitZT;
    noStroke();
    hitXR = ceil((loc.x)/gridSize);
    hitXL = floor((loc.x)/gridSize);
    hitZT = ceil((loc.z)/gridSize);
    hitZB = floor((loc.z)/gridSize);

    for (int i = 0; i < mag; i++) {
      if (map.get(hitXR, hitZB) != #FFFFFF || map.get(hitXL, hitZB) != #FFFFFF) { // x collision
        dirX.mult(-1);
        loc.add(dirX);
      }
      loc.add(dirX);
      if (loc.y < height-wallHeight*gridSize+gridSize/2+25 || loc.y > height+1*gridSize-gridSize/2-25) { // y collision
        dirY.mult(-1);
        loc.add(dirY);
      }
      loc.add(dirY);
      if (map.get(hitXR, hitZB) != #FFFFFF || map.get(hitXR, hitZT) != #FFFFFF) { // z collision
        dirZ.mult(-1);
        loc.add(dirZ);
      }
      loc.add(dirZ);
    }
    fill(255);
  }

  void changeDir() { 
    dir.set(cos(radians(random(45, 135))), tan(radians(random(-11.25, 11.25))), sin(radians(random(-45, 135))));
    dir.setMag(5);
    dirX = new PVector(dir.x, 0, 0);
    dirY = new PVector(0, dir.y, 0);
    dirZ = new PVector(0, 0, dir.z);
    moveDelay = int(random(10, 50));
  }

  void show() {
    dir2d = new PVector(dirZ.z, dirX.x);
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    rotateY(radians(180)+dir2d.heading());
    rotateX(radians(20));
    beeB(0, 0, 0, 0, 0, 0, gridSize/2);
    fill(255);
    popMatrix();

    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    rotateY(radians(180)+dir2d.heading());

    pushMatrix();
    translate(0, -20, -15);
    beeH(0, 0, 0, 0, 0, 0, gridSize/2); 
    popMatrix();

    pushMatrix();
    translate(10, -10, 10);
    rotateX(radians(20));
    rotateY(radians(115));
    beeW(0, 0, 0, 0, 0, 0, gridSize/2);
    popMatrix();

    pushMatrix();
    translate(-10, -10, 10);
    rotateX(radians(20));
    rotateY(radians(65));
    beeW(0, 0, 0, 0, 0, 0, gridSize/2);
    popMatrix();

    fill(255);
    popMatrix();
  }
}



void block( 
  PImage tex, 
  float tX, 
  float tY, 
  float tZ, 
  float rX, 
  float rY, 
  float rZ, 
  float s    
  ) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);
  texture(tex);
  //top
  vertex(-1, -1, -1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, -1, 1, 1, 1);
  vertex(-1, -1, 1, 0, 1);
  //bottom
  vertex(-1, 1, -1, 0, 0);
  vertex(1, 1, -1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  //front
  vertex(-1, -1, 1, 0, 0);
  vertex(1, -1, 1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  //back
  vertex(1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1, 1, -1, 1, 1);
  vertex(1, 1, -1, 0, 1);
  //left
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1, 1, 1, 0);
  vertex(-1, 1, 1, 1, 1);
  vertex(-1, 1, -1, 0, 1);
  //right
  vertex(1, -1, 1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, 1, -1, 1, 1);
  vertex(1, 1, 1, 0, 1);
  endShape();
  popMatrix();
}

void block( 
  PImage text,
  PImage texbt, 
  PImage texf, 
  PImage texbk, 
  PImage texl, 
  PImage texr, 
  float tX, 
  float tY,
  float tZ, 
  float rX,
  float rY, 
  float rZ, 
  float s     
  ) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);
  texture(text);
  //top
  vertex(-1, -1, -1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, -1, 1, 1, 1);
  vertex(-1, -1, 1, 0, 1);
  endShape();
  //bottom
  beginShape(QUADS);
  texture(texbt);
  vertex(-1, 1, -1, 0, 0);
  vertex(1, 1, -1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  endShape();
  //front
  beginShape(QUADS);
  texture(texf);
  vertex(-1, -1, 1, 0, 0);
  vertex(1, -1, 1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  endShape();
  //back
  beginShape(QUADS);
  texture(texbk);
  vertex(1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1, 1, -1, 1, 1);
  vertex(1, 1, -1, 0, 1);
  endShape();
  //left
  beginShape(QUADS);
  texture(texl);
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1, 1, 1, 0);
  vertex(-1, 1, 1, 1, 1);
  vertex(-1, 1, -1, 0, 1);
  endShape();
  //right
  beginShape(QUADS);
  texture(texr);
  vertex(1, -1, 1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, 1, -1, 1, 1);
  vertex(1, 1, 1, 0, 1);
  endShape();
  popMatrix();
}

void block(color c, float tX, float tY, float tZ, float rX, float rY, float rZ, float s) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);
  fill(c, 50);
  //top
  vertex(-1, -1, -1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, -1, 1, 1, 1);
  vertex(-1, -1, 1, 0, 1);
  //bottom
  vertex(-1, 1, -1, 0, 0);
  vertex(1, 1, -1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  //front
  vertex(-1, -1, 1, 0, 0);
  vertex(1, -1, 1, 1, 0);
  vertex(1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);
  //back
  vertex(1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1, 1, -1, 1, 1);
  vertex(1, 1, -1, 0, 1);
  //left
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1, 1, 1, 0);
  vertex(-1, 1, 1, 1, 1);
  vertex(-1, 1, -1, 0, 1);
  //right
  vertex(1, -1, 1, 0, 0);
  vertex(1, -1, -1, 1, 0);
  vertex(1, 1, -1, 1, 1);
  vertex(1, 1, 1, 0, 1);
  endShape();
  popMatrix();
}

void beeB(
  float tX, 
  float tY, 
  float tZ, 
  float rX, 
  float rY, 
  float rZ, 
  float s   
  ) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);

  fill(130,167,81);
  //top
  vertex(-0.375, -0.625, -0.375, 0, 0); 
  vertex(0.375, -0.625, -0.375, 1, 0); 
  vertex(0.375, -0.625, 0.375, 1, 1);
  vertex(-0.375, -0.625, 0.375, 0, 1);

  vertex(-0.375, 0.625, -0.375, 0, 0);
  vertex(0.375, 0.625, -0.375, 1, 0);
  vertex(0.375, 0.625, 0.375, 1, 1);
  vertex(-0.375, 0.625, 0.375, 0, 1);

  vertex(-0.375, -0.625, 0.375, 0, 0);
  vertex(0.375, -0.625, 0.375, 1, 0);
  vertex(0.375, 0.625, 0.375, 1, 1);
  vertex(-0.375, 0.625, 0.375, 0, 1);
 
  vertex(0.375, -0.625, -0.375, 0, 0);
  vertex(-0.375, -0.625, -0.375, 1, 0);
  vertex(-0.375, 0.625, -0.375, 1, 1);
  vertex(0.375, 0.625, -0.375, 0, 1);

  vertex(-0.375, -0.625, -0.375, 0, 0);
  vertex(-0.375, -0.625, 0.375, 1, 0);
  vertex(-0.375, 0.625, 0.375, 1, 1);
  vertex(-0.375, 0.625, -0.375, 0, 1);

  vertex(0.375, -0.625, 0.375, 0, 0);
  vertex(0.375, -0.625, -0.375, 1, 0);
  vertex(0.375, 0.625, -0.375, 1, 1);
  vertex(0.375, 0.625, 0.375, 0, 1);
  endShape();
  popMatrix();
}

void beeH( 
  float tX,
  float tY,
  float tZ, 
  float rX, 
  float rY, 
  float rZ, 
  float s 
  ) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);

  fill(70);
  //top
  vertex(-0.25, -0.1875, -0.125, 0, 0); 
  vertex(0.25, -0.1875, -0.125, 1, 0);
  vertex(0.25, -0.1875, 0.125, 1, 1); 
  vertex(-0.25, -0.1875, 0.125, 0, 1);

  vertex(-0.25, 0.1875, -0.125, 0, 0);
  vertex(0.25, 0.1875, -0.125, 1, 0);
  vertex(0.25, 0.1875, 0.125, 1, 1);
  vertex(-0.25, 0.1875, 0.125, 0, 1);

  vertex(-0.25, -0.1875, 0.125, 0, 0);
  vertex(0.25, -0.1875, 0.125, 1, 0);
  vertex(0.25, 0.1875, 0.125, 1, 1);
  vertex(-0.25, 0.1875, 0.125, 0, 1);

  vertex(0.25, -0.1875, -0.125, 0, 0);
  vertex(-0.25, -0.1875, -0.125, 1, 0);
  vertex(-0.25, 0.1875, -0.125, 1, 1);
  vertex(0.25, 0.1875, -0.125, 0, 1);

  vertex(-0.25, -0.1875, -0.125, 0, 0);
  vertex(-0.25, -0.1875, 0.125, 1, 0);
  vertex(-0.25, 0.1875, 0.125, 1, 1);
  vertex(-0.25, 0.1875, -0.125, 0, 1);
 
  vertex(0.25, -0.1875, 0.125, 0, 0);
  vertex(0.25, -0.1875, -0.125, 1, 0);
  vertex(0.25, 0.1875, -0.125, 1, 1);
  vertex(0.25, 0.1875, 0.125, 0, 1);
  endShape();
  popMatrix();
}

void beeW( 
  float tX, 
  float tY,
  float tZ, 
  float rX, 
  float rY, 
  float rZ, 
  float s   
  ) {
  pushMatrix();
  translate(tX, tY, tZ);
  rotateX(rX);
  rotateY(rY);
  rotateZ(rZ);
  scale(s);

  noStroke();
  beginShape(QUADS);

  fill(255);
  //top
  vertex(-0.625, -0.1875, -0.0625, 0, 0); 
  vertex(0.625, -0.1875, -0.0625, 1, 0);
  vertex(0.625, -0.1875, 0.0625, 1, 1); 
  vertex(-0.625, -0.1875, 0.0625, 0, 1);

  vertex(-0.625, 0.1875, -0.0625, 0, 0);
  vertex(0.625, 0.1875, -0.0625, 1, 0);
  vertex(0.625, 0.1875, 0.0625, 1, 1);
  vertex(-0.625, 0.1875, 0.0625, 0, 1);
  
  vertex(-0.625, -0.1875, 0.0625, 0, 0);
  vertex(0.625, -0.1875, 0.0625, 1, 0);
  vertex(0.625, 0.1875, 0.0625, 1, 1);
  vertex(-0.625, 0.1875, 0.0625, 0, 1);
  
  vertex(0.625, -0.1875, -0.0625, 0, 0);
  vertex(-0.625, -0.1875, -0.0625, 1, 0);
  vertex(-0.625, 0.1875, -0.0625, 1, 1);
  vertex(0.625, 0.1875, -0.0625, 0, 1);

  vertex(-0.625, -0.1875, -0.0625, 0, 0);
  vertex(-0.625, -0.1875, 0.0625, 1, 0);
  vertex(-0.625, 0.1875, 0.0625, 1, 1);
  vertex(-0.625, 0.1875, -0.0625, 0, 1);
  
  vertex(0.625, -0.1875, 0.0625, 0, 0);
  vertex(0.625, -0.1875, -0.0625, 1, 0);
  vertex(0.625, 0.1875, -0.0625, 1, 1);
  vertex(0.625, 0.1875, 0.0625, 0, 1);
  endShape();
  popMatrix();
}



class pokeball extends GameObj {
  PVector dir;
  float speed;
  pokeball() {
    super(eyeX+random(-200,200), eyeY+random(-200,200), eyeZ, 10);
    speed = 50;
    dir = new PVector(cos(lrAngle), tan(udAngle), sin(lrAngle));
    dir.setMag(speed);
  }

  void act() {
    int hitX = int((loc.x+gridSize/2)/gridSize);
    int hitZ = int((loc.z+gridSize/2)/gridSize);
    if (map.get(hitX, hitZ) != #FFFFFF || loc.y < height-wallHeight*gridSize+gridSize/2 || loc.y > height+1*gridSize-gridSize/2) {
      lives = 0;
      dir.setMag(0);
      for (int i = 0; i < 5; i++) {
        objects.add(new Particle(loc));
      }
    } else {
      loc.add(dir);
    }
    noStroke();
    fill(random(0,255),random(0,255),random(0,255));
  }
}



boolean canMove(char d) {
  float x, z;
  x = z = 0;
  if (d == 'w') {
    x = eyeX + cos(lrAngle)*50;
    z = eyeZ + sin(lrAngle)*50;
  } else if (d == 'a') {
    x = eyeX + cos(lrAngle-PI/2)*50;
    z = eyeZ + sin(lrAngle-PI/2)*50;
  } else if (d == 's') {
    x = eyeX + cos(lrAngle+PI)*50;
    z = eyeZ + sin(lrAngle+PI)*50;
  } else if (d == 'd') {
    x = eyeX + cos(lrAngle+PI/2)*50;
    z = eyeZ + sin(lrAngle+PI/2)*50;
  }

  int mapX = int((x+gridSize/2)/gridSize);
  int mapY = int((z+gridSize/2)/gridSize);

  if (map.get(mapX, mapY) == #FFFFFF) {
    return true;
  }
  return false;
}


void drawMap() {
  for (int x = 0; x < map.width; x++) {
    for (int z = 0; z < map.height; z++) {
      color c = map.get(x, z);
      if (c != #ffffff) {
        for (int y = 0; y < wallHeight; y++) {
          if (c == #000000) {
            block(trunktop, trunktop, trunk, trunk, trunk, trunk, x*gridSize, height - gridSize*y, z*gridSize, rotX, rotY, rotZ, gridSize/2);
          } else {
            block(darkgrass, x*gridSize, height - gridSize*y, z*gridSize, rotX, rotY, rotZ, gridSize/2);
          }
        }
      }
    }
  }
}

void drawPlatform(float tX, float tY, float tZ, float rX, float rY, float rZ) {
  for (int x = 0; x < gridSize*map.width; x += gridSize) {
    for (int z = 0; z < gridSize*map.height; z += gridSize) {
      block(grassy, tX*gridSize+x, height - tY*gridSize, tZ*gridSize+z, rX, rY, rZ, gridSize/2);
    }
  }
}

void drawCrosshair() {
  HUD.stroke(255);
  HUD.strokeWeight(5);
  HUD.line(width/2-20, height/2, width/2+20,height/2);
  HUD.line(width/2,height/2-20,width/2,height/2+20);
}


void drawMinimap() {
 HUD.image(map,550,550,360,360);
 int miniX = int((eyeX+2000)/gridSize);
 int miniY = int((eyeZ+2000)/gridSize);
 HUD.textSize(20);
 HUD.text("X: "+miniY, 550,520);
 HUD.text("Y: "+miniY, 550,560);
 HUD.noStroke();
 HUD.fill(255,0,0);
 HUD.square(miniX*4+550,miniY*4+550,4);
}

class GameObj {
  PVector loc;
  float size;
  float lives;

  GameObj() {
    loc = new PVector(0, 0, 0);
    size = 10;
    lives = 1;
  }

  GameObj(float x, float y, float z, float s) {
    loc = new PVector(x, y, z);
    size = s;
    lives = 1;
  }

  void act() {
  }

  void show() {
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    box(size);
    popMatrix();
  }
}



void moveCam() {
  if (wKey && canMove('w')) {
    eyeX += cos(lrAngle) * 15;
    eyeZ += sin(lrAngle) * 15;
  }
  if (aKey && canMove('a')) {
    eyeX -= cos(lrAngle + PI/2) * 10;
    eyeZ -= sin(lrAngle + PI/2) * 10;
  }
  if (sKey && canMove('s')) {
    eyeX -= cos(lrAngle) * 15;
    eyeZ -= sin(lrAngle) * 15;
  }
  if (dKey && canMove('d')) {
    eyeX += cos(lrAngle + PI/2) * 10;
    eyeZ += sin(lrAngle + PI/2) * 10;
  }
  if (space) eyeY -= 10;
  if (shift) eyeY += 10;

  lrAngle += (mouseX - width/2) * .005;
  udAngle += (mouseY - height/2) * .005;
  udAngle = min(udAngle, PI/2.001);
  udAngle = max(udAngle, -PI/2.001);

  focusX = eyeX + cos(lrAngle) * 300;
  focusY = eyeY + tan(udAngle) * 300;
  focusZ = eyeZ + sin(lrAngle) * 300;
}

void keyPressed() {
  if (key == 'w' || key == 'W') wKey = true;
  if (key == 'a' || key == 'A') aKey = true;
  if (key == 's' || key == 'S') sKey = true;
  if (key == 'd' || key == 'D') dKey = true;
  if (key == ' ') space = true;
  if (keyCode == SHIFT) shift = true;
}

void keyReleased() {
  if (key == 'w' || key == 'W') wKey = false;
  if (key == 'a' || key == 'A') aKey = false;
  if (key == 's' || key == 'S') sKey = false;
  if (key == 'd' || key == 'D') dKey = false;
  if (key == ' ') space = false;
  if (keyCode == SHIFT) shift = false;
}



class Particle extends GameObj {
  PVector posO;
  PVector dir;

  Particle(PVector tempP) {
    posO = new PVector(random(-10, 10), random(-10, 10), random(-10, 10));

    loc = tempP;
    loc.add(posO);
    dir = PVector.random3D();
    size = 5;
    lives = 255;
  }

  void act() {
    int hitX = int((loc.x+gridSize/2)/gridSize);
    int hitZ = int((loc.z+gridSize/2)/gridSize);
    lives--;
    fill(random(0,255),random(0,255),random(0,255), lives);
    if (map.get(hitX, hitZ) != #FFFFFF || loc.y < height-wallHeight*gridSize+gridSize/2 || loc.y > height+1*gridSize-gridSize/2) {
    } else {
      loc.add(dir);
      dir.add(0, 0.1, 0);
    }
  }
}
