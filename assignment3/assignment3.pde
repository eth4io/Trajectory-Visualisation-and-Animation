import  de.fhpotsdam.unfolding.*;
import  de.fhpotsdam.unfolding.geo.*;
import  de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.OpenStreetMap;
import controlP5.*;

UnfoldingMap map;
 
void setup() {
        size(800, 600);
        map = new UnfoldingMap(this, 0, 0, width, 
    height, new OpenStreetMap.OpenStreetMapProvider());
        
        
        MapUtils.createDefaultEventDispatcher(this, map);
        
        // new comment
}
 
void draw() {
    map.draw();
}
