class TrackData {
  private float x, y, altitude;
  private Date timeStamp;  
  
  public TrackData() { }
  
  /* to protect unwanted changes, use copy to pass object */
  public TrackData copy() {
    TrackData td = new TrackData();
    td.x = this.x;
    td.y = this.y;
    td.altitude = this.altitude;
    td.timeStamp = this.timeStamp;
    return td;
  }
  /* replace this object data from another */
  public void replace(TrackData td) {
    if (td != null) {
      this.x = td.x;
      this.y = td.y;
      this.altitude = td.altitude;
      this.timeStamp = td.timeStamp;
    }
  }
  
}
