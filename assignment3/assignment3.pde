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
  
}
 
void draw() {
  map.draw();
  barScale.draw();
}


String[][] loadPlt(String filename) {
  //loads a plt file, and returns a 2D String Array of tracklog
  //where tracklog[i] is a single trace line
  //tracklog[i][0] is the x coord and tracklog[i][1] is the y coord

  //tracklog starts from line 6 in trackfile
  String[] trackfile = loadStrings(filename);
  String[][] tracklog = new String[trackfile.length-6][7];
  for (int i =6; i<trackfile.length; i++) {
    tracklog[i-6] = split(trackfile[i], ",");
  }
  return tracklog;
}

