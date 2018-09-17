import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class TrackPoint extends SimplePointMarker {
  List<TrackData> trackData;
  
  /* creates new TrackPoint. pass in all associated data for this point as TrackData */
  public TrackPoint(Location l, List<TrackData> data) {
    super(l);
    
    this.trackData = new ArrayList<TrackData>();
    
    /* add passed in data to this point's trackData variable */
    for (int i = 0; i < data.size(); i++) {
      this.trackData.add(data.get(i));
    }
  }
}
