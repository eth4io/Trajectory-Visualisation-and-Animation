class Tools {

}
/* histogram class for displaying data
 * ask Michael for questions
 */
class Histogram {
  private float binSize = 0;
  private int[] bins;
  private float maxValue = 0;
  
  public Histogram(float binSize, float[] data) {
    maxValue = max(data);                              /* get max value in data */
    this.binSize = binSize;                            /* set bin size */
    bins = new int[ceil(maxValue / binSize)];          /* set number of bins based on maxValue and binsize*/
    for (int i = 0; i < bins.length; i++)              /* loop and set to zero */
      bins[i] = 0;
    for (int i = 0; i < data.length; i++) {            /* loop over data */
      int ceilData = ceil(data[i] / binSize);          /* find the ceiling for data[i] and the appropriate bin */
      bins[ceilData - 1] += 1;                         /* add one frequency to the bin (accounting for n-1) */
    }
    for (int i = 0; i < bins.length; i++) {            /* loop over bins to print */
      int count = bins[i];                             /* get count for bin i */
      print(i + 1,"");                                 /* print bin number */
      while (count-- > 0) {
        print("*");                                    /* print bin frequency */
      }
      println();
    }
  }
  
  public int[] getBins()  {return bins; }
}


