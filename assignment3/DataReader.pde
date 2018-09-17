import java.io.File;
import java.util.*; 

public class DataReader {
  private static final String SYSTEM_PROPERTY_FILE_SEPARATOR = "file.separator";
  private static final String GEOLIFE_DIR = "Geolife Trajectories 1.3";
  private static final String GEOLIFE_DATA_DIR = "Data";
  private static final String GEOLIFE_DATA_TRAJECTORY_DIR = "Trajectory";
  private String fileSeparator;
  private String dataDir;

  public DataReader() {
    /**
     * structure of GeoLife Data folder
     *
     * assignment3/
     * |
     * --data/
     *   |
     *   --Geolife Trajectories 1.3/
     *     |
     *     --Data/
     *       |
     *       |--000/
     *       |  |
     *       |  --Trajectory/
     *       |      |
     *       |      --20081023025304.plt
     *       |      --20090413213935.plt
     *       |      --20090521231053.plt
     *       |      --..
     *       | 
     *       |--001/
     *       |  |
     *       |  --Trajectory/
     *       |      |
     *       |      --20081023055305.plt
     *       |      --20081106233404.plt
     *       |      --20081203000505.plt
     *       |      --..
     *       ..
     */

    /* get OS correspoding file separator
     * MacOS: '/'    Windows: '\' 
     * reference: [The Java™ Tutorials - System Properties](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)
     */
    fileSeparator = System.getProperty(SYSTEM_PROPERTY_FILE_SEPARATOR);

    /* get absolute path for the real data directory */
    dataDir = dataPath(GEOLIFE_DIR + fileSeparator + GEOLIFE_DATA_DIR);
  }


  /**
   * Returns a List of String[][] contains all .plt files belongs to the tester
   *
   * @param folderIndex An int contains the index of the tester
   *                    range from 0 ("000") to 181 ("181")
   */
  public List<String[][]> getTesterDataByIndex(int folderIndex) { 
    String folderName = getFullFolderNameByIndex(folderIndex);

    String folderPath = dataDir + fileSeparator + folderName +
      fileSeparator + GEOLIFE_DATA_TRAJECTORY_DIR + fileSeparator;

    File directory = new File(folderPath);

    List<String[][]> result = new ArrayList<String[][]>(); 
    for (final File fileEntry : directory.listFiles ()) {
      if (fileEntry.isFile()) {
        result.add(getPltByFilePath(folderPath + fileEntry.getName()));
      }
    }
    return result;
  }

  /**
   * Returns a String[][] object contains selected .plt files belongs to the tester
   *
   * @param fileName A String contains the name of the file need to be loaded
   */
  public String[][] getPltByFilePath(String filePath) {   
    //loads a plt file, and returns a 2D String Array of tracklog
    //where tracklog[i] is a single trace line
    //tracklog[i][0] is the latitude and tracklog[i][1] is the longitude
    //[2] is empty (always 0), [3] is altitude in feet (always an int)
    //[4] is the date as a number (no. of days since 12/30/1899, w/ a fraction for time
    //[5] is the date as a string "YEAR/MONTH/DAY"
    //[6] is the time as a string "HR:MN:SE"

    //tracklog starts from line 6 in trackfile
    String[] trackfile = loadStrings(filePath);
    String[][] tracklog = new String[trackfile.length-6][7];
    for (int i = 6; i < trackfile.length; i++) {
      tracklog[i - 6] = split(trackfile[i], ",");
    }
    return tracklog;
  }

  private String getFullFolderNameByIndex(int folderIndex) {
    /* fulfill the name for folder
     * example: 
     *   0 -> "000"
     *   13 -> "013"
     *   100 -> "100"
     */

    String folderName = folderIndex + "";

    if (folderName.length() == 1) {
      folderName = "00" + folderName;
    } else if (folderName.length() == 2) {
      folderName = "0" + folderName;
    }
    return folderName;
  }
}

