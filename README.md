# GEOM90007 Group Project in 2018

This project enables visualization of project [GeoLife: Building Social Networks Using Human Location History](https://www.microsoft.com/en-us/research/project/geolife-building-social-networks-using-human-location-history/?from=http%3A%2F%2Fresearch.microsoft.com%2Fen-us%2Fprojects%2Fgeolife%2Fdefault.aspx)


## Getting Started



### Prerequisites
Processing IDE: [Processing 2.2.1](https://processing.org/download/)

*Warning: Processing 3 may not compatible for this project*


### Installing

Install Libraries for Processing

* [Unfolding](http://unfoldingmaps.org/)
* [ControlP5](http://www.sojamo.de/libraries/controlP5/)
* [giCentre Utilities](https://www.gicentre.net/utils/)

### Preparation for GeoLife Dataset
1. Geolife Trajectories 1.3 can be downloaded [here](https://www.microsoft.com/en-us/download/details.aspx?id=52367).
2. Create a new folder `/data` in directory `/assignment3` if it not exists.
3. Paste `Geolife Trajectories 1.3.zip` into `/data`
4. unzip `Geolife Trajectories 1.3`

the structure of the folder will be like:

```
 assignment3/
 |
 --data/
   |
   --Geolife Trajectories 1.3/
     |
     --Data/
       |
       |--000/
       |  |
       |  --Trajectory/
       |      |
       |      --20081023025304.plt
       |      --20090413213935.plt
       |      --20090521231053.plt
       |      --..
       | 
       |--001/
       |  |
       |  --Trajectory/
       |      |
       |      --20081023055305.plt
       |      --20081106233404.plt
       |      --20081203000505.plt
       |      --..
       ..
```

## Usage
Launch `assignment3.pde` and click `run`
