import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;

class GLPoint extends SimplePointMarker {
  //is Y, X
  float altitude;
  Date dateStamp;
  
  public GLPoint(Location l, Date
  
  /* default constructor, will default to system date/time */
  public GLPoint(Location l) {
    super(l);
    Date = new Date();
  
  }
}
