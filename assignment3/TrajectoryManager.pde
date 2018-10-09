// extention class for Marker Manager for working with trajectories
// created September 2018
// student number: 928428

import java.util.Map;
import de.fhpotsdam.unfolding.marker.*;

class TrajectoryManager extends MarkerManager {
  
  private List<List<Trajectory>> listOfTrajectoryList;
  private static final int DEFAULT_DRAW = 10;    //default draw level if not set
  private static final int DEFAULT_NUMBER_OF_DAYS = 10;
  private int drawLevel;                  //the draw level control
  private Date startTime;
  private Date endTime;
  
  public TrajectoryManager() {
    super();
    drawLevel = DEFAULT_DRAW;
  }
  
  public TrajectoryManager(List<List<Trajectory>> listOfTrajectoryList) {
    this(listOfTrajectoryList, DEFAULT_DRAW, DEFAULT_NUMBER_OF_DAYS);
  }
  
  public TrajectoryManager(List<List<Trajectory>> listOfTrajectoryList,
      int drawLevel, int numberOfDays) {
    this.listOfTrajectoryList = listOfTrajectoryList;
    this.drawLevel = drawLevel;
    setNumberOfDaysToDisplay(numberOfDays);
  }
  
  
  public void setNumberOfDaysToDisplay(int numberOfDays) {
    List<Trajectory> trajectoryList = new ArrayList<Trajectory>();
    for (int i = 0; i < numberOfDays || i < listOfTrajectoryList.size(); i++) {
      trajectoryList.addAll(listOfTrajectoryList.get(i));
    }
    this.setMarkers(trajectoryList);
  }
  
  
  /* sets fill, stroke and stroke weight all at once */
  public void setStyle(color fillColor, color strokeColor, int strokeWeight) {
    List<Marker> temp = this.getMarkers();
      
    for (Marker m : temp) {
      m.setColor(fillColor);
      m.setStrokeColor(strokeColor);
      m.setStrokeWeight(strokeWeight);
    }
    this.setMarkers(temp);
  }
  
  /* set fill for all */
  public void setAllColor(color fillColor) {
    List<Marker> temp = this.getMarkers();
      
    for (Marker m : temp) {
      m.setColor(fillColor);
    }
    this.setMarkers(temp);
  }
  
  /* set stroke colour for all */
  public void setAllStrokeColor(color strokeColor) {
    List<Marker> temp = this.getMarkers();
      
    for (Marker m : temp) {
      m.setStrokeColor(strokeColor);
    }
    this.setMarkers(temp);
  }
  
  /* set weight for all */
  public void setAllStrokeWeight(int strokeWeight) {
    List<Marker> temp = this.getMarkers();
      
    for (Marker m : temp) {
      m.setStrokeWeight(strokeWeight);
    }
    this.setMarkers(temp);
  }
  
  /* sets point radius for all */
  public void setPointRadius(float radius) {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      ((SimplePointMarker)m).setRadius(radius);
    }
    this.setMarkers(temp);
  }
  
  /* sets point radius for all based on a value, can be inverted */
  public void setRadiusToValue(float value, float min, float max, boolean invert) {
    List<Marker> temp = this.getMarkers();

    for (Marker m : temp) {
      // check for invert, map value, min, max, radius low, radius high
      float rad = invert ? map(value, max, min, 1.0, 10.0) 
        : map(value, min, max, 1.0, 10.0);
      ((SimplePointMarker)m).setRadius(rad);
    } 
    this.setMarkers(temp);
  }
  
  //takes care of mouse over and returns properties for marker if marker found
  public Marker checkMouseOver(float x, float y) {
    //performance issues on highlighting on passover
    this.setAllStrokeWeight(1);
    Marker m = this.getFirstHitMarker(x,y);  //look for fist marker
    if (m != null) {                         //if marker found
      m.setStrokeWeight(3);                  //set stroke to 3
      return m;                              // return marker for data
    }
    return null;
  }
  
  /* checls if a marker has been clicked, selects marker and returns this marker */
  public Trajectory checkClick(float x, float y) {
    List<Marker> temp = this.getMarkers();
    boolean isClicked = false;
    Trajectory t = new Trajectory();
    
    for (Marker m : temp) {
      if (m.isInside(map, x, y)) {
          m.setSelected(true);
          t = (Trajectory) m;
          isClicked = true;
        } else {
          m.setSelected(false);
        } 
      }
    this.setMarkers(temp);
    return isClicked ? t : null;
  }
  
  
  /* return all markers flagged selected */
  public List<Marker> getSelected() {
    List<Marker> temp = this.getMarkers();
    List<Marker> selected = new ArrayList<Marker>();
    
    for (Marker m : temp) {
        if (m.isSelected()) {
          selected.add(m);
        }
    }
    return selected;
  }
  
  /* deselect all markers */
  public void deselectAll() {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      m.setSelected(false);
    }
  this.setMarkers(temp);
  }
  
  //call update for all trajectories
  public void updateAll() {
     List<Marker> temp = this.getMarkers();
     for (Marker m : temp) {
       if (((Trajectory)m).hasNext())
         ((Trajectory)m).update();
     }
  }
  
  public void updateAll(float progress) {
    float timeDiff = getTimeDiff(startTime, endTime);
    float elapsedTime = timeDiff * progress;
    Date currentTime = new Date();
    currentTime.setTime(startTime.getTime() + (int)elapsedTime);
    List<Marker> temp = this.getMarkers();
     for (Marker m : temp) {
       if (((Trajectory)m).hasNext())
         ((Trajectory)m).update(currentTime);
     }
  }

  private float getTimeDiff(Date date0, Date date1) {
    float diff = abs(date0.getTime() - date1.getTime());
    return diff;
  }

  //get and set the draw level
  public void setDrawLevel(int x) { this.drawLevel = x; }
  public int getDrawLevel() { return this.drawLevel; }
  
  public void setTimeRange(Date startTime, Date endTime) {
    this.startTime = startTime;
    this.endTime = endTime;
  }
  
  public float calcAvgSpeed(float progress) {
    //return average speed of current array list
    float timeDiff = getTimeDiff(startTime, endTime);
    float elapsedTime = timeDiff * progress;
    Date currentTime = new Date();
    currentTime.setTime(startTime.getTime() + (int)elapsedTime);
    List<Marker> markers = this.getMarkers();
    float speedSum = 0;
    for (Marker m : markers) {
      if (((Trajectory)m).hasNext()){
        ((Trajectory)m).update(currentTime);
        speedSum = speedSum + ((Trajectory)m).getCurrentSpeed();
      }
    } 
    return speedSum / markers.size();
  }
}
