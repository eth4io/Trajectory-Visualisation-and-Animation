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
  private static final int SPEED_SMOOTHING_SIZE = 10;
  private static final int DATE_STRING_LENGTH = 8; // sample file name: "20090705025307.plt"
  static final String STUDY_DATE_FORMAT = "yyyy-MM-dd/HH:mm:ss";
  private String fileSeparator;
  private String dataDir;
  
  private Queue<Float> speedQueue;
  private PositionData currentPosition = null;
  private PositionData lastPosition = null;
  private float speedSum;

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

  public List<List<Trajectory>> getListOfTrajectoryListByListOfDate(List<String> dates) {
    List<List<Trajectory>> listOfTrajectoryList = new ArrayList<List<Trajectory>>();
    for (String date : dates) {
      listOfTrajectoryList.add(getTrajectoryListByDate(date));
    }
    return listOfTrajectoryList;
  }

  public List<Trajectory> getTrajectoryListByDate(String date) {
    List<Trajectory> trajectoryList = new ArrayList<Trajectory>();

    File directory = new File(dataDir);
    File[] files = directory.listFiles();
    for (final File fileEntry : files) {
      if (fileEntry.isDirectory()) {
        Trajectory trajectory = getTesterTrajectoryByDate(fileEntry.getName(), date);
        if (trajectory != null)
          trajectoryList.add(trajectory);
      }
    }

    return trajectoryList;
  }

  public Trajectory getTesterTrajectoryByDate(String folderName, String Date) {
    String folderPath = dataDir + fileSeparator + folderName +
      fileSeparator + GEOLIFE_DATA_TRAJECTORY_DIR + fileSeparator;
    File directory = new File(folderPath);
    File[] files = directory.listFiles();
    
    for (final File fileEntry : files) {
      if (fileEntry.isFile() && fileEntry.getName().substring(0, DATE_STRING_LENGTH).equals(Date)) {
        List<PositionData> result = new ArrayList<PositionData>();
        result.addAll(getPositionDataListByFilePath(fileEntry.toString()));
        return new Trajectory(result);
      }
    }
    return null;    
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
  private List<PositionData> getPositionDataListByFilePath(String filePath) {
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
    speedSum = 0.0;
    speedQueue = new LinkedList();
    for (int i = 6; i < trackfile.length; i++) {
      tracklog = split(trackfile[i], ",");

      float lat = Float.valueOf(tracklog[0]);
      float lon = Float.valueOf(tracklog[1]);
      float altitude = Float.valueOf(tracklog[3]);
      SimpleDateFormat dataFormat = new SimpleDateFormat(STUDY_DATE_FORMAT);
      try {
        Date date = dataFormat.parse(tracklog[5] + "/" + tracklog[6]);
        
        PositionData positionData = new PositionData(lat, lon, altitude, date);
        currentPosition = positionData;
        float speed = getSmoothedSpeed(speedQueue, lastPosition, currentPosition);
        positionData.setSpeed(speed);
        lastPosition = currentPosition;
        
//        println(positionData.toString());
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
  
  private float getSmoothedSpeed(Queue<Float> speedQueue,
    PositionData lastPosition, PositionData currentPosition) {
    // update current speed
    float currentSpeed = getSimpleSpeed(lastPosition, currentPosition);

    if (speedQueue.size() >= SPEED_SMOOTHING_SIZE) {
      speedSum -= speedQueue.remove();
    }
    speedQueue.add(currentSpeed);
    speedSum += currentSpeed;
    float smoothedSpeed = speedSum / speedQueue.size();

    // log for debugging
    println("curSpeed: ", currentSpeed, '\t', "size: ", speedQueue.size());
    return smoothedSpeed;
  }
    
  private float getSimpleSpeed(PositionData lastPosition, PositionData currentPosition) {
    if (lastPosition == null || currentPosition == null) {
      return 0;
    }
    //get time difference in milliseconds from current time - last time
    float timeDiffInHour = getTimeDiffInHour(lastPosition, currentPosition);
    float distanceDiffInKm = getDistance(lastPosition, currentPosition);

    if (Float.isNaN(distanceDiffInKm) || timeDiffInHour == 0)
      return 0;
    //calculate distance / speed to get km per hour
    return distanceDiffInKm / timeDiffInHour;
  }
 
  /**
   * Calculate distance between two points in latitude and longitude taking
   * into account height difference. If you are not interested in height
   * difference pass 0.0. Uses Haversine method as its base.
   * 
   * lat1, lon1 Start point lat2, lon2 End point el1 Start altitude in meters
   * el2 End altitude in meters
   * @returns Distance in Meters
   */
  private float getDistance(PositionData lastPosition, PositionData currentPosition) {
    float lat1 = lastPosition.getLat();
    float lat2 = currentPosition.getLat();
    float lon1 = lastPosition.getLng();
    float lon2 = lastPosition.getLng();
    final int R = 6371; // Radius of the earth

    double latDistance = Math.toRadians(lat2 - lat1);
    double lonDistance = Math.toRadians(lon2 - lon1);
    double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
            * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    double distance = R * c ; // in kilomete
    return (float) Math.abs(distance);
  }

  private float getTimeDiffInHour(PositionData lastPosition, PositionData currentPosition) {
    float diff = abs(currentPosition.getCreatedTime().getTime()
      - lastPosition.getCreatedTime().getTime());
    //remove miliseconds and seconds
    diff /= 1000 * 3600;
    return diff;
  }
}

