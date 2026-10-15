# EHT Contraction Analysis

A two-step Fiji/ImageJ and Python workflow for quantifying contractile motion in human induced pluripotent stem cell-derived engineered heart tissues (hiPSC-EHTs).

## Overview

This repository contains image-analysis code developed to quantify contractile motion in human induced pluripotent stem cell-derived engineered heart tissues (hiPSC-EHTs).

Contractile displacement is measured using a template-based coordinate-tracking approach. The workflow tracks the movement of the two supporting pillars in time-lapse microscopy images and calculates a displacement profile from the horizontal movement of the pillars.

The analysis consists of two steps:

1. A Fiji/ImageJ macro tracks pillar movement in TIFF image stacks and exports the tracking results as CSV files.
2. A Python notebook analyzes the exported displacement data and calculates contraction amplitude, peak-to-peak interval, contraction duration, and relaxation duration for each beating cycle.

Contractile peaks are identified using `scipy.signal.find_peaks`, and peak widths at the baseline are calculated using `scipy.signal.peak_widths`.

## Repository Contents

- `template_matching_SCRT.ijm`  
  Fiji/ImageJ macro for template-based tracking of the two supporting pillars.

- `wave_form_analysis.ipynb`  
  Python notebook for waveform analysis of the tracking results.

- `README.md`  
  Documentation for installation and use.

- `.gitignore`  
  Git ignore rules for Python and Jupyter-generated files.

## Analysis Workflow

The scripts should be executed in the following order:

1. `template_matching_SCRT.ijm`
2. `wave_form_analysis.ipynb`

The Fiji/ImageJ macro generates a CSV file containing frame-by-frame displacement information. The Python notebook then uses this CSV file to calculate contraction parameters.

## Requirements

### Fiji/ImageJ

The following software is required for the image-tracking step:

