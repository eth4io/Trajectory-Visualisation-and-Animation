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

static final Location BEIJING_CENTRAL =            /* study location */
new Location(39.907614, 116.397334);


//-----------------------  Global Variables ------------------------

UnfoldingMap map;
BarScaleUI barScale;                      /* bar scale object */
DataReader dataReader;

//test
TrajectoryManager trajectoryManager;
List<Trajectory> testTraj;
//----------- Slider Variables ----------------
ControlP5  cp5;
int sliderX, sliderY, sliderW, sliderH;
boolean play = true;
CColor  controlsColours;
int timeLine;
int time;

void setup() {
  size(800, 600);
  map = new UnfoldingMap(this, 0, 0, width, 
  height, new EsriProvider.WorldGrayCanvas());

  //create bar scale
  barScale = new BarScaleUI(this, map, 10, height - 20);

  //initialise UI
  frameRate(5);
  controlsColours  =  new  CColor(0x99ffffff, 0x55ffffff, 0xffffffff, 0xffffffff, 
  0xffffffff);
  sliderW=350;
  sliderH=10;
  sliderX = width/2 - sliderW/2;
  sliderY = height - 40;
  initialiseUI();

  //pan and zoom to study location
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);

  MapUtils.createDefaultEventDispatcher(this, map);


  /* test of DataReader method */
  dataReader = new DataReader();

  List<PositionData> testerData = dataReader.getTesterDataByIndex(0);

  print("[" + 0 + "]: " + testerData.size() + " points\t");
  println(testerData.get(0).getLat(), testerData.get(0).getLng());

  //test trajectory manager
  testTraj = new ArrayList<Trajectory>();
  testTraj.add(new Trajectory(testerData));
  trajectoryManager = new TrajectoryManager(testTraj);
  trajectoryManager.setMap(map);
}

void draw() {
  map.draw();
  //test radius variable
  //trajectoryManager.setRadiusToValue(frameCount, 10, 1000,false);
  //some colors testing
  //trajectoryManager.setAllColor(color(150,150,200));

  //trajectoryManager.draw();

  //trajectoryManager.nextAll();
  //barScale.draw();

  //trajectoryManager.updateAll();
  drawIU();
}

void initialiseUI() {
  cp5 =  new  ControlP5(this);
  cp5.addSlider("timeLine")
    .setPosition(sliderX, sliderY)
      .setSize(sliderW, sliderH)
        .setRange(0, 1440) 
          .showTickMarks(true)
            .setNumberOfTickMarks(23)
              .setColor(controlsColours)
                .setLabelVisible(false)
                  //.listen(true)
                    ;



  cp5.addButton("pause")
    .setPosition(width/2, height/2)
        //.setSize(10, 10)
        .setImage(loadImage("playPause.png"))
          .setSize(30,30);
          
  ;


  //  cp5.addButton("play")
  //    .setPosition(sliderX +sliderW/2+ 10, sliderY-20)
  //      .setSize(10, 10)
  //        .setColor(controlsColours);
}

void pause() {
  play = false;
}
void play() {
  play = true;
}
void drawIU() {
  fill(50, 50);
  noStroke();
  rect(sliderX-40, sliderY-40, sliderW+80, sliderH+80, 7);
  int hour = int(timeLine/60);
  int min = int(timeLine%60);
  fill(255);
  text(String.format("%02d:%02d", hour, min), sliderX, sliderY-10);
  timeLine++;
  //time = timeLine;
  //not working.. idk why. A problem for another day
  //cp5.getController("timeLine").setValue(time);
}

