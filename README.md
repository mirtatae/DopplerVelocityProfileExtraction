# Doppler Velocity Profile Extraction from Echo Images

## How to use the codes:
Clone this repository. Set the Matlab directory to this clone. Run the follwoing in the Matlab command line:

    [lo_env,up_env,lo_env2,up_env2]=ExtractDopplerFromECHO(A)
  
where A is your echo image. For the parameter definitions, see the Matlab code. Note that in the current version of the code, some parameters such as the baseline should be set manually. Change these numbers according to your image size and resolution. Please report any bugs in the Issues section.
Sample results are in the "Sample Results" folder.

## Sample image:
Use image A.jpg as a sample image to reproduce the results presented in [1].

## References
Cite the following papers if you use this code:

[1] Taebi, A.; Sandler, R.H.; Kakavand, B.; Mansy, H.A. Extraction of Peak Velocity Profiles from Doppler Echocardiography Using Image Processing. Bioengineering 2019, 6, 64, doi: 10.3390/bioengineering6030064. 

[2] Taebi, A., Sandler, R.H., Kakavand, B., & Mansy, H.A. (2018, December). Estimating Peak Velocity Profiles from Doppler Echocardiography using Digital Image Processing. In 2018 IEEE Signal Processing in Medicine and Biology Symposium (SPMB) (pp. 1-4). IEEE, doi: 10.1109/SPMB.2018.8615618.
