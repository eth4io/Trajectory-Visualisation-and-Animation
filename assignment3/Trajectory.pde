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
  
  //speed variables
  private float currentSpeed = 0;
  private float movingAverageSpeed = 0;
  private float[] speedArray = new float[]{0,0,0};
  //end speed variables
  
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
    //update speed
    this.updateSpeed();
    println(currentSpeed);
  }
  
  /* updates current speed based on previous position record */
  private void updateSpeed() {
    //do not check if first element
    if (currentPositionIndex > 0) {
      //temporary position for calulating
      PositionData lastPos = new PositionData();
      lastPos = positionData.get(currentPositionIndex - 1).copy();
      //get time difference in milliseconds from current time - last time
      float timeDiff = abs(currentPosition.getCreatedTime().getTime()
                       - lastPos.getCreatedTime().getTime());
      //remove miliseconds
      timeDiff /= 1000;
      //seconds to hours
      timeDiff /= 3600;
      //calculate distance / speed to get km per hour
      currentSpeed = (float) this.getDistanceTo(new Location(lastPos.getLat(), lastPos.getLng()))/timeDiff;
      //copy down speed array
      for (int i = speedArray.length; i > 0 ; i--) {
        speedArray[i - 1] = speedArray[i];
      }
      //load new current speed
      speedArray[speedArray.length] = currentSpeed;
      
      //calculate average speed from speed array
      movingAverageSpeed = 0;
      for (int i = 0; i < speedArray.length; i++) {
        movingAverageSpeed += speedArray[i];
      }
      
    }
  }
  // check if has next
  public boolean hasNext() {
    if (currentPositionIndex < positionData.size() - 1)
      return true;
    else
      return false;
  }
  
  //returns current speed in km/h
  public float getCurrentSpeed() {
    return this.currentSpeed;
  }
  
}
