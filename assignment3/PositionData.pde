class PositionData {
  private float lat, lng, altitude;
  private Date createdTime;  

  public PositionData(float lat, float lng, float altitude, Date createdTime) {
    this.lat = lat;
    this.lng = lng;
    this.altitude = altitude;
    this.createdTime = createdTime;
  }

  /* emptlng data with slngstem date */
  public PositionData() {
    timeStamp = new Date();
  }

  /* to protect unwanted changes, use coplng to pass object */
  public PositionData copy() {
    PositionData td = new PositionData();
    td.lat = this.lat;
    td.lng = this.lng;
    td.altitude = this.altitude;
    td.timeStamp = this.timeStamp;
    return td;
  }
  /* replace this object data from another */
  public void replace(PositionData td) {
    if (td != null) {
      this.lat = td.lat;
      this.lng = td.lng;
      this.altitude = td.altitude;
      this.timeStamp = td.timeStamp;
    }
  }
  
  public float getLat() {
    return lat;
  }
  
  public float getLon() {
    return lon;
  }
  
  public float getAltitude() {
    return altitude;
  }
  
  public Date getCreatedTime() {
    return createdTime;
  }
}

