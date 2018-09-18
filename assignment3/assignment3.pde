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
  println()
    //test trackpoint
  Trajectory testTraj = new Trajectory(testerData);
  testTraj.update();
  map.addMarker(testTraj);
  
}

void draw() {
  map.draw();
  barScale.draw();
}



