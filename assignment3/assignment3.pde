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
static final List<String> STUDY_DATES = Arrays.asList(
  "20090220",
  "20081116",
  "20081106",
  "20081105",
  "20081203",
  "20090312",
  "20090219",
  "20081111",
  "20081112",
  "20081205",
  "20090216",
  "20090313",
  "20081210",
  "20090217",
  "20081117",
  "20090408",
  "20081109",
  "20081207",
  "20081212",
  "20090305",
  "20081113",
  "20081114",
  "20090413",
  "20081209",
  "20081204",
  "20081211"
);
static final String STUDY_DATE = "20081106";
static final String STUDY_DATE_FORMAT = "yyyy-MM-dd/HH:mm:ss";
static final String STUDY_DATE_START_TIME = "2008-11-06/00:00:00";
static final String STUDY_DATE_END_TIME = "2008-11-06/23:59:59";
static final String ERROR_PARSING_DATE = "Error while parsing Date";
static final int SLIDER_MAX = 1440;
static final int FILTER_MAX = 20;                  /* kilometres */
static final int FILTER_MIN = 5;                   /* kilometres */
static final int HEIGHT = 768;
static final int WIDTH = 1024;
static final int UI_HEIGHT = 170;
static final int MAP_HEIGHT = HEIGHT - UI_HEIGHT;
static final int PANEL_WIDTH = 200;
static final int MAP_WIDTH = WIDTH - PANEL_WIDTH;

//-----------------------  Global Variables ------------------------

UnfoldingMap map;
BarScaleUI barScale;                      /* bar scale object */
DataReader dataReader;

Trajectory inspectedTrajectory;           /* trajectory for inspection */
MarkerManager inspectedManager;           /* manager for exploring trajectory points */
//test
TrajectoryManager trajectoryManager;
List<Trajectory> testTraj;
ColourTable markerColourTable;

//----------- UI Variables ----------------
ControlP5  cp5;
RadioButton radioButton;
int sliderX, sliderY, sliderW, sliderH;
boolean isPlay = true;
int animationSpeed;
CColor  controlsColours;
int timeLine;
int time;
long previousUpdate = 0;

//-----------Histogram Variables---------------
Histogram histogram;
Histogram histogram2;
static float[] HIST_BINS = new float[] {5, 10, 15, 20, 25, 30, 35, 40, 45, 50};
//-----------LineChart Variables----------------
XYChart lineChart;

int timeBreakSize;
float[] avgSpeeds;
float[] times;

int chartY;
int chartHeight;

//----------- Radius Filter Variables----------
//RadiusFilter radiusFilter;
FilterManager filterManager;
int currentZoomLevel = 0;
int previousZoomLevel = 0;
boolean isFilterMode = false;
float filterSize = 5;
color FILTER_BLUE;
color FILTER_RED;

void setup() {
  size(WIDTH, HEIGHT);
  FILTER_BLUE = color(252,141,89);
  FILTER_RED = color(145,191,219);

  
  /* set up map */
  map = new UnfoldingMap(this, 0, 0, MAP_WIDTH,                 /* init map */
  MAP_HEIGHT, new EsriProvider.WorldGrayCanvas());
  
  map.setZoomRange(MAX_LVL, MIN_LVL);                      /* lock zoom */
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);                   /* pan and zoom to study location */
  map.setPanningRestriction(BEIJING_CENTRAL, 20);          /* lock panning */

  //create bar scale

  barScale = new BarScaleUI(this, map, 10, MAP_HEIGHT - 20);


  MapUtils.createDefaultEventDispatcher(this, map);

   //create radius filter
  //radiusFilter = new RadiusFilter(color(255,0,0,50));
  //radiusFilter.setFilterRadius(map, 20);
  //map.addMarker(radiusFilter);
  filterManager = new FilterManager();
  //filterManager.addFilter(color(255,0,0,50));
  filterManager.setMap(map);
  
  
  /* test of DataReader method */
  dataReader = new DataReader();

  markerColourTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_GN,0,50);
  
  //init trajectory manager
  trajectoryManager = new TrajectoryManager(
    dataReader.getListOfTrajectoryListByListOfDate(STUDY_DATES));
  trajectoryManager.setMap(map);
  
  //init inspected trajectory manager
  inspectedManager = new MarkerManager();
  inspectedManager.setMap(map);
  
  
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



  
  //initialise histogram
  histogram = new Histogram(HIST_BINS, new float[]{0}, this);
  histogram2 = new Histogram(HIST_BINS, new float[]{0}, this);
  histogram.changeLook(true, 0, FILTER_BLUE);
  histogram2.changeLook(true, 4, FILTER_RED);
  //initialise Line Graph
  initialiseLineGraph();
  initialiseUI();
}

