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

//-----------------------  Global Constants -----------------------------------------------------

static final String FILE_SEPARATOR = System.getProperty("file.separator");
static final String DATA_DIR = "data" + FILE_SEPARATOR +
  "Geolife Trajectories 1.3" + FILE_SEPARATOR + "Data" + FILE_SEPARATOR;
static final int MAX_TESTER_INDEX = 181;
static final int MAX_LVL = 11;
static final int MIN_LVL = 13;
static final int LINE_CHART_Y_MAX = 5;

static final Location BEIJING_CENTRAL =            /* study location */
  new Location(39.907614, 116.397334);
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
static final int CENTROID_SIZE = 5;
final color CENTROID_COLOUR = color(4, 4, 100, 50);

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

CentroidMarker centroid;

//----------- UI Variables ----------------
ControlP5  cp5;
RadioButton radioButton;
int sliderX, sliderY, sliderW, sliderH;
boolean isPlay = true;
Icon isPlayIcon;
int animationSpeed;
CColor  controlsColours;
int timeLine;
long previousUpdate = 0;
int frameSpeed;
long countFrames;
boolean isHistogramOn;
boolean isColoursOn;
boolean isTrajOn;
boolean isLinesOn;
boolean isPtsOn;
boolean isCentroidOn;

//-----------Histogram Variables---------------
Histogram histogram;
Histogram histogram2;


static float[] HIST_BINS = new float[] {
  5, 10, 15, 20, 25,
  30, 35, 40, 45, 50,
  100
};
float offsetTest = 3;
//-----------Chart Variables----------------
XYChart lineChart;


int timeBreakSize;
float[] avgSpeeds;
float[] times;

int chartY;
int chartHeight;
PVector startLineGraph;
PVector endLineGraph;

//----------- Radius Filter Variables----------

FilterManager filterManager;
int currentZoomLevel = 0;
int previousZoomLevel = 0;
boolean isFilterMode = false;
float filterSize = 5;
color FILTER_BLUE;
color FILTER_RED;

//---------------------------SETUP--------------------------------------------------------------------------------

void setup() {
  size(WIDTH, HEIGHT);


  //-------------Set Map Variables ------------------------------------
  map = new UnfoldingMap(this, 0, 0, MAP_WIDTH, /* init map */
  MAP_HEIGHT, new EsriProvider.WorldGrayCanvas());

  map.setZoomRange(MAX_LVL, MIN_LVL);                      /* lock zoom */
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);                   /* pan and zoom to study location */
  map.setPanningRestriction(BEIJING_CENTRAL, 20);          /* lock panning */


  //create bar scale

  barScale = new BarScaleUI(this, map, MAP_WIDTH-60, MAP_HEIGHT - 20);


  MapUtils.createDefaultEventDispatcher(this, map);
  
  centroid = new CentroidMarker(new Location(0,0), CENTROID_COLOUR, CENTROID_SIZE);

  //-----Set Filter Variables ------------------------------------  
  FILTER_BLUE = color(252, 141, 89);
  FILTER_RED = color(145, 191, 219);

  filterManager = new FilterManager();
  filterManager.setMap(map);


  /* test of DataReader method */
  dataReader = new DataReader();

  //---Set Marker Table----------------------------------------
  markerColourTable = ColourTable.getPresetColourTable(ColourTable.RD_PU, 0, 50);

  //init trajectory manager
  trajectoryManager = new TrajectoryManager(
  dataReader.getListOfTrajectoryListByListOfDate(StudyDates.STUDY_DATES));
  trajectoryManager.setMap(map);


  //init inspected trajectory manager
  inspectedManager = new MarkerManager();
  inspectedManager.setMap(map);

  //-----------Set Date Variables-------------------------------------
  try {
    SimpleDateFormat dataFormat = new SimpleDateFormat(STUDY_DATE_FORMAT);
    Date startTime = dataFormat.parse(STUDY_DATE_START_TIME);
    Date endTime = dataFormat.parse(STUDY_DATE_END_TIME);
    trajectoryManager.setTimeRange(startTime, endTime);
  }
  catch (Exception e) {
    println(ERROR_PARSING_DATE);
  }

  //--------------Speed Graph Variables-----------------------------------------
  List<Trajectory> testSpeedGraph = new ArrayList<Trajectory>();
  testSpeedGraph = trajectoryManager.getMarkers();



  //---------initialise Graphs--------------------------------------------------

    String[] LABELS = new String[] {
      "0-4", "5-9", "10-14", "15-19", "20-24",
      "25-29", "30-34", "35-39", "40-44", "45-49",
      ">50"
    };
  histogram = new Histogram(HIST_BINS, new ArrayList(), this, LABELS);
  histogram2 = new Histogram(HIST_BINS, new ArrayList(), this);

  histogram.changeLook(0, 4, FILTER_BLUE);
  histogram2.changeLook(8, 0, FILTER_RED);
  histogram.getChart().setAxisValuesColour(255);
  histogram2.getChart().setDecorations(false);

  //initialise Line Graph
  initialiseLineGraph();
  frameSpeed = 2;

  //initialise UI
  initialiseUI();
}



