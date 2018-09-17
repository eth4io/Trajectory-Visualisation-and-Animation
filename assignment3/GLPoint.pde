import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class GLPoint extends SimplePointMarker {
  //is Y, X
  float altitude;
  Date dateStamp;
  
  
  /* default constructor, will default to system date/time */
  public GLPoint(Location l) {
    super(l);
    dateStamp = new Date();
  
  }
}
