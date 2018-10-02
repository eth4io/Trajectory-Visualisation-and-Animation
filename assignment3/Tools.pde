import org.gicentre.utils.stat.*;                    /* for charts */

class Tools {

}


/* histogram class for displaying data
 * ask Michael for questions
 */
class Histogram {
   
  private float[] bins;
  private float[] binValues;
  private float maxValue = 0;
  private String[] labels;
  private BarChart barChart;
  
  public Histogram(float[] bins, float[] data, PApplet PObj) 
  {
    update(bins, data);
    
    barChart = new BarChart(PObj);
    barChart.setData(binValues);
    barChart.showValueAxis(true);
    barChart.setValueFormat("#.#");
    barChart.setBarLabels(labels);
    barChart.showCategoryAxis(true);
    barChart.transposeAxes(true);
  }
  
  //private update function
  private void update(float[] bins, float[] data) 
  {
    maxValue = max(data);                              /* get max value in data */
    //this.binSize = binSize;                            /* set bin size */
    this.bins = bins;                                   /* set number of bins based on maxValue and binsize*/
    labels = new String[bins.length];                  /* set labels to length of bins array */
    binValues = new float[bins.length];
    
    for (int i = 0; i < binValues.length; i++)              /* loop and set to zero */
      binValues[i] = 0;
    for (int i = 0; i < data.length; i++) {            /* loop over data */
      float ceilData = ceil(data[i]);                    /* find the ceiling for data[i] and the appropriate bin */
      for (int j = 0; j < binValues.length; j++) {
        if (ceilData < bins[0]) {
          binValues[0] += 1;
        }
        if (i > 0 && ceilData < bins[i] && ceilData > bins[i-1]) {
          binValues[i] += 1;
        }
      }
    }
    for (int i = 0; i < binValues.length; i++) {            /* loop over bins to print */
      println(i + 1, binValues[i]);                         /* print bin number and frequency */
      labels[i] = Integer.toString(i) + "0 - " +       /* format value axis labels */
        Integer.toString(i) + "9" ;
    }
  }
  
  //public updater to be used at runtime
  public void update(float[] data) {
    update(this.bins, data);
    barChart.setData(bins);
  }
  
  public void draw(int x, int y, int w, int h) {
    this.barChart.draw(x, y, w, h);
  }
  
  public float[] getBins()  {return bins; }
}