//---------------------DRAW METHOD ---------------------------------------------------------




void draw() {
  //get new zoom level (leave at start of draw)
  currentZoomLevel = map.getZoomLevel();
  //main radius filter updater
  updateRadiusFilter();

  map.draw();
  fill(0, 0, 0, 100);
  rect(0, 0, width, height);
  //draw interface background
  fill(50, 150);
  noStroke();
  rect(0, MAP_HEIGHT, width, UI_HEIGHT);

  //-------------draw Panel-------------------------------------------------------------------
  if (cp5.getTab("Controls").isActive()) {
    rect(MAP_WIDTH, 0, PANEL_WIDTH, MAP_HEIGHT);
    stroke(255);
    line(MAP_WIDTH, 30, width, 30);
    line(MAP_WIDTH, 125, width, 125);
    line(MAP_WIDTH, 215, width, 215);
    line(MAP_WIDTH, 440, width, 440);
    stroke(0);
    fill(255);
    textSize(13);
    int speedY = 480; //variable holds the Y value of all legend items
    if ((isTrajOn) || (isColoursOn) || (isLinesOn)) {
      float inc = 0.001;
      int colOffset = MAP_WIDTH + 70;

      text("Speed", MAP_WIDTH+25, speedY + 10);
      for (float i=0; i<1-inc; i+=inc)
      {
        fill(markerColourTable.findColour(i*50));
        stroke(markerColourTable.findColour(i*50));
        rect(colOffset + 100*i, speedY-5, 50*inc, 20);
      }
      fill(255);
      text("0km/h", MAP_WIDTH+70, speedY + 35);
      text("50km/h", MAP_WIDTH+130, speedY + 35);
    }
    if (isCentroidOn) {
      text("Mean Centre", MAP_WIDTH+25, speedY + 65);
      fill(CENTROID_COLOUR);
      strokeWeight(1);
      rectMode(RADIUS);
      rect(MAP_WIDTH + 130, speedY + 60, CENTROID_SIZE, CENTROID_SIZE);
      rectMode(CORNER);
    }
  }

  //----------draw scale-----------------------------
  textSize(15); 
  barScale.draw();

  //----------------UPDATE POINTS AND SLIDER--------------------------------------------------------
  float progress = (float)timeLine / SLIDER_MAX;
  trajectoryManager.updateAll(progress);
  if (isPlay) {

    if (timeLine < SLIDER_MAX) timeLine ++;
    if (timeLine >= SLIDER_MAX) timeLine = 0;
  }
  //----------------CENTROID DISPLAY--------------------------------
  if (isCentroidOn) {
    centroid.setLocation(trajectoryManager.calcAvgLoc());
    centroid.draw(map);
  }

  //draw inspector if there is a current selection && if is not in filter mode
  if (inspectedTrajectory != null && !isFilterMode) {

    // test and show selected trajectory
    if (Tools.exploreTrajectory(inspectedTrajectory, inspectedManager, markerColourTable)) {
      inspectedManager.draw();
    }
    showInspector();// add coords here
  }

  //--------------------------------DRAW POINTS----------------------
  if (isPtsOn) trajectoryManager.draw();


  //--------------------------------DRAW LINES--------------------------
  //draw markers as lines between current and previous pt
  if (isLinesOn) {
    List<Marker> lines = trajectoryManager.getLineCoords(markerColourTable);
    //map.addMarkers(lines);
    for (Marker l : lines) {

      l.draw(map);
    }
  }

  //----------------------COLOUR HANDLING FOR MARKERS------------------------
  trajectoryManager.setAllColor(200);
  fill(255);
  textSize(8);

  if (!isFilterMode) {
    List<Trajectory> empty = new ArrayList<Trajectory>();
    updateHistogram(trajectoryManager.getMarkers(), empty);
    trajectoryManager.setStyle(color(255, 255, 255, 0), color(0, 0, 0), 1);
  }

  colourMarkers();

  //-----------------------DRAW CHARTS--------------------------------------------
  if (isHistogramOn) {
    histogram.draw(10, MAP_HEIGHT - 260, 250, 250);
    histogram2.draw(10, MAP_HEIGHT - 260, 250, 250);
  }

  lineChart.setPointSize(1);
  lineChart.draw(0, chartY, width-5, chartHeight);


  filterManager.draw();
  updateLineGraph();

  //update zoom levels (leave last in draw)
  previousZoomLevel = currentZoomLevel;

  drawIU();
}

