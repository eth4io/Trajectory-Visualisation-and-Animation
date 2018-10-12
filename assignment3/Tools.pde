/* Tools file 
 * 
 * List of Tools:
 * - radius filter 
 * - filter manager
 * - histogram
 *
 * Statics:
 * - explore trajectory
 * 
 */

import org.gicentre.utils.stat.*;                          /* for charts */
import de.fhpotsdam.unfolding.utils.GeoUtils.*; 
import de.fhpotsdam.unfolding.marker.SimpleLinesMarker;

static class Tools {
  
/* reads entire positionData file for a trajectory,
 * creates line segments and colours according to speed,
 * and adds to Marker Manager.
 * 
 * precondition marker manager must be initilised 
 * and assigned to an UnfoldingMap
 *
 * returns true if successful, otherwise false
 * 
 * ask Michael for Q&A
 */
  public static boolean exploreTrajectory(Trajectory t, MarkerManager mm, ColourTable ct) 
  {
    if (mm.getMarkers() != null) {                                                  /* clear marker manager if not empty */
      mm.clearMarkers();
    }
    for (int i = 0; i < t.getPositionData().size() - 1; i++) {                      /* create line shape while i < n-1 */
      Location a = new Location(                                                    /* set location i */
          t.getPositionData().get(i).getLat(),                                       
          t.getPositionData().get(i).getLng());
      Location b = new Location(                                                    /* set locaiton i + 1 */                                  
          t.getPositionData().get(i+1).getLat(), 
          t.getPositionData().get(i+1).getLng());
          
      if (GeoUtils.getDistance(a, b) <= 2) {                                        /* check for sample errors > 2km apart */
        SimpleLinesMarker slm = new SimpleLinesMarker(a, b);
        slm.setStrokeWeight(3);
        slm.setColor(ct.findColour(t.getPositionData().get(i+1).getSpeed()));       /* set colour of line segment based on i+1 speed */
        mm.addMarker(slm);  
      }                                                  
    }
    return mm.getMarkers().size() > 0 ? true : false;                               /* test if anything loaded */
  }
}

/* class for radius filter
 * calculated from actual distances.
 * unit is Kilometres
 * 
 * ask Michael for Q&A
 */
class RadiusFilter extends SimplePointMarker  {
  private float rad_km = 20;
  private boolean placed = false;
  
  public RadiusFilter(color c) 
  {                                       
    super(new Location(0,0));
    //this.setColor(c/*color(255,0,0,50)*/);
    this.setStrokeColor(c);
    this.setStrokeWeight(3);
    this.setColor(color(255,255,255, 0));
  }
  
  /* cycle updates for the filter */
  public void update(UnfoldingMap map) 
  {
    if (!placed) {
      this.setLocation(map.getLocation(mouseX, mouseY));
    }
  }
  
  /* returns list of markers that are within this filter */
  public List<Trajectory> getWithinRadius(UnfoldingMap map, List<Trajectory> markers) 
  {
    int pfound = 0;
    List<Trajectory> found = new ArrayList<Trajectory>();
    double dist = GeoUtils.getDistance(this.getLocation(), 
      GeoUtils.getDestinationLocation(this.getLocation(), 0, rad_km));
    
    for (Trajectory m : markers) {
      if(!m.isActive())
        continue;
      double diff = GeoUtils.getDistance(m.getLocation(),
        this.getLocation());
      if (diff < dist/2 && m.isMoving()) {
        m.setSelected(true);
        found.add(m);
      } else {
        if (m.isSelected()) {
          //m.setSelected(false);
        }
      }
      if (m.isSelected()) pfound++;
    }
    println(pfound);
    return found;
  }
  
  public void setFilterRadius(UnfoldingMap map, float kms) 
  {
    this.rad_km = kms;
    Location radPos = GeoUtils.getDestinationLocation(this.getLocation(), 0, kms);
    ScreenPosition radScreen = map.getScreenPosition(radPos);
    ScreenPosition centreScreen = map.getScreenPosition(this.getLocation());
    
    float actualRad = PApplet.dist(radScreen.x, radScreen.y, centreScreen.x, centreScreen.y);
    this.setRadius(actualRad);
    
  }
  
