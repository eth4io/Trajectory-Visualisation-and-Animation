/* Created by
 *  Angela Ryan 953452
 *  Michael Holmes 928428
 *  Yichi Zhang  895529
 * at 11/9/18
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import controlP5.*;
import de.fhpotsdam.unfolding.ui.BarScaleUI;
import java.util.List;
import org.gicentre.utils.colour.*;

//-----------------------  Global Constants ------------------------

static final String FILE_SEPARATOR = System.getProperty("file.separator");
static final String DATA_DIR = "data" + FILE_SEPARATOR +
"Geolife Trajectories 1.3" + FILE_SEPARATOR + "Data" + FILE_SEPARATOR;
static final int MAX_TESTER_INDEX = 181;
static final int MAX_LVL = 11;
static final int MIN_LVL = 13;

static final Location BEIJING_CENTRAL =            /* study location */
new Location(39.907614, 116.397334);
static final String STUDY_DATE = "20081106";
static final String STUDY_DATE_FORMAT = "yyyy-MM-dd/HH:mm:ss";
static final String STUDY_DATE_START_TIME = "2008-11-06/00:00:00";
static final String STUDY_DATE_END_TIME = "2008-11-06/23:59:59";
static final String ERROR_PARSING_DATE = "Error while parsing Date";
static final int SLIDER_MAX = 1440;
static final int HEIGHT = 768;
static final int UI_HEIGHT = 170;
static final int MAP_HEIGHT = HEIGHT - UI_HEIGHT;


//-----------------------  Global Variables ------------------------

UnfoldingMap map;
BarScaleUI barScale;                      /* bar scale object */
DataReader dataReader;

Trajectory inspectedTrajectory;              /* trajectory for inspection */

//test
TrajectoryManager trajectoryManager;
List<Trajectory> testTraj;
ColourTable markerColourTable;

//----------- UI Variables ----------------
ControlP5  cp5;
int sliderX, sliderY, sliderW, sliderH;
boolean isPlay = true;
int animationSpeed;
CColor  controlsColours;
int timeLine;
int time;
long previousUpdate = 0;

//-----------Histogram Variables---------------
Histogram histogram;
static float[] HIST_BINS = new float[] {10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
//-----------LineChart Variables----------------
XYChart lineChart;

int timeBreakSize;
float[] speeds;
float[] times;

int chartY;
int chartHeight;




void setup() {
  size(1024, HEIGHT);
  

  
  /* set up map */
  map = new UnfoldingMap(this, 0, 0, width,                 /* init map */
  MAP_HEIGHT, new EsriProvider.WorldGrayCanvas());
  
  map.setZoomRange(MAX_LVL, MIN_LVL);                      /* lock zoom */
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);                   /* pan and zoom to study location */
  map.setPanningRestriction(BEIJING_CENTRAL, 20);          /* lock panning */

  //create bar scale
  barScale = new BarScaleUI(this, map, 10, MAP_HEIGHT - 20);

  MapUtils.createDefaultEventDispatcher(this, map);

  /* test of DataReader method */
  dataReader = new DataReader();

  markerColourTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_GN,0,50);
  

  trajectoryManager = new TrajectoryManager(dataReader.getTrajectoryListByDate(STUDY_DATE));
  trajectoryManager.setMap(map);
  
  try {
    SimpleDateFormat dataFormat = new SimpleDateFormat(STUDY_DATE_FORMAT);
    Date startTime = dataFormat.parse(STUDY_DATE_START_TIME);
    Date endTime = dataFormat.parse(STUDY_DATE_END_TIME);
    trajectoryManager.setTimeRange(startTime, endTime);
  }
  catch (Exception e) {
    println(ERROR_PARSING_DATE);
  }


  List<Trajectory> testSpeedGraph = new ArrayList<Trajectory>();
  testSpeedGraph = trajectoryManager.getMarkers();

  //initialise UI
  frameRate(30);
  controlsColours = new CColor(0x99ffffff, 0x55ffffff, 0xffffffff, 0xffffffff, 
  0xffffffff);


  
  //initialise histogram
  histogram = new Histogram(HIST_BINS, new float[]{0}, this);
  
  //initialise Line Graph
  initialiseLineGraph();
  initialiseUI();
}

void draw() {
  map.draw();
  //test radius variable
  //trajectoryManager.setRadiusToValue(frameCount, 10, 1000,false);
  //some colors testing
  //trajectoryManager.setAllColor(color(150,150,200));
  //draw interface background
  fill(50, 150);
  noStroke();
  rect(0, MAP_HEIGHT, width, UI_HEIGHT, 7);
  trajectoryManager.draw();
  colourMarkers();
  barScale.draw();
  if (isPlay) {
    float progress = (float)time / SLIDER_MAX;
    trajectoryManager.updateAll(progress);
    if (timeLine < SLIDER_MAX)
      timeLine ++;
    else
      timeLine = 0;
  }
  
  
    //draw inspector if there is a current selection
  if (inspectedTrajectory != null) {
    showInspector();
  }
  fill(255);
  textSize(8);
  updateHistogram();
  histogram.draw(width - 180, MAP_HEIGHT - 120, 150, 110);
  lineChart.draw(0, chartY, width-5, chartHeight);
  updateLineGraph();
  drawIU();
}

