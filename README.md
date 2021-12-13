# Welcome to robust PET-Only Processing, aka rPOP!
In this repository you will find everything you need to run rPOP.

## Licensing

### rPOP is only distributed for academic/research purposes, with NO WARRANTY. 
### rPOP is not intended for any clinical or diagnostic purposes. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## Validation

rPOP validation is available at https://www.sciencedirect.com/science/article/pii/S1053811921010478 (Iaccarino et al., 2022 NeuroImage)

## Contact

Any comment or Inquiry is welcome. Please contact me at: Leonardo.Iaccarino@ucsf.edu

## Installation

rPOP has three main dependencies:

-	MATLAB (proprietary commercial software). rPOP has been validated with MATLAB R2018b (OS: macOS High Sierra) and R2020b (OS: macOS Mojave) 
-	Statistical Parametric Mapping v12 (SPM12) toolbox (publicly available) for MATLAB, available at  https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ 
-	Analysis of Functional NeuroImages (AFNI) software suite (publicly available), available at https://afni.nimh.nih.gov/. rPOP has been validated with AFNI_20.3.03 (Dec  7 2020)

Prior to running rPOP, make sure you have both SPM12 ready to run on your MATLAB version and AFNI fully installed.

Download the whole rPOP package from the repository, unzip and copy over in your MATLAB search path. 
In MATLAB, add paths to all the subfolders with 

> addpath(genpath('/your/path/to/rPOP-master/'))

To double check availability of rPOP in your MATLAB search path, just type:

> which rPOP

in your MATLAB console. 

## Running rPOP

If all the dependencies have been successfully installed, rPOP will run automatically asking only few options to the user.

You can start rPOP by first opening MATLAB and then typing in the console: 

> rPOP

A disclaimer will pop-up with some info about rPOP. Press any key to acknowledge and continue. 

### You will be first asked to select PET images to process. Images must meet the requirements below

- NIfTI files must be 3D. 4D files are not supported.
- Scans must be Attenuation Corrected
- Scans must have been performed with either of three FDA-approved amyloid-PET radiotracers, i.e. 18F-Florbetapir, 18F-Florbetaben or 18F-Flutemetamol.

### You will be then asked for a master output directory. All logs will be saved here.

### You will be then asked to locate the 3dFWHMx executable 

On a macOS system, after installation you can find the location of 3dFWHMx by typing

> which 3dFWHMx

in your MAC OS terminal. It should look something like 

> /Users/myusername/abin/3dFWHMx

### You will be then required to choose an option regarding the setting of the image origin, with two choices:

- Do not reset origin
- Set origin to center of image

Your choice will be applied to all the images you inputed in the previous step.

The code performing the reset of the origin is from <b>F. Yamashita</b> and is part of an ac/pc co-registration script (parent function available at: http://www.nemotos.net/scripts/acpc_coreg.m)

### You will be then required to choose a Warping Templates option, with four choices:

- Tracer-independent, use all Templates (Validated Approach)
- Tracer-specific, use 18F-florbetaben Templates
- Tracer-specific, use 18F-florbetapir Templates
- Tracer-specific, use 18F-flutemetamol Templates

rPOP performance and Centiloids conversion formulas as described in Iaccarino et al. 2022, have been validated using the first option (Tracer-independent).
The user will be able to choose also tracer-specific options. The warping and differential smoothing are expected to be very similar, but the user will have to perform their own cross-validation to obtain Centiloid conversion formulas. 

Details on template generation are available in Iaccarino et al. 2022, and templates can be found in this repository and can as well be inspected at Neurovault: https://neurovault.org/collections/CPHVNXDQ/

### Differential smoothing in rPOP

Details on rPOP differential smoothing approach can be found in Iaccarino et al. 2022. rPOP employs an AFNI function, 3dFWHMx, to estimate FWHM of the warped 3D PET scan provided as input. The estimation is performed with the following flags:

- automask: Generating brain mask automatically to select voxels used for the FWHM estimation
- 2difMAD: Used to estimate FWHM in the 3D file and take into account intrinsic structure (see details in the function documentation)

Using the -2difMAD option highly increased the accuracy of the 3dFWHMx FWHM estimation when compared to known effective resolution (validated with both a local and and an ADNI dataset). When running, it is likely 3dFWHMx will also display an error like:

> ERROR: largest ACF found is 0.518093 -- too big for model fit!

The function will nevertheless output the txt file with the appropriate FWHM estimation. This seems to be a bug related to the -2difMAD option (see a discussion here: https://github.com/poldracklab/mriqc/issues/677). If anyone has additional inputs or comments regarding this please let me know. 

### rPOPs runs serially, so the time required to complete the job will depend on how many scans you input.

## rPOP Output

### rPOP will provide, for any given input image (e.g. 'myscan.nii'):
- myscan_sn.mat - Storage of the spatial transformation parameters estimated by SPM12
- wmyscan.nii - Non-linearly warped version of the image
- wmyscan_automask.txt - Results of the Full-Width at Half Maximum (FWHM) estimation by AFNI 3dFWHMx on the warped image
- swmyscan.nii - Smoothed, non-linearly warped version of the image. Scan is brought to final ~10mm3 as default (see text for details). 

### Other outputs:
- A database, with naming convention rPOP_mm-dd-yyyy_HH-MM-SS.csv, storing for each inputed image the calculated FWHM and the estimated filter applied to reach ~10mm3
- Optional - a Warning database with naming convention rPOPWarnings_mm-dd-yyyy_HH-MM-SS.csv will be produced in case at least one image had an estimated FWHM resolution >25 on any of the planes. In that case 3dFWHMx is re-run without the -2difMAD flag, which in some instances helped. In that case, a flag is also added to the main database described above. This instance is very rare and only happened during first rPOP iterations, never happened in the validation datasets reported in the manuscript.

## QC 

### The user is required to run essentially two main quality control checks with their software/method of choice:
- Qualitative evaluation of the warping. Size, shape(s), orientation of the w and sw images must match MNI standard space. 
- Qualitative evaluation of goodness of fit of the ROIs which will be used for quantification (Extremely important!). 

## Quantification

rPOP users will have the ability to run any quantification approach they prefer on either the w or the sw images as required. 

In the paper, we validated a quantification approach using smoothed and warped images and requiring:

- Extraction of average binding values from the GAAIN 2mm volumes of interest, i.e. ctx with whole cerebellum as reference. The files are readily available at http://www.gaain.org/centiloid-project (direct download link -> https://www.gaaindata.org/data/centiloid/Centiloid_Std_VOI.zip)
- Calculation of Standardized Uptake Value Ratio (SUVR) with the ctx/wc ratio
- Conversion to Centiloids using tracer-specific formulas as described in the paper. 

## Warning to rPOP users!

- Any change in the rPOP methods described above, e.g. changing the target resolution, using different templates, using different ROIs for quantification, automatically invalidate the Centiloid conversion formulas described in the paper. For any of these changes, users will be required to run their own Centiloid pipeline cross-validation as described in Klunk et al., 2015 Alzheimer's & Dementia

## Replication dataset

A database "ADNIReplicationData.csv" can be found in the rPOP repository and can be used to replicate numbers and estimations generated in the study. The dataset includes N=200 random image data from our N=1518 ADNI dataset (100 per tracer), with included a dictionary file. Users can download the corresponding images from ADNI (publicly available) and test their rPOP setup before proceeding with the analyses. Average binding values and estimated FWHMs should be nearly identical to those available in the database.
