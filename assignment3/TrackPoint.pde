import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class TrackPoint extends SimplePointMarker {
  //is Y, X
  float altitude;
  Date dateStamp;
  
  
  /* default constructor, will default to system date/time */
  public TrackPoint(Location l) {
    super(l);
    Date = new Date();
  
  }
}
