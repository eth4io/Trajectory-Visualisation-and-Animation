import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class TrackPoint extends SimplePointMarker {
  List<TrackData> trackData;
  
  /* creates new TrackPoint. pass in all associated data for this point as TrackData */
  public TrackPoint(List<TrackData> data) {
    super();
    this.trackData = new ArrayList<TrackData>();
    
    /* add passed in data to this point's trackData variable */
    for (int i = 0; i < data.size(); i++) {
      this.trackData.add(data.get(i));
    }
  }
  
  /* new from location */
  public TrackPoint(Location location) {
    super(location);
    trackData = new ArrayList<TrackData>();
  }
  
  /* new empty */
  public TrackPoint() {
    super(new Location(0,0));
    trackData = new ArrayList<TrackData>();
  }
  
}
