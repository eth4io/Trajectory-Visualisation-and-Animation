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


final Location beijingCentral =            /* study location */
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
  map.zoomAndPanTo(beijingCentral, 11);
  
  MapUtils.createDefaultEventDispatcher(this, map);
  
}
 
void draw() {
  map.draw();
  barScale.draw();
}