void draw() {
  //get new zoom level (leave at start of draw)
  currentZoomLevel = map.getZoomLevel();
  //main radius filter updater
  updateRadiusFilter();
  
  map.draw();

  //test radius variable
  //trajectoryManager.setRadiusToValue(frameCount, 10, 1000,false);
  //some colors testing
  //trajectoryManager.setAllColor(color(150,150,200));
  //draw interface background
  fill(50, 150);
  noStroke();
  rect(0, MAP_HEIGHT, width, UI_HEIGHT);
  
  //draw Panel
  if (cp5.getTab("Controls").isActive()){
    rect(MAP_WIDTH,0,PANEL_WIDTH,MAP_HEIGHT);
    stroke(1);
    fill(255);
    line(MAP_WIDTH, 30,width,30);
    line(MAP_WIDTH, 100,width,100);
  }
   
  barScale.draw();
    float progress = (float)time / SLIDER_MAX;
    trajectoryManager.updateAll(progress);
    if (isPlay) {
    if (timeLine < SLIDER_MAX)
      timeLine ++;
    else
      timeLine = 0;
    }
  
    //draw inspector if there is a current selection && if is not in filter mode
  if (inspectedTrajectory != null && !isFilterMode) {
    showInspector();// add coords here
    // test and show selected trajectory
    if (Tools.exploreTrajectory(inspectedTrajectory, inspectedManager, markerColourTable)) {
      inspectedManager.draw();
    }
  }
  
  trajectoryManager.draw();
  
  trajectoryManager.setAllColor(200);
  fill(255);
  textSize(8);
  
  if (!isFilterMode){
    List<Trajectory> empty = new ArrayList<Trajectory>();
    updateHistogram(trajectoryManager.getMarkers(), empty);
    trajectoryManager.setStyle(color(255,255,255,0), color(0,0,0),1);
  }
  
  colourMarkers();
  
  histogram.draw(width - 220, MAP_HEIGHT - 170, 220, 170);
  histogram2.draw(width - 220, MAP_HEIGHT - 170, 220, 170);
  lineChart.draw(0, chartY, width-5, chartHeight);
  filterManager.draw();
  updateLineGraph();
  
  //update zoom levels (leave last in draw)
  previousZoomLevel = currentZoomLevel;
  
  drawIU();
}

void updateRadiusFilter() {
  if (currentZoomLevel != previousZoomLevel) {
    filterManager.setAllFilterRadius(map, filterSize);
    //radiusFilter.setFilterRadius(map, filterSize);                
  }
  if (isFilterMode) {
    if (filterManager.getMarkers().size() <= 0) {
      filterManager.addFilter(FILTER_BLUE);
    }
    //radiusFilter.setHidden(false);
    filterManager.setAllHidden(false);
    //radiusFilter.setFilterRadius(map,filterSize);
    filterManager.setAllFilterRadius(map, filterSize);
    List<List<Trajectory>> tTemp = new ArrayList<List<Trajectory>>();
    
    tTemp = filterManager.getAllWithinRadius(map,trajectoryManager.getMarkers());
    if (filterManager.getMarkers().size() > 1 ) {
      updateHistogram(tTemp.get(0), tTemp.get(1));
    } else {
      updateHistogram(tTemp.get(0), null);
    }
    
    trajectoryManager.deselectAll();
    filterManager.getAllWithinRadius(map,trajectoryManager.getMarkers());
    //radiusFilter.update(map);
    filterManager.updateAll(map);
  } else {
    if (filterManager.getMarkers().size() > 0) {
      filterManager.setAllHidden(true);
    }
  }
  
  

}

