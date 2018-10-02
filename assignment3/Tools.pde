import org.gicentre.utils.stat.*;                    /* for charts */

class Tools {

}


/* histogram class for displaying data
 * ask Michael for questions
 */
class Histogram {
   
  private float binSize = 0;
  private float[] bins;
  private float maxValue = 0;
  private String[] labels;
  private BarChart barChart;
  
  public Histogram(float binSize, float[] data, PApplet PObj) 
  {
    update(binSize, data);
    
    barChart = new BarChart(PObj);
    barChart.setData(bins);
    barChart.showValueAxis(true);
    barChart.setValueFormat("#.#");
    barChart.setBarLabels(labels);
    barChart.showCategoryAxis(true);
    barChart.transposeAxes(true);
  }
  
  //private update function
  private void update(float binSize, float[] data) 
  {
    maxValue = max(data);                              /* get max value in data */
    this.binSize = binSize;                            /* set bin size */
    bins = new float[ceil(maxValue / this.binSize)];   /* set number of bins based on maxValue and binsize*/
    labels = new String[bins.length];                  /* set labels to length of bins array */
    
    for (int i = 0; i < bins.length; i++)              /* loop and set to zero */
      bins[i] = 0;
    for (int i = 0; i < data.length; i++) {            /* loop over data */
      int ceilData = ceil(data[i] / this.binSize);     /* find the ceiling for data[i] and the appropriate bin */
      if (ceilData <= 0) 
        ceilData = 1;                                  /* if negative value or 0, add to first bin (min bin) */
      bins[ceilData - 1] += 1;                         /* add one frequency to the bin (accounting for n-1) */
    }
    for (int i = 0; i < bins.length; i++) {            /* loop over bins to print */
      println(i + 1, bins[i]);                         /* print bin number and frequency */
      labels[i] = Integer.toString(i) + "0 - " +       /* format value axis labels */
        Integer.toString(i) + "9" ;
    }
  }
  
  //public updater to be used at runtime
  public void update(float[] data) {
    update(this.binSize, data);
    barChart.setData(bins);
  }
  
  public void draw(int x, int y, int w, int h) {
    this.barChart.draw(x, y, w, h);
  }
  
  public float[] getBins()  {return bins; }
}
