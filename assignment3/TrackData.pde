class TrackData {
  private float x, y, altitude;
  private Date dateStamp;  
  
  public TrackData() { }
  
  /* to protect unwanted changes, use copy to pass object */
  public TrackData copy() {
    TrackData td = new TrackData();
    td = this;
    return td;
  }
  /* replace this object data from another */
  public void replace(TrackData td) {
    if (td != null) {
      this.x = td.x;
      this.y = td.y;
      this.altitude = td.altitude;
      this.dateStamp = td.dateStamp;
    }
  }
  
}
