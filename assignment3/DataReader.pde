/* created by Yichi Zhang (895529)
 * at 17/9/18
 */

import java.io.File;
import java.util.*; 

public class DataReader {
  private static final String SYSTEM_PROPERTY_FILE_SEPARATOR = "file.separator";
  private static final String GEOLIFE_DIR = "Geolife Trajectories 1.3";
  private static final String GEOLIFE_DATA_DIR = "Data";
  private static final String GEOLIFE_DATA_TRAJECTORY_DIR = "Trajectory";
  private static final String ERROR_PARSING_DATE = "Error while parsing Date from plt.";
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
   * Returns a List of PositionData contains all .plt files belongs to the tester
   *
   * @param folderIndex An int contains the index of the tester
   *                    range from 0 ("000") to 181 ("181")
   */
  public List<PositionData> getTesterDataByIndex(int folderIndex) {
    String folderName = getFullFolderNameByIndex(folderIndex);

    String folderPath = dataDir + fileSeparator + folderName +
      fileSeparator + GEOLIFE_DATA_TRAJECTORY_DIR + fileSeparator;

    File directory = new File(folderPath);

    File[] files = directory.listFiles();
    Arrays.sort(files);
    List<PositionData> result = new ArrayList<PositionData>();
    for (final File fileEntry : files) {
      if (fileEntry.isFile()) {
        println(fileEntry.getName());
        result.addAll(getPositionDataListByFilePath(fileEntry.toString()));
      }
    }
    return result;
  }

  /**
   * Returns a List of PositionData object contains data
   * from all .plt files belongs to the selected tester
   *
   * @param fileName A String contains the name of the file need to be loaded
   */
  public List<PositionData> getPositionDataListByFilePath(String filePath) {
    //loads a plt file, and returns a 2D String Array of tracklog
    //where tracklog[i] is a single trace line
    //tracklog[i][0] is the latitude and tracklog[i][1] is the longitude
    //[2] is empty (always 0), [3] is altitude in feet (always an int)
    //[4] is the date as a number (no. of days since 12/30/1899, w/ a fraction for time
    //[5] is the date as a string "yyyy-MM-dd"
    //[6] is the time as a string "HH:mm:ss"

    //tracklog starts from line 6 in trackfile
    List<PositionData> pointTrack = new ArrayList<PositionData>();
    String[] trackfile = loadStrings(filePath);
    String[] tracklog = new String[7];
    for (int i = 6; i < trackfile.length; i++) {
      tracklog = split(trackfile[i], ",");

      float lat = Float.valueOf(tracklog[0]);
      float lon = Float.valueOf(tracklog[1]);
      float altitude = Float.valueOf(tracklog[3]);
      SimpleDateFormat dataFormat = new SimpleDateFormat("yyyy-MM-dd/HH:mm:ss");
      try {
        Date date = dataFormat.parse(tracklog[5] + "/" + tracklog[6]);
        PositionData positionData = new PositionData(lat, lon, altitude, date);
        pointTrack.add(positionData);
      }
      catch (Exception e) {
        println(ERROR_PARSING_DATE);
      }
    }
    return pointTrack;
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

