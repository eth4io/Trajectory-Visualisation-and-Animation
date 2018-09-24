// trajectory class
// created by Michael Holmes, September 2018
// student number: 928428

import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.text.*;

class Trajectory extends SimplePointMarker {
  List<PositionData> positionData;
  PositionData currentPosition;
  private int currentPositionIndex = 0;  //PositionData iterator
  
  //speed variables
  private float currentSpeed = 0;
  private float movingAverageSpeed = 0;
  private float movingMaxSpeed = 0;
  private float[] speedArray = new float[10];
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
    //println(this, "moving ave speed:", movingAverageSpeed);
  }
  
  /* updates current speed based on previous position record */
  
  private void updateSpeed() {
    //do not check if first element
    if (currentPositionIndex > 0) {
      //temporary position for calulating
      PositionData lastPos = new PositionData();
      lastPos = positionData.get(currentPositionIndex - 1);
      //get time difference in milliseconds from current time - last time
      float timeDiff = abs(currentPosition.getCreatedTime().getTime()
                       - lastPos.getCreatedTime().getTime());
      //remove miliseconds
      timeDiff /= 1000;
      //seconds to hours
      timeDiff /= 3600;
      //calculate distance / speed to get km per hour
      currentSpeed = (float) this.getDistanceTo(new Location(lastPos.getLat(), lastPos.getLng())) / timeDiff;
      
      //move down speed array and bump elements up
      for (int i = speedArray.length - 1; i > 0; i--) {
        speedArray[i] = speedArray[i - 1];
      }
      //load new current speed into first element
      speedArray[0] = currentSpeed;
      
      //calculate moving average speed and moving max speed from speed array
      movingAverageSpeed = movingMaxSpeed = 0;
      for (int i = 0; i < speedArray.length; i++) {
        //sum for average
        movingAverageSpeed += speedArray[i];
        //check max
        if (speedArray[i] > movingMaxSpeed) {
          movingMaxSpeed = speedArray[i];
        }
      }
      //divide sum by n to get average
      movingAverageSpeed /= speedArray.length;

    }
  }
  
  // check if has next
  public boolean hasNext() {
    if (currentPositionIndex < positionData.size() - 1)
      return true;
    else
      return false;
  }
  //returns an array on float for speed at every position
  //CAUTION: heavy processing power required. do not call frequently
  public float[] getSpeedData() {
    float[] temp = new float[positionData.size()];
    int i, j;
    
    i = 1;
    j = 0;
    for (; i < positionData.size(); i++, j++) {
      PositionData p1 = new PositionData();
      PositionData p2 = new PositionData();
      float diff = 0;
      
      p1 = positionData.get(i);
      p2 = positionData.get(i-1);
      Location l = new Location(p1.getLat(), p1.getLng());
      diff = abs(p1.getCreatedTime().getTime() -
                 p2.getCreatedTime().getTime());
      diff /= 1000;
      diff /= 3600;
      temp[j] = (float) l.getDistance(new Location(p2.getLat(), p2.getLng())) / diff;
    }
    return temp;
  }
  
  //getters
  public float getCurrentSpeed() { return this.currentSpeed; }
  public float getMovingAverageSpeed() { return this.movingAverageSpeed; }
  public float getMovingMaxSpeed() { return this.movingMaxSpeed; }
  public int getCurrentPositionIndex() { return currentPositionIndex; }
  //setters
  public void setCurrentPositionIndex(int i) { this.currentPositionIndex = i; }
}
