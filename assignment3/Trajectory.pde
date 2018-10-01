// trajectory class
// created September 2018
//

import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.util.Queue;
import java.util.LinkedList;
import java.text.*;

class Trajectory extends SimplePointMarker {
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
  }

  /* updates current speed based on previous position record */


  // check if has next
  public boolean hasNext() {
    if (currentPositionIndex < positionData.size() - 1)
      return true;
    else
      return false;
  }

  //getters
  public float getCurrentSpeed() { return this.currentSpeed; }
  public float getMovingAverageSpeed() { return this.movingAverageSpeed; }
  public float getMovingMaxSpeed() { return this.movingMaxSpeed; }
  public int getCurrentPositionIndex() { return currentPositionIndex; }
  //setters
  public void setCurrentPositionIndex(int i) { this.currentPositionIndex = i; }
}

