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

### You will be then asked for a master output directory. All logs will be saved here.

### You will be then required to choose an option regarding the setting of the image origin, with two choices:

- Do not reset origin
- Set origin to center of image

Your choice will be applied to all the images you inputed in the previous step.

### You will be then required to choose a Warping Templates option four choices:

- Tracer-independent, use all Templates (Validated Approach)
- Tracer-specific, use 18F-Florbetaben Templates
- Tracer-specific, use 18F-Florbetapir Templates
- Tracer-specific, use 18F-Flutemetamol Templates

rPOP performance and Centiloids conversion formulas as described in Iaccarino et al., have been validated using the first option (Tracer-independent).
The user will be able to choose also tracer-specific templates options. The warping and differential smoothing are expected to be very similar, but the user will have to perform their own cross-validation to obtain Centiloid conversion formulas. 

### rPOPs runs serially, so the time required to complete the job will depend on how many scans you input.

## rPOP Output

### rPOP will provide, for any given inputed image (e.g. 'myscan.nii'):
- myscan_sn.mat - Storage of the spatial transformation parameters estimated by SPM12
- wmyscan.nii - Non-linearly warped version of the image
- wmyscan_automask.txt - Results of the Full-Width at Half Maximum (FWHM) estimation by AFNI 3dFWHMx on the warped image
- swmyscan.nii - Smoothed, non-linearly warped version of the image. Scan is brought to final 10mm3 as default. 

### Other outputs:
- A database, with naming convention rPOP_mm-dd-yyyy_HH-MM-SS.csv, storing for each inputed image the calculated FWHM and the estimated filter to be applied to reach 10mm3
- Optional - a Warning database will be produced in case at least one image had an estimated FWHM resolution >25. In that case 3dFWHMx is re-run without the -2difMAD flag, which in some instances helped. In that case, a flag is also added to the main database described above. This instance is very rare and only happened during first rPOP iterations, never happened in the validation datasets.


