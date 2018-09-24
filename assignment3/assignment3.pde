/* Created by
 *  Angela Ryan 953452
 *  Michael Holmes 928428
 *  Yichi Zhang  895529
 * at 11/9/18
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.OpenStreetMap;
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

void setup() {
  size(800, 600);
  map = new UnfoldingMap(this, 0, 0, width, 
  height, new OpenStreetMap.OpenStreetMapProvider());

  //create bar scale
  barScale = new BarScaleUI(this, map, 10, height - 20);
  

  
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
  
  //test histogram
  float[] hist = new float[]{0.1,1.4,3.2,7,9.2};
  Histogram histoTest = new Histogram(0.5,hist);
}

void draw() {
  map.draw();
  //test radius variable
  trajectoryManager.setRadiusToValue(frameCount, 10, 1000,false);
  //some colors testing
  trajectoryManager.setAllColor(color(150,150,200));

  trajectoryManager.draw();

  barScale.draw();
  
  trajectoryManager.updateAll();
}



