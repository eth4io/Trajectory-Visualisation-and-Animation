import java.io.File;

public class DataReader {
  private static final String SYSTEM_PROPERTY_FILE_SEPARATOR = "file.separator";
  private static final String GEOLIFE_DIR = "Geolife Trajectories 1.3";
  private static final String GEOLIFE_DATA_DIR = "Data";
  private static final String GEOLIFE_DATA_TRAJECTORY_DIR = "Trajectory";
  private String fileSeparator;
  private String dataDir;

  public DataReader() {
    initVariables();
    loadPltByFolder(0);
  }

  private void initVariables() {
    /* get OS correspoding file separator
     * MacOS: '/'    Windows: '\' 
     * reference: [The Java™ Tutorials - System Properties](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)
     */
    fileSeparator = System.getProperty(SYSTEM_PROPERTY_FILE_SEPARATOR);
    
    /* get absolute path for the real data directory */
    dataDir = dataPath(GEOLIFE_DIR + fileSeparator + GEOLIFE_DATA_DIR);
  }

  public void listFilesForFolder(String dirName) {
    File directory = new File(dirName);

    for (final File fileEntry : directory.listFiles ()) {
      if (fileEntry.isDirectory()) {
        listFilesForFolder(fileEntry.getAbsolutePath());
      } else {
        System.out.println(fileEntry.getName());
      }
    }
  }
  
  /**
   * Returns a String[][][] object contains all .plt files belongs to the tester
   *
   * @param folderIndex An int contains the index of the tester
   *                    range from 0 ("000") to 181 ("181")
   */
  public String[][][] loadPltByFolder(int folderIndex) { 
    String folderName = folderIndex + "";

    /* fulfill the name for folder
     * example: 
     *   0 -> "000"
     *   13 -> "013"
     */
    if (folderName.length() == 1) {
      folderName = "00" + folderName;
    }
    else if (folderName.length() == 2) {
      folderName = "0" + folderName;
    }

    String folderDir = dataDir + fileSeparator + folderName +
      fileSeparator + GEOLIFE_DATA_TRAJECTORY_DIR;
    return new String[1][1][1];
  }

  /**
   * Returns a String[][] object contains selected .plt files belongs to the tester
   *
   * @param folderIndex An int contains the index of the tester
   *                    range from 0 ("000") to 181 ("181")
   * @param fileName A String contains the name of the file need to be loaded
   */
  public String[][] loadPlt(String folderIndex, String filename) {    
    //loads a plt file, and returns a 2D String Array of tracklog
    //where tracklog[i] is a single trace line
    //tracklog[i][0] is the latitude and tracklog[i][1] is the longitude
    //[2] is empty (always 0), [3] is altitude in feet (always an int)
    //[4] is the date as a number (no. of days since 12/30/1899, w/ a fraction for time
    //[5] is the date as a string "YEAR/MONTH/DAY"
    //[6] is the time as a string "HR:MN:SE"

    //tracklog starts from line 6 in trackfile
    String[] trackfile = loadStrings(filename);
    String[][] tracklog = new String[trackfile.length-6][7];
    for (int i =6; i<trackfile.length; i++) {
      tracklog[i-6] = split(trackfile[i], ",");
    }
    return tracklog;
  }
}

