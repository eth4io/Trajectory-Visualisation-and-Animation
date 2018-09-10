import  de.fhpotsdam.unfolding.*;
import  de.fhpotsdam.unfolding.geo.*;
import  de.fhpotsdam.unfolding.utils.*;

UnfoldingMap map;
 
void setup() {
        size(800, 600);
        map = new UnfoldingMap(this);
        MapUtils.createDefaultEventDispatcher(this, map);
}
 
void draw() {
    map.draw();
}