void updateHistogram() {
  //histogram update and draw
  List<Trajectory> t = trajectoryManager.getMarkers();
  float[] speeds = new float[t.size()];
  int i = 0;
  
  for (Trajectory m : t) {
    
    speeds[i++] =  m.getCurrentSpeed();
  }
  histogram.update(speeds);
}

void mouseClicked() {
  inspectedTrajectory = trajectoryManager.checkClick(mouseX, mouseY);

}

void showInspector() {
  fill(30,20,20,150);
  println(inspectedTrajectory.getX(map), inspectedTrajectory.getY(map));
  float x = inspectedTrajectory.getX(map);
  float y = inspectedTrajectory.getY(map);
  int speed = round(inspectedTrajectory.getCurrentSpeed());
  int alt = round(inspectedTrajectory.getCurrentPosition().getAltitude());
  rect(x, y - 60, 125, 60, 7);
  fill(255,255,255);
  text("Speed: " + speed + " km/h", x + 5, y - 50);
  text("altitude: " + alt + " m", x + 5, y - 35);
}

void initialiseUI() {
  PVector startLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMinX(), lineChart.getMinY()));
  PVector endLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMaxX(), lineChart.getMaxY()));
  
  sliderH=10;
  sliderY = height - 130;  
  sliderX =(int) startLineGraph.x;
  sliderW = (int)(endLineGraph.x - startLineGraph.x);
  
  cp5 = new ControlP5(this);
  cp5.addSlider("timeLine")
    .setPosition(sliderX, sliderY)
    .setSize(sliderW, sliderH)
    .setRange(0, SLIDER_MAX)
    //.showTickMarks(true)
    //.setNumberOfTickMarks(98)
    .setColor(controlsColours)
    .setLabelVisible(false)
     .listen(true)
    ;

  cp5.addIcon("isPlay", 40)
    .setPosition((width / 2) - 20, sliderY - 40)
    .setSize(40, 40)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 25))
    .setFontIcons(#00f04C, #00f04B)
    //.setScale(0.9, 1)
    .setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground()
    .setOn();
    
   cp5.addIcon("plusSpeed",1)
    .setPosition((width / 2) +50 , sliderY - 30)
    .setSize(10, 10)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 25))
    .setFontIcon(#00f067)
    //.setScale(0.9, 1)
    //.setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground();
    //.setOn();
    
   cp5.addIcon("minusSpeed",1)
    .setPosition((width / 2) +50 , sliderY - 10)
    .setSize(10, 10)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 25))
    .setFontIcon(#00f068)
    //.setScale(0.9, 1)
    //.setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground();
    //.setOn();
}

void drawIU() {


  int rawHour = int(timeLine / 60) + 8;
  int hour = rawHour;
  String daytime = "am";
  if (rawHour > 12){
   hour = rawHour - 12;
   daytime = "pm";
  }
  if (rawHour >= 24) {
    hour = rawHour - 24;
    daytime = "am";
  }
  int min = int(timeLine % 60);
  fill(255);
  textSize(20);
  text(String.format("%02d:%02d%s", hour, min,daytime), sliderX, sliderY - 10);

}


public void timeLine(int value) {

  timeLine = value; 
  time = value;
}

public void initialiseLineGraph() {
  timeBreakSize = 5;
  chartHeight = 110;
  chartY = height-chartHeight-5;
  //create speed array for y variable:
  speeds = new float[SLIDER_MAX/timeBreakSize+1];
  times = new float[SLIDER_MAX/timeBreakSize+1];
  int i = 0; 
  for (int x = 0; x <= SLIDER_MAX; x=x+timeBreakSize) {
    
    speeds[i] = trajectoryManager.calcAvgSpeed(x/(float)SLIDER_MAX);
    times[i]=x;
    //print("Time: " + x + " avg Speed: " + speeds[i] + "\n");
    i++;
  }
  lineChart = new XYChart(this);
  lineChart.setData(times,speeds);
  //lineChart.showXAxis(true); 
  lineChart.showYAxis(true); 
  lineChart.setLineWidth(2);
  lineChart.setMaxX(SLIDER_MAX);
  lineChart.setMaxY(13);
  lineChart.setXAxisLabel("Time");
  lineChart.setYAxisLabel("Average Speed");
  lineChart.setAxisColour(255);
  lineChart.setAxisLabelColour(255);
  lineChart.setAxisValuesColour(255);
  lineChart.setLineColour(255);
  lineChart.setPointColour(255);
  lineChart.draw(0, chartY, width-5, chartHeight);
 

}

public void updateLineGraph(){
  int i = timeLine/timeBreakSize;

  PVector pointLocation = lineChart.getDataToScreen( new PVector(times[i],speeds[i]));
  int y = chartY+chartHeight - (int)lineChart.getBottomSpacing();
  int y2 = chartY;
  strokeWeight(2);
  stroke(200,80,80);
 
  line(pointLocation.x, y, pointLocation.x, y2);
}

/* Colour markers according to speed */
public void colourMarkers(){
  List<Trajectory> t = trajectoryManager.getMarkers();
  
  for (Trajectory m : t) {
    if (m.isMoving()) {
      float speed =  m.getCurrentSpeed();
      m.setColor(markerColourTable.findColour(speed));
      m.setHidden(false);                                                 /* show if moving */
    } else {
      m.setHidden(true);                                                  /* Hide if not moving */
    }
    
  }
    
  }
