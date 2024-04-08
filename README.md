# ptm-examples
Simplified model driver data and namelist files to test a General Lake Model particle tracking model, using Falling Creek Reservoir data.

Model scenarios (all with AED off):
1. one-month run in January, homogenous temperature profile as initial condition, no wind, no inflows/outflows
2. one-month run in July, stratified temperature profile as initial condition, no wind, no inflows/outflows
3. artificial wind in January (six days no wind, then 1 day of wind; repeat 4x with varying strengths of windy days)
4. artificial wind in July (six days no wind, then 1 day of wind; repeat 4x with varying strengths of windy days)
5. one inflow/outflow in January (constant inflow/outflow)
6. one inflow/outflow in July (constant inflow/outflow)
7. observed wind + one inflow/outflow in January (observed inflow at weir + outflow to maintain water balance)
8. observed wind + one inflow/outflow in July (observed inflow at weir + outflow to maintain water balance)

Steps to run GLM using ptm-examples (macos):
1. Download VSCode; see instructions here: 
2. Clone latest version of GLM-AED; see instructions here: https://github.com/AquaticEcoDynamics/GLM?tab=readme-ov-file
3. Install homebrew if you haven't; see instructions here: 
4. Make sure you have the following libraries: gcc (fortran compiler); gd (graphics library); netcdf (to handle output); these can be installed with the command 'brew install LIBRARY_NAME'
5. Compile GLM. To do this you will need to navigate to the glm-source folder cd glm-aed/glm-source
6. Then run ./build_glm.sh
7. Then you will need to point to both the folder where you have the .nml and driver files for your example as well as the folder containing the GLM executable you wish to run
8. First, the file with example: cd glm-examples/FCR
9. Then, the file with the executable you've built and run the executable /Users/MaryLofton/glm-aed/glm-source/GLM/glm
10. If you edit the source code, you need to re-compile the model (navigate to glm-source and run ./build_glm.sh) again before running it