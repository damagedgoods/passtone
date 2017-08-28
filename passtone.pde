import processing.sound.*;
import java.awt.*;

PImage photo;
int cols = 700;
int rows = 592;

SoundFile sample;
FFT fft;
AudioIn in;
int bands = 512;
float r_width;
float[] sum = new float[bands];
float smooth_factor = 0.2;
int readBands = 24;
float threshold = 0.005;

int numValues = 4;
int[] validTones = {16, 14, 12, 10, 9, 8, 7, 5};
int[] sequence;
int current = 0;

int t = 0;
int t_last = 0;
int t_espera = 15;

boolean debug = false;

void setup() {
  size(700, 592);
  background(255);
  r_width = width/float(readBands);
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);
  textSize(32);  
  sequence = generateSequence();
}      

void draw() {  
  
  t++;
  background(255);
  fill(0, 0, 255);
  noStroke();
  fft.analyze();
  
  photo = loadImage("richard-lytle-eos.png");
  image(photo,0,0);
  photo.loadPixels();  
  
  // Pixels
  int value = (sequence.length-current)*10;
  if (value == 0) value = 1;
  for (int i=0; i<cols; i+=value) {
    for (int j=0; j<rows; j+=value) {
      color c = photo.pixels[i+j*cols];
      fill(c);
      noStroke();
      rect(i,j,value,value);
    }
  }  
  
  // Status
  fill(0,0,0,100);
  //rect(width/2-150, height/2-40, 300, 80);
  for (int i=0; i<sequence.length; i++) {
    if (i < current) {
      fill(255);
      noStroke();
    } else {
      noFill();
      stroke(255);
      strokeWeight(3);
    } 
    ellipse(width/2-80+10+i*50,height/2,40,40);
  }
    
  int maxBand = 0;
  float maxRead = 0;  
  for (int i = 0; i < readBands; i++) {    
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;    
    if ((sum[i] > threshold) && (sum[i]) > maxRead) {
      maxBand = i;
      maxRead = sum[i];      
    }
        
    if (debug) {
      noStroke();
      fill(255,100);
      rect( i*r_width, height, r_width, -sum[i]*5000);
      rect(-width/2, height-threshold*5000, width*2, 1);
    }
    
  }    
  
  // Chequeo si hay nota y ha acertado
  if ((maxBand > 0)&&(current != sequence.length)&&(t > (t_last + t_espera))) {
    t_last = t;
    if (maxBand == sequence[current]) {
      // Success
      current++;      
    } else {
      // Error
      current = 0;
    }
  }
  
  if ((debug)&&(maxBand > 0)) {
    text(maxBand, 500, 40);
  }  
}

int[] generateSequence() {  
  int[] result = new int[numValues];
  for (int i=0; i<numValues; i++) {
    int t = int(random(0, validTones.length));    
    result[i] = validTones[t];
    println(result[i]);
  }
  //int[] result2 = {8,12,14,9};  
  //return result2;
  return result;  
}