# GammaGammaHistograms
Creates gamma-gamma histograms from unpacked analysis trees. Time random background
subtraction occurs while the histograms are being filled and a second event
mixed (depth 10) matrix is created for normalization procedures.

## Table of Contents
  * [Installation](#installation)
  * [Running GammaGammaHistograms](#running-gammagammahistograms)
  * [Helper scripts](#helper-scripts)
    + [MakeGammaGammaHistograms.sh](#makegammagammahistogramssh)

# Installation
0. Requires GRSISort 4.X.X
1. Get the code, either via tarball or from github
```
git clone https://github.com/cnatzke/MakeGammaGammaHistograms.git
```
2. Build program using standard cmake process, e.g.
```
mkdir myBuild && cd myBuild
cmake ..
make
```
3. Do science.

# Running MakeGammaGammaHistograms
The general form of input is:
```
./GammaGammaHistograms analysis_tree [analysis_tree_2 ... ] calibration_file
```

##### Parameters
```
analysis_tree           ROOT file(s) containing analysis tree to process (must end with .root)
calibration_file        GRIFFIN calibration file (must end with .cal)
```

##### Outputs
```
gg_XXXXX.root   ROOT file containing gammma gamma histograms
```


# Helper scripts
Included is a helper script that makes building histograms easier.

### MakeGammaGammaHistograms.sh
This script takes a run and optionally a batch size.
```
./MakeGammaGammaHistograms.sh run_number [batch_size]
```
where
```
run_number  Run number of interest
batch_size  Number of subruns to be chained together (optional)
```
The script chains subruns together to process, but depending on the size of the run  this exceeds the available system memory. The batch size controls how many subruns will be chained together in each step. For example if you have 17 subruns (0-16) and a batch size of 3, the script will pass a total of 6 batches to the histogram programs like so
```
batch   subruns
---------------
1       000-002
2       003-005
3       006-008
4       009-011
5       012-014
6       015-016
```

If you do not pass a batch size the script will collects all subruns and pass them to the histogram sorting function.
