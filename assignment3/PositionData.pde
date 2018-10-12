class PositionData {
  private float lat;
  private float lng;
  private float altitude;
  private float speed;
  private Date createdTime;  
  private int time; //variable holds the time as the number of minutes from midnight
  private float floatDate;

  public PositionData(float lat, float lng, float altitude, float speed, Date createdTime, float floatDate) {
    this.lat = lat;
    this.lng = lng;
    this.altitude = altitude;
    this.speed = speed;
    this.createdTime = createdTime;
    this.floatDate = floatDate;
    this.time = calculateTime(floatDate);
  }
  
  public PositionData(float lat, float lng, float altitude, Date createdTime, float floatDate) {
    this(lat, lng, altitude, 0, createdTime, floatDate);
  }

  /* emptlng data with slngstem date */
  public PositionData() {
    createdTime = new Date();
  }

  /* to protect unwanted changes, use coplng to pass object */
  public PositionData copy() {
    PositionData td = new PositionData();
    td.lat = this.lat;
    td.lng = this.lng;
    td.altitude = this.altitude;
    td.createdTime = this.createdTime;
    td.floatDate = this.floatDate;
    td.time = this.time;
    return td;
  }
  /* replace this object data from another */
  public void replace(PositionData td) {
    if (td != null) {
      this.lat = td.lat;
      this.lng = td.lng;
      this.altitude = td.altitude;
      this.createdTime = td.createdTime;
      this.floatDate = this.floatDate;
      this.time = td.time;
    }
  }
  
  public float getLat() {
    return lat;
  }
  
  public float getLng() {
    return lng;
  }
  
  public float getAltitude() {
    return altitude;
  }
  
  public float getSpeed() {
    return speed;
  }
  
  public void setSpeed(float speed) {
    this.speed = speed;
  }
  
  public Date getCreatedTime() {
    return createdTime;
  }
  
  public int getTime(){
    return time;
  }
  
  public String toString() {
    return "lat: " + lat + ",\tlng: " + lng + ",\taltitude: "
      + altitude + ",\tspeed: " + speed + ",\ttime: " + createdTime;
  }
  
  public int calculateTime(float floatDate){
    int intDate = (int) floatDate;
    float timeFraction = floatDate - intDate;
    return (int)(timeFraction*1440);
  }
}