//-----------------------------------------FILTER METHODS----------------------------------------

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

    tTemp = filterManager.getAllWithinRadius(map, trajectoryManager.getMarkers());
    if (filterManager.getMarkers().size() > 1 ) {
      updateHistogram(tTemp.get(0), tTemp.get(1));
    } else {
      updateHistogram(tTemp.get(0), null);
    }

    trajectoryManager.deselectAll();
    filterManager.getAllWithinRadius(map, trajectoryManager.getMarkers());
    //radiusFilter.update(map);
    filterManager.updateAll(map);
  } else {
    if (filterManager.getMarkers().size() > 0) {
      filterManager.setAllHidden(true);
    }
  }
}

void mouseClicked() {
  if ((mouseY <= MAP_HEIGHT) && (isTrajOn)) {
    inspectedTrajectory = trajectoryManager.checkClick(mouseX, mouseY);
  }

  if (isFilterMode && mouseX <= MAP_WIDTH && mouseY <= MAP_HEIGHT) {
    filterManager.placeFilter(map);
    if (filterManager.getMarkers().size() < 2) {
      filterManager.addFilter(FILTER_RED);
    }
  } else if (!isFilterMode) {
    filterManager.clearMarkers();
  }
}

void showInspector() {
  fill(30, 20, 20, 150);
  float x = inspectedTrajectory.getX(map);
  float y = inspectedTrajectory.getY(map);
  int speed = round(inspectedTrajectory.getCurrentSpeed());
  int alt = round(inspectedTrajectory.getCurrentPosition().getAltitude());
  String id = inspectedTrajectory.getId();
  rect(x, y - 60, 125, 60, 7);
  fill(255, 255, 255);
  text("id: " + id, x + 5, y - 50);
  text("Speed: " + speed + " km/h", x + 5, y - 35);
  text("altitude: " + alt + " m", x + 5, y - 15);
}

//------------------------------CHART METHODS--------------------------------------------------

void updateHistogram(List<Trajectory> a, List<Trajectory> b) {
  //histogram update and draw

  List<Float> speeds1 = new ArrayList();
  List<Float> speeds2 = b != null? new ArrayList() : null;
  int i = 0;


  for (Trajectory m : a) {
    if (!m.isActive())
      continue;
    speeds1.add(m.getCurrentSpeed());
  }

  histogram.update(speeds1);

  if (b != null) {
    i = 0;
    for (Trajectory m : b) {
      if (!m.isActive())
        continue;
      speeds2.add(m.getCurrentSpeed());
    }
    histogram2.update(speeds2);
  }
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
    i++;
  }
  lineChart = new XYChart(this);
  lineChart.setData(times, avgSpeeds);
  lineChart.showYAxis(true); 
  lineChart.setLineWidth(2);
  lineChart.setMaxX(SLIDER_MAX);
  lineChart.setMaxY(LINE_CHART_Y_MAX);
  lineChart.setXAxisLabel("Time");
  lineChart.setYAxisLabel("Average Speed");
  lineChart.setAxisColour(255);
  lineChart.setAxisLabelColour(255);
  lineChart.setAxisValuesColour(255);
  lineChart.setLineColour(255);
  lineChart.setPointColour(255);
  lineChart.draw(0, chartY, width-5, chartHeight);

}

public void updateLineGraph() {
  int i = timeLine/timeBreakSize;

  PVector pointLocation = lineChart.getDataToScreen( new PVector(times[i], avgSpeeds[i]));
  int y = chartY+chartHeight - (int)lineChart.getBottomSpacing();
  int y2 = chartY;
  strokeWeight(2);
  stroke(200, 80, 80);

  line(pointLocation.x, y, pointLocation.x, y2);
}



//----------------------------------------------BUTTON METHODS------------------------------------------


