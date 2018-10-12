// trajectory class
// created September 2018
//

import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.Date;
import java.util.Queue;
import java.util.LinkedList;
import java.text.*;

class Trajectory extends SimplePointMarker {
  private String id;
  private List<PositionData> positionData;
  private PositionData currentPosition;
  private int currentPositionIndex = 0;  //PositionData iterator

  //speed variables
  private float currentSpeed = 0;
  //private float movingAverageSpeed = 0;
  //private float movingMaxSpeed = 0;
  private Queue<Float> speedQueue = new LinkedList();
  //end speed variables
  private boolean isActive;

  /* creates new TrackPoint. pass in all associated data for this point as PositionData */
  public Trajectory(String id, List<PositionData> data) {
    super(new Location(0, 0));
    this.id = id;
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
    this.isActive = true;
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
    //set speed to 0 if at end of data
    if (this.hasNext()) {
      this.currentSpeed = this.currentPosition.getSpeed();                /* update speed variable */
    } else {
      currentSpeed = 0;
    }
  }

  public void update(Date currentTime) {
    for (int i = 0; i < positionData.size(); i++) {
      currentPosition = positionData.get(i);

      if ((currentPosition.getCreatedTime().getTime() % (1000 * 3600 * 24)
        - currentTime.getTime() % (1000 * 3600 * 24) > 0)
        && (currentPosition.getCreatedTime().getTime() % (1000 * 3600 * 24)
        - (currentTime.getTime() % (1000 * 3600 * 24) + 1000 * 60) < 0)) {
        this.setLocation(currentPosition.lat, currentPosition.lng);
        this.currentSpeed = this.currentPosition.getSpeed();                /* update speed variable */
        isActive = true;
        return;
      }
    }
    isActive = false;
  }
  
  public boolean isMoving() {
    PositionData previousPosition = positionData.get(currentPositionIndex);
    Location previousLocation = new Location(previousPosition.lat, previousPosition.lng);
    double distance = this.getDistanceTo(previousLocation);
    if (distance < 3) return false;
    else return true;
  }
  
  public boolean isActive() {
    return isActive;
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
  //public float getMovingAverageSpeed() { return this.movingAverageSpeed; }
  //public float getMovingMaxSpeed() { return this.movingMaxSpeed; }
  public int getCurrentPositionIndex() { return currentPositionIndex; }
  public List<PositionData> getPositionData () { return this.positionData; }
  public PositionData getCurrentPosition() { return this.currentPosition; }
  
  public float getX(UnfoldingMap map) {
    ScreenPosition sp = map.getScreenPosition(this.getLocation());
    return sp.x;
  }
  
  public float getY(UnfoldingMap map) {
    ScreenPosition sp = map.getScreenPosition(this.getLocation());
    return sp.y;
  }
  
  public String getId() {
    return id;
  }
  
  //setters
  public void setCurrentPositionIndex(int i) { this.currentPositionIndex = i; }
  
  
  

}