  public void setPlaced(boolean b) { this.placed = b; }
  
  public boolean getPlaced() {return this.placed;}
}

class FilterManager extends MarkerManager {
  
  public FilterManager() {
    super();
  }
  
  public void addFilter(color c)
  {
    this.addMarker(new RadiusFilter(c));
  }
  
  public void setAllHidden(boolean b) 
  {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      m.setHidden(b);
    }
    this.setMarkers(temp);  
  }
  
  public void updateAll(UnfoldingMap map) {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      ((RadiusFilter)m).update(map);
    }
    this.setMarkers(temp); 
  }
  
  public void setAllFilterRadius(UnfoldingMap map, float kms)
  {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      ((RadiusFilter)m).setFilterRadius(map, kms);
    }
    this.setMarkers(temp);
  }
  
  public void placeFilter(UnfoldingMap map) 
  {
    List<Marker> temp = this.getMarkers();
    
    for (Marker m : temp) {
      if (!((RadiusFilter)m).getPlaced()) {
        ((RadiusFilter)m).setPlaced(true);
      }
    }
    this.setMarkers(temp);
  }
  
  public List<List<Trajectory>> getAllWithinRadius(UnfoldingMap map, List<Trajectory> markers)
  {
    List<Marker> temp = this.getMarkers();
    List<List<Trajectory>> listOfTraj = new ArrayList<List<Trajectory>>();
    for (Marker m : temp) {
      List<Trajectory> traj = new ArrayList<Trajectory>();
      traj = ((RadiusFilter) m).getWithinRadius(map, markers);
      listOfTraj.add(traj);
    }
    return listOfTraj;
  }
}


/* histogram class for displaying data frequency
 * ask Michael for Q&A
 */
class Histogram {
   
  private float[] bins;
  private float[] values;
  //private float maxValue = 0;
  private String[] labels;
  private BarChart barChart;

  
  public Histogram(float[] bins, float[] data, PApplet PObj) 
  {
    labels = new String[bins.length];
    update(bins, data);
    
    barChart = new BarChart(PObj);
    barChart.setData(this.values);
    barChart.showValueAxis(true);
    barChart.setValueFormat("#.#");
    barChart.setBarLabels(labels);
    barChart.showCategoryAxis(true);
    barChart.transposeAxes(true);
    barChart.setMinValue(0);
    barChart.setMaxValue(20);
    barChart.setBarGap(3);
  }
  
  public void changeLook(boolean showLabels, float padding, color c)
  {
    barChart.showValueAxis(showLabels);
    barChart.showCategoryAxis(showLabels);
    barChart.setBarColour(c);
    barChart.setBarPadding(padding);
  }
  
  /* private update function */
  private void update(float[]bins, float[] data) {
    this.bins = new float[bins.length];
    this.values = new float[bins.length];
    
    for (int i = 0; i < this.bins.length; i++) {
      this.bins[i] = bins[i];                                /* set bin limits */
      this.values[i] = 0;                                    /* set values to 0 */
    }
    
    for (int i = 0; i < data.length; i++) {
      float a = ceil(data[i]);                               /* round up data i */
      for (int j = 0; j < this.bins.length; j++) {
        if (a < this.bins[j]) {                              /* if data i less than limit j */
          if (j > 0 && a >= this.bins[j-1]) {                /* check if data i more than limit j - 1 */
            this.values[j] += 1;                             /* if tests passed, add 1 to bin frequency */
          } else if (j == 0 && a >= 0) {                     /* else if iterator is 0 and data i is greater that 0 */
            this.values[0] += 1;                             /* data i must be between 0 and first limit */
          } 
        }
      }
    }
    labels = new String[]{"0-4", "5-9", "10-14", "15-19", "20-24", "25-29",
                             "30-34", "35-49", "40-44", "45-49"};
  }

  /* public updater to be used at runtime */
  public void update(float[] data) {
    update(this.bins, data);
    barChart.setData(values);
  }
  
  /* draws the histogram at given params */
  public void draw(int x, int y, int w, int h) {
    this.barChart.draw(x, y, w, h);
  }
  
  public float[] getBins()  {return bins; }
}