void updateHistogram(List<Trajectory> a, List<Trajectory> b) {
  //histogram update and draw
  
  float[] speeds1 = new float[a.size()];
  float[] speeds2 = new float[b != null ? b.size() : 0];
  int i = 0;
  
  
  for (Trajectory m : a) {
    if(!m.isActive())
        continue;
    speeds1[i++] =  m.getCurrentSpeed();
  }
  
  histogram.update(speeds1);
  
  if (b != null) {
    i = 0;
    for (Trajectory m : b) {
      if(!m.isActive())
        continue;
      speeds2[i++] =  m.getCurrentSpeed();
    }
    histogram2.update(speeds2);
  }
}

void mouseClicked() {
  if (mouseY <= MAP_HEIGHT) {
    inspectedTrajectory = trajectoryManager.checkClick(mouseX, mouseY);
  }
  
  if (isFilterMode && mouseX <= MAP_WIDTH) {
    filterManager.placeFilter(map);
    if (filterManager.getMarkers().size() < 2) {
      filterManager.addFilter(FILTER_RED);
    }
  } else if (!isFilterMode) {
    filterManager.clearMarkers();
  }

}

void showInspector() {
  fill(30,20,20,150);
  float x = inspectedTrajectory.getX(map);
  float y = inspectedTrajectory.getY(map);
  int speed = round(inspectedTrajectory.getCurrentSpeed());
  int alt = round(inspectedTrajectory.getCurrentPosition().getAltitude());
  String id = inspectedTrajectory.getId();
  rect(x, y - 60, 125, 60, 7);
  fill(255,255,255);
  text("id: " + id, x + 5, y - 50);
  text("Speed: " + speed + " km/h", x + 5, y - 35);
  text("altitude: " + alt + " m", x + 5, y - 15);
}

