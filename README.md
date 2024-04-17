# ptm-examples
Simplified model driver data and namelist files to test a General Lake Model particle tracking model, using Falling Creek Reservoir data.

### Model scenarios (all with AED off):

#### 1. **1_unstratified**: a one-month run in January 2016, with a homogeneous temperature profile as the initial condition, constant air temperature, solar radiation, and humidity, and no precipitation, wind, or inflows/outflows. 

**Purpose:** This scenario is designed to test vertical diffusion under still, unstratified conditions. Neutrally buoyant particles should slowly diffuse throughout the water column, similar to how a drop of dye spreads in a tub of still water.

#### 2. **2_stratified**: a one-month run in July-August 2015, with a stratified temperature profile as the initial condition, constant air temperature, solar radiation, and humidity, and no precipitation, wind, or inflows/outflows.

**Purpose:** This scenario is designed to test vertical diffusion under still, stratified conditions. Neutrally buoyant particles should accumulate in regions of low diffusivity (K~v~), which typically occur at and below the thermocline.

#### 3. **3_unstratified_wind**: a one-month run in January 2016, with a homogeneous temperature profile, constant air temperature, solar radiation, and humidity, and no precipitation or inflows/outflows. This scenario includes artificial wind (six days no wind, then 1 day of wind, where each windy day is of increasing strength).  

**Purpose:** This scenario is designed to test the movement of particles due to wind-driven mixing. In unstratified conditions, wind-driven mixing should cause particles to vertically diffuse more quickly over time in the surface layers, due to increases in turbulent diffusivity. Moreover, wind-driven mixing may lead to merging (and potentially post-wind-event splitting) of layers even in unstratified conditions. In this case, particles in layers that are merged should be redistributed throughout the newly created merged layer, and particles in a splitting layer should be reassigned to one of the two newly created split layers based on their elevation.

#### 4. **4_stratified_wind**: a one-month run in July-August 2015, with a stratified temperature profile, constant air temperature, solar radiation, and humidity, and no precipitation or inflows/outflows. This scenario includes artificial wind (six days no wind, then 1 day of wind, where each windy day is of increasing strength).

**Purpose:** This scenario is designed to test the movement of particles due to wind-driven mixing. In stratified conditions, wind should homogenize the temperature across surface layers, causing layers to merge. In this case, particles within the two layers that are merging should be randomly redistributed across the new merged layer. After a wind event, due to warm summer temperatures, layers should re-stratify and split. In this case, particles should be reassigned to the appropriate new layer ID based on their elevation.

#### 5. **5_unstratified_inflow**: a one-month run in January 2016, with a homogeneous temperature profile, constant air temperature, solar radiation, and humidity, and no precipitation or wind. This scenario includes one inflow/outflow of constant flow (cms) and temperature (the same as the water column). 

**Purpose:** This scenario is designed to test the movement of particles due to inflow discharge under unstratified conditions, which includes (1) introduction of new particles through the inflow; and (2) changes in particle elevation due to corresponding water level elevation changes. Inflow to a lake in GLM may cause a layer to shift in elevation (raise or lower). In this case, the elevation of particles within that layer should be reassigned according to the newly assigned elevation of the layer. Under unstratified winter conditions, when the temperature of the inflow and the lake are the same, the surface inflow will remain at the surface. Thus, particles introduced via the inflow should diffuse vertically from the surface throughout the water column over time. The expectation is that there will be more particles at the end of this simulation than at the beginning due to influx of particles from the inflow.

#### 6. **6_stratified_inflow**: a one-month run in July-August 2015, with a stratified temperature profile, constant air temperature, solar radiation, and humidity, and no precipitation or wind. This scenario includes one inflow/outflow of constant flow (cms) and temperature (about 5ºC cooler than the surface layer). 

**Purpose:** This scenario is designed to test the movement of particles due to inflow discharge under stratified conditions, which includes (1) introduction of new particles through the inflow; and (2) changes in particle elevation due to corresponding water level elevation changes. Inflow to a lake in GLM may cause a layer to shift in elevation (raise or lower). In this case, the elevation of particles within that layer should be reassigned according to the newly assigned elevation of the layer. Under stratified winter conditions, when the temperature of the inflow is cooler than the surface lake temperature, the surface inflow will plunge, leading to raising of layers above it and lowering of layers below it. Thus, particles introduced via the inflow should be assigned an elevation corresponding to the plunge elevation of the inflow. The expectation is that there will be more particles at the end of this simulation than at the beginning due to influx of particles from the inflow.

#### 7. **7_unstratified_observed_wind_inflow**: a one-month run in January 2016, with a homogeneous temperature profile and observed meteorology and inflow data (from the primary inflow only); outflow data are set to match inflow data to maintain the reservoir at full pond. 

**Purpose:** this scenario is designed to test the movement of particles under realistic (variable) meteorology and inflow conditions applied to an unstratified lake.

#### 8. **8_stratified_observed_wind_inflow**: a one-month run in July-August 2015, with a stratified temperature profile and observed meteorology and inflow data (from the primary inflow only); outflow data are set to match inflow data to maintain the reservoir at full pond.

**Purpose:** this scenario is designed to test the movement of particles under realistic (variable) meteorology and inflow conditions applied to a stratified lake.


### Steps to run GLM using ptm-examples (right now for Mac OS only):

1. Download VSCode [here](https://code.visualstudio.com/). 

2. Clone latest version of GLM-AED; see instructions [here](https://github.com/AquaticEcoDynamics/GLM?tab=readme-ov-file). 

3. Install homebrew if you haven't; see instructions [here](https://brew.sh/). 

4. Make sure you have the following libraries: gcc (fortran compiler); gd (graphics library); netcdf (to handle output); these can be installed with the command:
```
brew install LIBRARY_NAME
```

5. Compile GLM. To do this you will need to navigate to the glm-source folder and build GLM:
```
cd glm-aed/glm-source
./build_glm.sh
```

6. Then run GLM. You will need to point to both the folder where you have the .nml and driver files for your example as well as the folder containing the GLM executable you wish to run.

Navigate to directory that houses the model scenario you wish to run (be sure to check the filepath is correct for your directory):
```
cd ptm-examples/1_unstratified
```
Run the GLM executable (be sure to check the filepath is correct for your executable):
```
/Users/YOUR_NAME/glm-aed/glm-source/GLM/glm
```

7. If you edit the source code or download a new version of GLM, you need will to re-compile the model (Step 5) again before running it (Step 6)

### Plot output:
Plots of the initial conditions and driver data for each scenario can be found in the `plots` folder, under the sub-folder for each scenario. An example `IC_driver.png` plot for Scenario 1 (**1_unstratified**) is shown below:

<img src="plots/1_unstratified/IC_drivers.png" align="center" height="500" width="950">
