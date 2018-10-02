import org.gicentre.utils.stat.*;                    /* for charts */

class Tools {

}


/* histogram class for displaying data
 * ask Michael for questions
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
    
    for (int i = 0; i < values.length; i++) {                /* loop over bins to generate labels */
      //println(i + 1, values[i]);                           /* print bin number and frequency */
      labels[i] = Integer.toString(i) + "0 - " +             /* format value axis labels */
        Integer.toString(i) + "9" ;
    }
    
    
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
