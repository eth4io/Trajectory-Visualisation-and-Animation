// extention class for Marker Manager for working with trajectories
// created by Michael Holmes, September 2018
// student number: 928428

import java.util.Map;

class ExtManager extends MarkerManager {
  
  private final int DEFAULT_DRAW = 10;    //default draw level if not set
  private int drawLevel;                  //the draw level control
  
  public ExtManager(List<Marker> m) {
    super(m);
    drawLevel = DEFAULT_DRAW;
  }
  
  public ExtManager(List<Marker> m, int drawLevel) {
    super(m);
    this.drawLevel = drawLevel;
  }
  
  public ExtManager() {
    super();
    drawLevel = DEFAULT_DRAW;
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
      m.setRadius(radius);
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
      m.setRadius(rad);
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
  public Marker checkClick(float x, float y) {
    List<Marker> temp = this.getMarkers();
      
    for (Marker m : temp) {
      if (m.isInside(map, x, y)) {
        if (m.isSelected()) {
          m.setSelected(false);
        } else {
          m.setSelected(true);
          return m;
        }
      }
    }
  this.setMarkers(temp);
  return null;
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
  
  //get and set the draw level
  public void setDrawLevel(int x) { this.drawLevel = x; }
  public int getDrawLevel() { return this.drawLevel; }
}
