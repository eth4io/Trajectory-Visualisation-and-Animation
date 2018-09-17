import  de.fhpotsdam.unfolding.*;
import  de.fhpotsdam.unfolding.geo.*;
import  de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.OpenStreetMap;
import controlP5.*;

UnfoldingMap map;

void setup() {
     size(800, 600);
     map = new UnfoldingMap(this, 0, 0, width, height, new OpenStreetMap.OpenStreetMapProvider());


     MapUtils.createDefaultEventDispatcher(this, map);

     String[][] tracklog = loadPlt("20081023025304.plt");
     println(tracklog[1]);
}

void draw() {
     map.draw();
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



