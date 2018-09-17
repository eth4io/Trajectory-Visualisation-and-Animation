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

static final Location BEIJING_CENTRAL =            /* study location */
new Location(39.907614, 116.397334);


//-----------------------  Global Variables ------------------------

UnfoldingMap map;
BarScaleUI barScale;                      /* bar scale object */


void setup() {
  size(800, 600);
  map = new UnfoldingMap(this, 0, 0, width, 
  height, new OpenStreetMap.OpenStreetMapProvider());

  //create bar scale
  barScale = new BarScaleUI(this, map, 10, height - 20);

  //pan and zoom to study location
  map.zoomAndPanTo(BEIJING_CENTRAL, 11);

  MapUtils.createDefaultEventDispatcher(this, map);
  //test of loadPlt method
  String[][] tracklog = loadPlt(DATA_DIR + "000" +
    FILE_SEPARATOR + "Trajectory" + FILE_SEPARATOR + "20081023025304.plt");
  println(tracklog[0]);
}

void draw() {
  map.draw();
  barScale.draw();
}


String[][] loadPlt(String filename) {
  //loads a plt file, and returns a 2D String Array of tracklog
  //where tracklog[i] is a single trace line
  //tracklog[i][0] is the latitude and tracklog[i][1] is the longitude
  //[2] is empty (always 0), [3] is altitude in feet (always an int)
  //[4] is the date as a number (no. of days since 12/30/1899, w/ a fraction for time
  //[5] is the date as a string "YEAR/MONTH/DAY"
  //[6] is the time as a string "HR:MN:SE"

  //tracklog starts from line 6 in trackfile
  String[] trackfile = loadStrings(filename);
  String[][] tracklog = new String[trackfile.length-6][7];
  for (int i =6; i<trackfile.length; i++) {
    tracklog[i-6] = split(trackfile[i], ",");
  }
  return tracklog;
}

