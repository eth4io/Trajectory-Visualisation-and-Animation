import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class Trajectory extends SimplePointMarker {
  List<PositionData> PositionData;
  PositionData nextPosition;
  PositionData currentPosition;
  /* creates new TrackPoint. pass in all associated data for this point as PositionData */
  public Trajectory(List<PositionData> data) {
    super();
    nextPosition = new PositionData();
    this.PositionData = new ArrayList<PositionData>();
    
    /* add passed in data to this point's PositionData variable */
    for (int i = 0; i < data.size(); i++) {
      this.PositionData.add(data.get(i));
    }
  }
  
  /* new from location */
  public Trajectory(Location location) {
    super(location);
    PositionData = new ArrayList<PositionData>();
  }
  
  /* new empty */
  public Trajectory() {
    super(new Location(0,0));
    PositionData = new ArrayList<PositionData>();
  }
  
  public void update() {
<<<<<<< HEAD
    this.set
=======
  
>>>>>>> master
  }
  
}
