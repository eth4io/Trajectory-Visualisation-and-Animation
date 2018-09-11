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

UnfoldingMap map;
 
void setup() {
  size(800, 600);
  map = new UnfoldingMap(this, 0, 0, width, 
  height, new OpenStreetMap.OpenStreetMapProvider());
  
  MapUtils.createDefaultEventDispatcher(this, map);
  
}
 
void draw() {
  map.draw();
}
