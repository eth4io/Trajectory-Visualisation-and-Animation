/* Tools file 
 * 
 * List of Tools:
 * - radius filter 
 * - histogram
 *
 * Statics:
 * - explore trajectory
 * 
 */

import org.gicentre.utils.stat.*;                          /* for charts */
import de.fhpotsdam.unfolding.utils.GeoUtils.*; 


static class Tools {
  
/* reads entire positionData file for a trajectory
 * and adds to Marker Manager as point data
 * 
 * precondition marker manager must be initilised 
 * and assigned to an UnfoldingMap
 *
 * returns true if successful, otherwise false
 * 
 * ask Michael for Q&A
 */
  public static boolean exploreTrajectory(Trajectory t, MarkerManager mm) 
  {
    if (mm.getMarkers() != null) {                                                  /* clear marker manager if not empty */
      mm.clearMarkers();
    }
    for (int i = 0; i < t.getPositionData().size(); i++) {                            /* add markers from position data file */
      mm.addMarker(new SimplePointMarker(
                     new Location(
                       t.getPositionData().get(i).getLat(), 
                       t.getPositionData().get(i).getLng()
                   )));
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
  
  public RadiusFilter() 
  {                                       
    super(new Location(0,0));
    this.setColor(color(255,0,0,50));
    this.setStrokeWeight(0);
  }
  
  /* cycle updates for the filter */
  public void update(UnfoldingMap map) 
  {
    this.setLocation(map.getLocation(mouseX, mouseY));
  }
  
  /* returns list of markers that are within this filter */
  public List<Trajectory> getWithinRadius(UnfoldingMap map, List<Trajectory> markers) 
  {
    List<Trajectory> found = new ArrayList<Trajectory>();
    double dist = GeoUtils.getDistance(this.getLocation(), 
      GeoUtils.getDestinationLocation(this.getLocation(), 0, rad_km));
    
    for (Trajectory m : markers) {
      double diff = GeoUtils.getDistance(m.getLocation(),
        this.getLocation());
      if (diff < dist/2) {
        m.setSelected(true);
        found.add(m);
      } else {
        if (m.isSelected()) {
          m.setSelected(false);
        }
      }
    }
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
    barChart.setBarGap(3);
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
