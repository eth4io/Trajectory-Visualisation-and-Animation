class Tools {

}
/* histogram class for displaying data
 * ask Michael for questions
 */
class Histogram {
  /*
   * test histogram on altitude example:
   *
   * float[] hist = new float[testerData.size()];
   * for (int i = 0; i < testerData.size(); i++)
   * hist[i] = testerData.get(i).getAltitude();
   * Histogram histoTest = new Histogram(500,hist);
   */
   
  private float binSize = 0;
  private int[] bins;
  private float maxValue = 0;
  
  public Histogram(float binSize, float[] data) {
    maxValue = max(data);                              /* get max value in data */
    this.binSize = binSize;                            /* set bin size */
    bins = new int[ceil(maxValue / this.binSize)];     /* set number of bins based on maxValue and binsize*/
    
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
    }
  }
  
  public int[] getBins()  {return bins; }
}


