class PositionData {
  private float lat;
  private float lng;
  private float altitude;
  private float speed;
  private Date createdTime;  

  public PositionData(float lat, float lng, float altitude, float speed, Date createdTime) {
    this.lat = lat;
    this.lng = lng;
    this.altitude = altitude;
    this.speed = speed;
    this.createdTime = createdTime;
  }
  
  public PositionData(float lat, float lng, float altitude, Date createdTime) {
    this(lat, lng, altitude, 0, createdTime);
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
    return td;
  }
  /* replace this object data from another */
  public void replace(PositionData td) {
    if (td != null) {
      this.lat = td.lat;
      this.lng = td.lng;
      this.altitude = td.altitude;
      this.createdTime = td.createdTime;
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
  
  public float getTime() {
    Calendar cal = Calendar.getInstance();
    cal.setTime(getCreatedTime());
    float hour = cal.get(Calendar.HOUR_OF_DAY);
    float min = cal.get(Calendar.MINUTE);
    return (hour*60)+min;
  }
  
  public void setSpeed(float speed) {
    this.speed = speed;
  }
  
  public Date getCreatedTime() {
    return createdTime;
  }
  
  public String toString() {
    return "lat: " + lat + ",\tlng: " + lng + ",\taltitude: "
      + altitude + ",\tspeed: " + speed + ",\ttime: " + createdTime;
  }
}

