import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class Trajectory extends SimplePointMarker {
  List<PositionData> positionData;
  PositionData nextPosition;
  PositionData currentPosition;
  int currentPositionIndex = 0;  //PositionData iterator
  
  /* creates new TrackPoint. pass in all associated data for this point as PositionData */
  public Trajectory(List<PositionData> data) {
    super();
    nextPosition = new PositionData();
    currentPosition = new PositionData();
    this.positionData = new ArrayList<PositionData>();
    
    /* add passed in data to this point's PositionData variable */
    for (int i = 0; i < data.size(); i++) {
      this.positionData.add(data.get(i));
    }
    //set to position 0 by default
    this.currentPosition = positionData.get(currentPositionIndex);
  }
  
  /* new from location */
  public Trajectory(Location location) {
    super(location);
    positionData = new ArrayList<PositionData>();
    nextPosition = new PositionData();
    currentPosition = new PositionData();
  }
  
  /* new empty */
  public Trajectory() {
    super(new Location(0,0));
    positionData = new ArrayList<PositionData>();
    nextPosition = new PositionData();
    currentPosition = new PositionData();
  }
  
  //call at the end of the cycle
  public void update() {
    currentPosition = nextPosition;
    this.setLocation(currentPosition.lat, currentPosition.lng);
  }
  
  //pushes next location in List to nextPosition
  public void next() {
    if (currentPositionIndex < positionData.size()) {
      currentPositionIndex++;
      nextPosition = positionData.get(currentPositionIndex);
    }
    
    
  }
  
}
