# fires_trees_mountains
simulated images of natural phenomena

## Fire
### Overview


The scripts in this section focus on simulating and visualizing a small campfire scene. Wooden sticks (logs) are arranged in a circular pattern and ignited using FDS (Fire Dynamics Simulator). The resulting data slices from the simulation are then transformed into heatmaps and eventually converted to vector polygons for stylistic rendering in Inkscape.

Key Steps
	1.	Generate an FDS input in R to precisely define the log positions.
	2.	Run FDS to simulate the fire and produce slice output files.
	3.	Use Python (via fdsreader) to convert the slice files into 2D heatmaps.
	4.	Convert the heatmaps into vector polygons in R (using terra + sf).
	5.	Refine the visuals in Inkscape.

### Workflow Details
 1.	R Script (Campfire_setup.R)
		Defines coordinates for the logs, sets up the basic geometry, and offers a 3D visualization using the plotly package.

 2. FDS Simulation
    For FDS simulation, FDS (https://github.com/firemodels/fds) is reqiured 
    Using the generated campfire3.fds input file, run the simulation with:
```
    fds campfire3.fds
```
   FDS outputs slice data (*.slcf files) that contain temperature fields over time.

 3.	Python script for Heatmaps
		A Python notebook (extract_slices.ipynp) reads the FDS slice files with fdsreader.
		It converts them into arrays, and then writes out each time step as a simple .txt heatmap.

 4.	Contour Conversion in R
  	Another R script (generate_polygons.R) launches a Shiny app that loads the .txt heatmaps and uses terra and sf to create vector contour       polygons at specified temperature intervals.
	  Colors and boundary thresholds can be adjusted interactively and then exported to SVG.

 5.	Post-Processing in Inkscape
	  The final SVG polygons are imported into Inkscape, where the final campfire is assembled

![My SVG Image](campfire_image.svg)
