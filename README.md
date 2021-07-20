# Welcome to robust PET-Only Processing, aka rPOP!
In this repository you will find everything you need to run rPOP.

## Installation

rPOP has three main dependencies:

-	MATLAB (proprietary commercial software). rPOP has been validated with MATLAB R2018b (OS: macOS High Sierra) and R2020b (OS: macOS Mojave) 
-	Statistical Parametric Mapping v12 (SPM12) toolbox (publicly available) for MATLAB, available at  https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ 
-	Analysis of Functional NeuroImages (AFNI) software suite (publicly available), available at https://afni.nimh.nih.gov/

Prior to running rPOP, make sure you have both SPM12 ready to run on your MATLAB version and AFNI fully installed.

Download the whole rPOP package from the repository, unzip and copy over in your MATLAB search path. 
In MATLAB, add paths to all the subfolders with 

> addpath(genpath('/your/path/to/rPOP-master/'))

To double check availability of rPOP in your search path, just type:

> which rPOP

## Running rPOP

If all the dependencies have been successfully installed, rPOP will run automatically asking only few options to the user.

You can start rPOP by running 

> rPOP

### You will be first asked to select PET images to process. Images must meet the requirements below

- NIfTI files must be 3D. 4D Scans are not supported.
- Scans must be Attenuation Corrected
- Scans must have been performed with either of three FDA-approved amyloid-PET radiotracers, i.e. 18F-Florbetapir, 18F-Florbetaben or 18F-Flutemetamol.






rPOPs runs serially, so the time required to complete the job will depend on how many scans you input.