void initialiseUI() {
  PVector startLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMinX(), lineChart.getMinY()));
  PVector endLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMaxX(), lineChart.getMaxY()));
  controlsColours = new CColor(0xffffffff, 0x55ffffff, 0xffffffff, 0x99ffffff, 
  0xffffffff);
  
  int buttonX = MAP_WIDTH + 20;
  
  sliderH=10;
  sliderY = height - 130;  
  sliderX =(int) startLineGraph.x;
  sliderW = (int)(endLineGraph.x - startLineGraph.x);
  
  cp5 = new ControlP5(this);
  
  cp5.setColor(controlsColours);
  cp5.setFont(createFont("Arial", 10));
  
  //------------------Animation Controls---------------------------------------
  
  cp5.addSlider("timeLine")
    .moveTo("global")
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
    .moveTo("global")
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
    .moveTo("global")
    .setPosition((width / 2) +100 , sliderY - 35)
    .setSize(20, 20)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 20))
    .setFontIcon(#00f067)
    //.setScale(0.9, 1)
    //.setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground();
    //.setOn();
    
   cp5.addIcon("minusSpeed",1)
    .moveTo("global")
    .setPosition((width / 2) +100 , sliderY - 15)
    .setSize(20, 10)
    //.setRoundedCorners(20)
    .setFont(createFont("fontawesome-webfont.ttf", 20))
    .setFontIcon(#00f068)
    //.setScale(0.9, 1)
    //.setSwitch(true)
    .setColorBackground(color(255, 100))
    .hideBackground();
    //.setOn();
    
    
    //-------------------------------Panel Controls-----------------------------
   
  cp5.addTextlabel("Title")
     .setText("USER CONTROLS")
     .setPosition(buttonX,5)
     .setColorValue(color(0))
     .moveTo("Controls")
     .setFont(createFont("Arial", 20))  
     ; 

  cp5.addTextlabel("FilterControls")
     .setText("Chose Amount of Data")
     .setPosition(buttonX,35)
     .setColorValue(color(0))
     .moveTo("Controls")
     .setFont(createFont("Arial", 15))  
     ; 
     
     
  //ui for radius filter control
  cp5.addToggle("isFilterMode")
        .setPosition(buttonX, 300)
      //.setColor(controlsColours)
        .setLabel("Filter Mode")
        .setColorLabel(color(0))
        .moveTo("Controls")
        ;
  cp5.addSlider("filterSize")
        .setPosition(buttonX, 350)
        .setRange(FILTER_MIN, FILTER_MAX)
        //.setColor(controlsColours)
        .showTickMarks(true)
        .setNumberOfTickMarks(4)
        .setColorLabel(color(0))
        .setLabel("Filter Size")
        .setBroadcast(true)
        .moveTo("Controls")
        ;

  radioButton = cp5.addRadioButton("radioButton")
         .setPosition(buttonX,60)
         .setSize(40,20)
         //.setColorForeground(color(120))
         ////.setColorActive(color(255))
         .setColorLabel(color(0))
         .setColor(controlsColours)
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         .moveTo("Controls")
         .addItem("1 day",1)
         .addItem("5 days",2)
         .addItem("10 days",3)
         ;
         

     for(Toggle t : radioButton.getItems()) {
       t.getCaptionLabel().setColorBackground(color(255,80));
       t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
       t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
       t.getCaptionLabel().getStyle().backgroundWidth = 45;
       t.getCaptionLabel().getStyle().backgroundHeight = 13;
     }

   cp5.addButton("showHistogram")
        .moveTo("Controls")
        .setPosition(buttonX, 400); 

   


    
    //tab sorting
   cp5.getTab("Controls")
        .setColorLabel(color(0))
        .setLabel("Show Controls")
         ;

  cp5.getTab("default")
        .setColorLabel(color(0))
        .setLabel("Hide Controls")
        ;
    
}

/* update filter size from filter controls */
void filterSize(int size) {
  filterSize = size;
//  cp5.getController("filterSize").setValue(size);
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
  fill(255,255,255,255);
  strokeWeight(3);
  textSize(20);
  text(String.format("%02d:%02d%s", hour, min,daytime), sliderX, sliderY - 10);
  textSize(15);
  text("Speed", (width / 2) +50, sliderY-10);

}

public void minusSpeed() {frameRate(frameRate/2);}
public void plusSpeed() {frameRate(frameRate*2);}

public void timeLine(int value) {

  timeLine = value; 
  time = value;
}

public void initialiseLineGraph() {
  timeBreakSize = 5;
  chartHeight = 110;
  chartY = height-chartHeight-5;
  //create speed array for y variable:
  avgSpeeds = new float[SLIDER_MAX/timeBreakSize+1];
  times = new float[SLIDER_MAX/timeBreakSize+1];
  int i = 0; 
  for (int x = 0; x <= SLIDER_MAX; x=x+timeBreakSize) {
    
    avgSpeeds[i] = trajectoryManager.calcAvgSpeed((float)x/SLIDER_MAX);
    times[i]=x;
    //print("Time: " + x + " avg Speed: " + speeds[i] + "\n");
    i++;
  }
  lineChart = new XYChart(this);
  lineChart.setData(times,avgSpeeds);
  //lineChart.showXAxis(true); 
  lineChart.showYAxis(true); 
  lineChart.setLineWidth(2);
  lineChart.setMaxX(SLIDER_MAX);
  //lineChart.setMaxY(13);
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

  PVector pointLocation = lineChart.getDataToScreen( new PVector(times[i],avgSpeeds[i]));
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
    if (m.isActive() && m.isMoving()) {
      if (!isFilterMode) {                                              /* do not colour if in filter mode */
        float speed =  m.getCurrentSpeed();
        m.setColor(markerColourTable.findColour(speed));
      }
      m.setHidden(false); /* show if moving */
    } else {
      m.setHidden(true); /* Hide if not moving */
    }
  }
}




void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(radioButton)) {
    trajectoryManager.clearMarkers();
    switch(int(theEvent.getValue())) {
      case 1:
        trajectoryManager.setNumberOfDaysToDisplay(1);
        break;
      case 2:
        trajectoryManager.setNumberOfDaysToDisplay(5);
        break;
      case 3:
        trajectoryManager.setNumberOfDaysToDisplay(10);
        break;
    }
  }
}
