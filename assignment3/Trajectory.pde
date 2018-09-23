// trajectory class
// created by Michael Holmes, September 2018
// student number: 928428

import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class Trajectory extends SimplePointMarker {
  List<PositionData> positionData;
  PositionData currentPosition;
  int currentPositionIndex = 0;  //PositionData iterator
  
  /* creates new TrackPoint. pass in all associated data for this point as PositionData */
  public Trajectory(List<PositionData> data) {
    super(new Location(0,0));
    currentPosition = new PositionData();
    this.positionData = new ArrayList<PositionData>();
    
    /* add passed in data to this point's PositionData variable */
    for (int i = 0; i < data.size(); i++) {
      this.positionData.add(data.get(i));
    }
    //set to position 0 by default
    this.currentPosition = positionData.get(currentPositionIndex);
    //set initial loaction
    this.setLocation(currentPosition.lat, currentPosition.lng);
  }
  
  /* new from location */
  public Trajectory(Location location) {
    super(location);
    positionData = new ArrayList<PositionData>();
    currentPosition = new PositionData();
  }
  
  /* new empty */
  public Trajectory() {
    this(new Location(0, 0));
  }
  
  /* call at the end of the cycle
   * attention: check if the list `hasNext()` before invoke update()
   */
  public void update() {
    currentPositionIndex++;
    currentPosition = positionData.get(currentPositionIndex);
    this.setLocation(currentPosition.lat, currentPosition.lng);
  }
  
  
  // check if has next
  public boolean hasNext() {
    if (currentPositionIndex < positionData.size() - 1)
      return true;
    else
      return false;
  }
  
}
