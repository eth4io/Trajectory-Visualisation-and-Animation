// trajectory class
// created by Michael Holmes, September 2018
// student number: 928428

import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.util.Queue;
import java.util.LinkedList;
import java.text.*;

class Trajectory extends SimplePointMarker {
  private static final int SPEED_SMOOTHING_SIZE = 10;
  private List<PositionData> positionData;
  private PositionData currentPosition;
  private int currentPositionIndex = 0;  //PositionData iterator

  //speed variables
  private float currentSpeed = 0;
  private float movingAverageSpeed = 0;
  private float movingMaxSpeed = 0;
  private Queue<Float> speedQueue = new LinkedList();
  //end speed variables

  /* creates new TrackPoint. pass in all associated data for this point as PositionData */
  public Trajectory(List<PositionData> data) {
    super(new Location(0, 0));
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
  }

  /* updates current speed based on previous position record */

  private void updateSpeed() {
    // update current speed
    float currentSpeed = getSpeedByIndex(currentPositionIndex);

    // update average speed
    float speedSum = movingAverageSpeed * speedQueue.size();
    if (speedQueue.size() == 0) {
      movingMaxSpeed = 0;
      movingAverageSpeed = 0;
    }
    else if (speedQueue.size() >= SPEED_SMOOTHING_SIZE) {
      speedSum -= speedQueue.remove();
    }
    speedQueue.add(currentSpeed);
    speedSum += currentSpeed;
    movingAverageSpeed = speedSum / speedQueue.size();

    // update max speed
    if (currentSpeed > movingMaxSpeed)
      movingMaxSpeed = currentSpeed;

    // log for debugging
    // println(currentPositionIndex, "curSpeed: ", currentSpeed, '\t',
    //   "moving ave speed: ", movingAverageSpeed, '\t', "size: ", speedQueue.size());
  }

  // check if has next
  public boolean hasNext() {
    if (currentPositionIndex < positionData.size() - 1)
      return true;
    else
      return false;
  }

  private float getSpeedByIndex(int index) {
    if (index == 0) {
      return 0;
    }
    PositionData lastPosition = positionData.get(index - 1);
    //get time difference in milliseconds from current time - last time
    float timeDiff = abs(currentPosition.getCreatedTime().getTime()
      - lastPosition.getCreatedTime().getTime());
    //remove miliseconds and seconds
    timeDiff /= 1000 * 3600;
    float distanceDiff = (float) this.getDistanceTo(new Location(lastPosition.getLat(), lastPosition.getLng()));

    if (Float.isNaN(distanceDiff) || timeDiff == 0)
      return 0;
    //calculate distance / speed to get km per hour
    return distanceDiff / timeDiff;
  }

  //returns an array on float for speed at every position
  //CAUTION: heavy processing power required. do not call frequently
  public float[] getSpeedData() {
    float[] speedArray = new float[positionData.size()];

    for (int i = 0; i < positionData.size(); i++) {
      speedArray[i] = getSpeedByIndex(i);
    }
    return speedArray;
  }

  //getters
  public float getCurrentSpeed() { return this.currentSpeed; }
  public float getMovingAverageSpeed() { return this.movingAverageSpeed; }
  public float getMovingMaxSpeed() { return this.movingMaxSpeed; }
  public int getCurrentPositionIndex() { return currentPositionIndex; }
  //setters
  public void setCurrentPositionIndex(int i) { this.currentPositionIndex = i; }
}