- [Fiji](https://fiji.sc/) or ImageJ
- [Template Matching and Slice Alignment plugin](https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin) by Qingzong Tseng

The macro calls the plugin command `Align slices in stack...`.

### Installing the Fiji Plugin

The plugin developer recommends installation through the Fiji update manager:

1. Open Fiji.
2. Select **Help > Update...**
3. Select **Manage update sites**.
4. Add the following update site:

   ```text
   [https://sites.imagej.net/Template_Matching/](https://sites.imagej.net/Template_Matching/)
   ```

5. Enable the newly added update site.
6. Apply the changes and restart Fiji.

Users should confirm that the Template Matching functions are available in the Fiji plugins menu after restarting Fiji.

The [plugin documentation](https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin) provides troubleshooting and manual installation instructions.

### Python

The waveform analysis was performed using:

- Python 3.10.6
- SciPy 1.15.3
- NumPy
- pandas
- Matplotlib
- Jupyter Notebook or JupyterLab

The required Python packages can be installed with:

```bash
python -m pip install scipy==1.15.3 numpy pandas matplotlib jupyter
```

## Step 1: Preparing the Image Data

Users should prepare each time-lapse microscopy video before running the Fiji macro:

1. Import each time-lapse microscopy video into Fiji.
2. Crop the image to the region containing the EHT and its two supporting pillars.
3. Orient the image so that the two pillars are positioned horizontally.
4. Save each time-lapse series as a multi-frame TIFF stack with the `.tif` extension.

Each TIFF file should contain one complete time series for one sample.

The macro automatically defines tracking regions covering the left third and right third of the image with a 25-pixel margin from the outer edges. Therefore, users should verify that the two supporting pillars remain within these regions throughout the time series.

## Step 2: Running the Fiji/ImageJ Macro

1. Open Fiji.
2. Open `template_matching_SCRT.ijm`, for example by dragging the macro file into the Fiji window or by selecting **Plugins > Macros > Run...**
3. Run the macro.
4. When prompted, select the directory containing the TIFF image stacks.
5. Enter the image-file suffix. The default value is:

   ```text
   .tif
   ```

The macro searches the selected directory and its subdirectories for files with the specified suffix.

The macro performs the following steps for each TIFF stack:

1. converts the image stack to 8-bit;
2. defines tracking regions around the left and right pillars;
3. aligns the image stack to the left pillar using the first slice as the reference and tracks the horizontal displacement of the right pillar; and
4. exports the displacement results as a CSV file.

### Fiji Macro Output

An input file named:

```text
sample01.tif
```

produces an output file named:

```text
sample01_Results.csv
```

The output CSV file contains the following columns required by the analysis workflow:

- `Slice`: frame or slice number
- `dX`: horizontal displacement in pixels
- `dY`: vertical displacement in pixels

The Python notebook uses `Slice` and `dX` for waveform analysis. The `dY` column is exported by the tracking plugin but is not used in the current Python analysis.

## Step 3: Preparing the Sample List

Create a CSV file listing the tracking-result files to be analyzed.

The sample-list CSV must contain the following columns:

- `name`: input filename without the `.csv` extension
- `rate`: video frame rate in frames per second (fps)

Example `sample_list.csv`:

```csv
name,rate
sample01_Results,30
sample02_Results,30
sample03_Results,20
```

The `name` value must include `_Results` because the Fiji macro appends `_Results` to each output filename.

For example:

```text
sample01.tif
```

is converted by the macro to:

```text
sample01_Results.csv
```

and should therefore be listed as:

```text
sample01_Results
```

in the sample-list CSV.

## Step 4: Configuring the Python Notebook

Open `wave_form_analysis.ipynb` and locate the following variables in the first code cell:

```python
dir = 'xxx'
datalist = pd.read_csv('xxxx.csv')
pixel_length = 6.8
```

Update these values before running the notebook.

### `dir`: directory containing the tracking CSV files

Specify the directory containing the CSV files generated by the Fiji macro.

The path must end with `/` because the current notebook constructs input paths by joining strings.

macOS or Linux example:

```python
dir = '/path/to/tracking_results/'
```

Windows example:

```python
dir = 'C:/Users/username/Data/tracking_results/'
```

Forward slashes are recommended for Windows paths to avoid problems with backslash escape sequences.

### `datalist`: sample-list CSV

Specify the path to the sample-list CSV:

```python
datalist = pd.read_csv('sample_list.csv')
```

A relative path is interpreted relative to the directory from which the Jupyter notebook server was started. An absolute path can also be used.

### `pixel_length`: spatial calibration

Specify the physical distance represented by one pixel, in micrometres per pixel:

```python
pixel_length = 6.8
```

Replace this value with the spatial calibration used for your imaging system.

The same `pixel_length` value is applied to all samples processed in one execution of the notebook.

## Step 5: Running the Waveform Analysis

Users should run the first code cell of `wave_form_analysis.ipynb` after configuring the three variables.

The notebook performs the following steps for each sample:

1. reads the `Slice` and `dX` values;
2. converts horizontal displacement from pixels to micrometres;
3. converts the frame index to time using the sample-specific frame rate;
4. detects contraction peaks using `scipy.signal.find_peaks`;
5. determines peak width at the baseline using `scipy.signal.peak_widths`;
6. calculates contraction amplitude;
7. calculates contraction and relaxation durations; and
8. calculates the interval between consecutive contraction peaks.

The current analysis uses a default peak-width search window of 150 frames (`wlen = 150`), which reliably processes standard 10-second recordings acquired at 60 fps. Users can evaluate the accuracy of peak and baseline detection by inspecting the exported `.png` waveform plot. If videos acquired at higher frame rates or showing slower relaxation are not analyzed properly (for example, if the horizontal baseline markers do not reach the base of the peaks), users can increase the `wlen = 150` value in the notebook to expand the search window.

## Python Analysis Outputs

An input file named:

```text
sample01_Results.csv
```

produces the following output files in the same directory:

### Waveform plot

```text
sample01_Results.png
```

This image shows the displacement waveform, detected peaks, and baseline peak-width measurements.

### Contraction measurements

```text
sample01_Results_wave_form.csv
```

This file contains one row per detected contraction cycle and includes:

- `amplitude`: contraction amplitude in micrometres
- `contract`: contraction duration in seconds
- `relax`: relaxation duration in seconds

### Peak-to-peak intervals

```text
sample01_Results_peak_interval.csv
```

This file contains:

- `peak interval`: interval between consecutive contraction peaks in seconds

Peak-to-peak intervals are meaningful only when at least two contraction peaks are detected.

## Important Notes

- The workflow was developed for EHT images in which the two supporting pillars are positioned horizontally.
- The Fiji macro uses fixed, automatically generated tracking regions covering the left third and right third of the image with a 25-pixel margin from the outer edges.
- Images should therefore be cropped and oriented consistently before analysis.
- The Python analysis uses horizontal displacement (`dX`) and does not use vertical displacement (`dY`).
- The frame rate must be specified separately for each sample in the sample-list CSV.
- The spatial calibration specified by `pixel_length` is applied to every sample analyzed in the same notebook run.
- Input image data and experimental CSV files are not included in this repository.

## Related Manuscript

This repository contains image-analysis code developed for a research study on contractile motion in human induced pluripotent stem cell-derived engineered heart tissues (hiPSC-EHTs).

A manuscript describing the study and the application of this analysis workflow has been submitted for publication. Publication details will be added when they become publicly available.

## Authors and Contact

Shinichiro Horiuchi<sup>1</sup>  
Noritaka Masaki<sup>2</sup>  
Akatsuki Kimura<sup>2,3</sup>  
Daiju Yamazaki<sup>1,*</sup>

<sup>1</sup> Division of Pharmacology, National Institute of Health Sciences, Kawasaki, Kanagawa 210-9501, Japan  
<sup>2</sup> Cell Architecture Laboratory, National Institute of Genetics, 1111 Yata, Mishima, Shizuoka 411-8540, Japan  
<sup>3</sup> Genetics Program, The Graduate University for Advanced Studies (SOKENDAI), 1111 Yata, Mishima, Shizuoka 411-8540, Japan  
<sup>*</sup> Corresponding author: Daiju Yamazaki (daiju-y@nihs.go.jp)

## Third-Party Software

The `template_matching_SCRT.ijm` macro uses the Template Matching and Slice Alignment plugin developed by Qingzong Tseng. This plugin is distributed separately and is not included in this repository.

Plugin information:

- https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin
- https://sites.imagej.net/Template_Matching/

Users should consult the plugin documentation for its installation requirements, licensing terms, and appropriate citation.

## License

This software is released under the MIT License. See the `LICENSE` file for details.

Third-party software used by this workflow is subject to its own respective license terms.