void initialiseUI() {
  startLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMinX(), lineChart.getMinY()));
  endLineGraph = lineChart.getDataToScreen( new PVector(lineChart.getMaxX(), lineChart.getMaxY()));

  controlsColours =new CColor(0x99ffffff, 0x55ffffff, 0xffffffff, 0xffffffff, 0xffffffff);
  controlsColours.setValueLabel(color(0));

  int buttonX = MAP_WIDTH + 20;

  sliderH = 10;
  sliderY = height - 130;  
  sliderX =(int) startLineGraph.x;
  sliderW = (int)(endLineGraph.x - startLineGraph.x);

  cp5 = new ControlP5(this);

  cp5.setColor(controlsColours);
  cp5.setFont(createFont("Arial", 10));

  cp5.getTab("Controls")
    .setColorLabel(color(0))
      .setLabel("Show Controls")
        ;

  cp5.getTab("default")
    .setColorLabel(color(0))
      .setLabel("Hide Controls")
        ;

  //------------------Animation Controls---------------------------------------

  cp5.addSlider("timeLine")
    .moveTo("global")
      .setPosition(sliderX, sliderY)
        .setSize(sliderW, sliderH)
          .setRange(0, SLIDER_MAX)
            .setColor(controlsColours)
              .setLabelVisible(false)
                .listen(true)
                  ;

  isPlayIcon = cp5.addIcon("isPlay", 40)
    .moveTo("global")
      .setPosition((width / 2) -30, sliderY - 40)
        .setSize(40, 40)
          .setFont(createFont("fontawesome-webfont.ttf", 25))
            .setFontIcons(#00f04C, #00f04B)
              .setSwitch(true)
                .setColorBackground(color(255, 100))
                  .hideBackground()
                    .setOn();

  cp5.addIcon("plusSpeed", 1)
    .moveTo("global")
      .setPosition(width -30, sliderY - 25)
        .setSize(20, 20)
          .setFont(createFont("fontawesome-webfont.ttf", 20))
            .setFontIcon(#00f067)
              .setColorBackground(color(255, 100))
                .hideBackground();


  cp5.addIcon("minusSpeed", 1)
    .moveTo("global")
      .setPosition(width-95, sliderY - 25)
        .setSize(20, 20)
          .setFont(createFont("fontawesome-webfont.ttf", 20))
            .setFontIcon(#00f068)
              .setColorBackground(color(255, 100))
                .hideBackground();


  //-------------------------------Panel Controls-----------------------------

  cp5.addTextlabel("Title")
    .setText("USER CONTROLS")
      .setPosition(buttonX-10, 3)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 20))  
              ; 

  cp5.addTextlabel("FilterControls")
    .setText("Chose Amount of Data")
      .setPosition(buttonX, 35)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 15))  
              ; 

  cp5.addTextlabel("Tools")
    .setText("Filter Tool")
      .setPosition(buttonX, 130)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 15))  
              ; 

  cp5.addTextlabel("ViewControls")
    .setText("View Controls")
      .setPosition(buttonX, 220)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 15))  
              ; 

  cp5.addTextlabel("MarkerSettings")
    .setText("Marker Options")
      .setPosition(buttonX+10, 240)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 13))  
              ; 

  cp5.addTextlabel("View Options")
    .setText("View Options")
      .setPosition(buttonX+10, 360)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 13))  
              ; 

  cp5.addTextlabel("Legend")
    .setText("Legend")
      .setPosition(buttonX, 445)
        .setColorValue(color(255))
          .moveTo("Controls")
            .setFont(createFont("Arial", 15))  
              ; 

  //ui for radius filter control
  cp5.addToggle("isFilterMode")
    .setPosition(buttonX, 155)
      .setLabel("Activate Filter Mode")
        .setColorLabel(color(255))
          .moveTo("Controls")
            .getCaptionLabel()
              .getStyle()
                .setMarginTop(-22)
                  .setMarginLeft(45)
                    ;

  cp5.addSlider("filterSize")
    .setPosition(buttonX, 190)
      .setRange(FILTER_MIN, FILTER_MAX)
        .setColorLabel(color(255))
          .showTickMarks(true)
            .setNumberOfTickMarks(4)
              .setLabel("Radius (KM)")
                .setBroadcast(true)
                  .moveTo("Controls")
                    ;

  radioButton = cp5.addRadioButton("radioButton")
    .setPosition(buttonX, 55)
      .setSize(40, 20)
        .setColor(controlsColours)
          .setItemsPerRow(1)
            .setSpacingColumn(50)
              .setColorLabel(color(255))
                .moveTo("Controls")
                  .addItem("10 day", 1)
                    .addItem("50 days", 2)
                      .addItem("150 days", 3)
                        ;


  for (Toggle t : radioButton.getItems ()) {
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
  }

  radioButton.getController("150 days").setValue(1);
 
  
  int viewControlY = 260; 

  cp5.addToggle("showTrajectory")
    .setLabel("Show Traj with Click")
      .setPosition(buttonX, viewControlY + 25)
        .setValue(true)
          .moveTo("Controls")
            .setColorLabel(color(255))
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45); 

  cp5.addToggle("showPts")
    .setLabel("Show Points as Circles")
      .setPosition(buttonX, viewControlY + 50)
        .setValue(false)
          .setColorLabel(color(255))
            .moveTo("Controls")
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45)
                      ; 

  cp5.addToggle("showAsLines")
    .setLabel("Show Pts as Lines")
      .setPosition(buttonX, viewControlY)
        .setValue(true)
          .setColorLabel(color(255))
            .moveTo("Controls")
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45);

  cp5.addToggle("showColours")
    .setLabel("Colour by Speed")
      .setPosition(buttonX+10, viewControlY + 75)
        .setValue(true)
          .moveTo("Controls")
            .setColorLabel(color(255))
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45); 

  cp5.addToggle("showHistogram")
    .setLabel("Show Histogram")
      .setPosition(buttonX, viewControlY+125)
        .setValue(false)
          .setColorLabel(color(255))
            .moveTo("Controls")
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45);


  cp5.addToggle("showCentroid")
    .setLabel("Show Mean Centre")
      .setPosition(buttonX, viewControlY + 150)
        .setValue(false)
          .setColorLabel(color(255))
            .moveTo("Controls")
              .getCaptionLabel()
                .getStyle()
                  .setMarginTop(-22)
                    .setMarginLeft(45)
                      ;
}

