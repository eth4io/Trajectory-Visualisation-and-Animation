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


//-----------------------  Global Variables ------------------------

UnfoldingMap map;
BarScaleUI barScale;                      /* bar scale object */
DataReader dataReader;

Trajectory inspectedTrajectory;              /* trajectory for inspection */

//test
TrajectoryManager trajectoryManager;
List<Trajectory> testTraj;

//----------- Slider Variables ----------------
ControlP5  cp5;
int sliderX, sliderY, sliderW, sliderH;
boolean isPlay = true;
CColor  controlsColours;
int timeLine;
int time;
long previousUpdate = 0;

void setup() {
  size(800, 600);
  map = new UnfoldingMap(this, 0, 0, 800, 400, new EsriProvider.WorldGrayCanvas());

  
  /* set up map */
  map = new UnfoldingMap(this, 0, 0, width,                 /* init map */
  height, new EsriProvider.WorldGrayCanvas());
  
  map.setZoomRange(MAX_LVL, MIN_LVL);                      /* lock zoom */
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);                   /* pan and zoom to study location */
  map.setPanningRestriction(BEIJING_CENTRAL, 20);          /* lock panning */

  //create bar scale
  barScale = new BarScaleUI(this, map, 10, height - 20);

  MapUtils.createDefaultEventDispatcher(this, map);

  /* test of DataReader method */
  dataReader = new DataReader();


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

  controlsColours = new CColor(0x99ffffff, 0x55ffffff, 0xffffffff, 0xffffffff, 
  0xffffffff);
  sliderW=350;
  sliderH=10;
  sliderX = width / 2 - sliderW / 2;
  sliderY = height - 40;
  initialiseUI();
}

void draw() {
  map.draw();
  //test radius variable
  //trajectoryManager.setRadiusToValue(frameCount, 10, 1000,false);
  //some colors testing
  //trajectoryManager.setAllColor(color(150,150,200));
  trajectoryManager.draw();
  barScale.draw();
  if (isPlay) {
    float progress = (float)time / SLIDER_MAX;
    trajectoryManager.updateAll(progress);
    if (time < SLIDER_MAX)
      time ++;
    else
      time = 0;
  }
  drawIU();

  
  //draw inspector if there is a current selection
  if (inspectedTrajectory != null) {
    showInspector();
  }
}

void mouseClicked() {
  inspectedTrajectory = trajectoryManager.checkClick(mouseX, mouseY);

}

void showInspector() {
  fill(30,20,20,150);
  println(inspectedTrajectory.getX(map), inspectedTrajectory.getY(map));
  float x = inspectedTrajectory.getX(map);
  float y = inspectedTrajectory.getY(map);
  int speed = round(inspectedTrajectory.getCurrentPosition().getSpeed());
  int alt = round(inspectedTrajectory.getCurrentPosition().getAltitude());
  rect(x, y - 60, 125, 60, 7);
  fill(255,255,255);
  text("Speed: " + speed + " km/h", x + 5, y - 50);
  text("altitude: " + alt + " km/h", x + 5, y - 35);
}

void initialiseUI() {
  cp5 = new ControlP5(this);
  cp5.addSlider("timeLine")
    .setPosition(sliderX, sliderY)
    .setSize(sliderW, sliderH)
    .setRange(0, SLIDER_MAX)
    .showTickMarks(true)
    .setNumberOfTickMarks(23)
    .setColor(controlsColours)
    .setLabelVisible(false)
     //.listen(true)
    ;

  cp5.addIcon("isPlay", 40)
    .setPosition(sliderX + sliderW / 2, sliderY - 40)
    .setSize(40, 40)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 25))
    .setFontIcons(#00f04C, #00f04B)
    //.setScale(0.9, 1)
    .setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground()
    .setOn();
}

void drawIU() {

  fill(50, 150);
  noStroke();
  rect(sliderX - 40, sliderY - 40, sliderW + 80, sliderH + 80, 7);
  int hour = int(time / 60);
  int min = int(time % 60);
  fill(255);
  text(String.format("%02d:%02d", hour, min), sliderX, sliderY - 10);
  
  if(abs(time - previousUpdate) > 60){
    cp5.getController("timeLine").setValue(time);
    previousUpdate = time;
  }
}

public void timeLine(int value) {
  time = value; 
}