void isFilterMode(boolean value) {
  if (value) { 
    cp5.getController("showHistogram").setValue(1);
    cp5.getController("showCentroid").setValue(0);
    cp5.getController("showPts").setValue(1);
    cp5.getController("showAsLines").setValue(0);
  }
    
  isFilterMode = value;
}


void showHistogram(boolean value) {
  isHistogramOn = value;
}

void showCentroid(boolean value) {
  isCentroidOn = value;
  if (isCentroidOn) cp5.getController("isFilterMode").setValue(0);
}

void showColours(boolean value) {
  isColoursOn = value;
}

void showTrajectory(boolean value) {
  isTrajOn = value;
}

void showAsLines(boolean value) {
  isLinesOn = value;
  if (isLinesOn) cp5.getController("showPts").setValue(0);
}

void showPts(boolean value) {
  isPtsOn = value;
  if (isPtsOn) cp5.getController("showAsLines").setValue(0);
}

/* update filter size from filter controls */
void filterSize(int size) {
  filterSize = size;
}

public void minusSpeed() {
  frameRate(frameRate/2);
}
public void plusSpeed() {
  frameRate(frameRate*2);
}

public void timeLine(int value) {

  timeLine = value;
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(radioButton)) {
    trajectoryManager.clearMarkers();
    switch(int(theEvent.getValue())) {
    case 1:
      trajectoryManager.setNumberOfDaysToDisplay(10);
      break;
    case 2:
      trajectoryManager.setNumberOfDaysToDisplay(50);
      break;
    case 3:
      trajectoryManager.setNumberOfDaysToDisplay(150);
      break;
    }
  }
}


void drawIU() {

  int rawHour = int(timeLine / 60) + 8;
  int hour = rawHour;
  String daytime = "am";
  if (rawHour == 12) daytime = "pm";
  if (rawHour > 12) {
    hour = rawHour - 12;
    daytime = "pm";
  }
  if (rawHour >= 24) {
    hour = rawHour - 24;
    daytime = "am";
  }
  int min = int(timeLine % 60);
  fill(255, 255, 255, 255);
  strokeWeight(3);
  textSize(20);
  text(String.format("%02d:%02d%s", hour, min, daytime), sliderX, sliderY - 10);
  textSize(15);
  text("Speed", width-75, sliderY-12);
}



//------------------------Colour Markers-----------------------------------------------

/* Colour markers according to speed */
public void colourMarkers() {
  List<Trajectory> t = trajectoryManager.getMarkers();

  for (Trajectory m : t) {
    if (m.isActive()) {
      if ((!isFilterMode)&&(isColoursOn)) {                                              /* do not colour if in filter mode */
        float speed =  m.getCurrentSpeed();
        m.setColor(markerColourTable.findColour(speed));
      }
      m.setHidden(false); /* show if moving */
    } else {
      m.setHidden(true); /* Hide if not moving */
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    if (isPlay)
      isPlayIcon.setOff();
    else
      isPlayIcon.setOn();
  }
  else if (key == 'h') { // left
    timeLine--;
  }
  else if (key == 'l') { // right
    timeLine++;
  }
}

