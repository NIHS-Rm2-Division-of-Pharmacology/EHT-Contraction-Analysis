# EHT-Contraction-Analysis
Coordinate-based cloud pipeline for EHT contraction analysis

## Configuration Before Running

Before executing the script `wave_form_analysis.ipynb`, you must update three specific variables in the code to match your local environment and experimental data. 

Open the script and locate the following section (around line 10):

```python
dir = 'xxx' # define initial directory for the dialog
datalist=pd.read_csv('xxxx.csv') # read csv data
pixel_length = 6.8# length for 1 pixel
```

Please replace the placeholder values with your actual data specifications:

1. dir (Data Directory Path)

Description: The absolute or relative path to the folder containing your output CSV files to be analyzed.

Note: Ensure the path ends with a slash (/ for Mac/Linux, or \\ for Windows).

Example: dir = 'C:/Users/Data/Experiment_01/'

2. datalist (Sample List CSV)

Description: The file name (or path) of your metadata CSV file that lists the samples to be processed.

CRITICAL: Your CSV file must contain at least the following two column headers:

name: The prefix of your data file names (excluding the .csv extension).

rate: The frame rate (fps) of the corresponding video.

Example Code: datalist = pd.read_csv('sample_list.csv')

3. pixel_length (Pixel Calibration)

Description: The physical distance represented by a single pixel in your imaging setup (typically in µm/pixel). This is used to scale the raw pixel displacements into actual physical lengths.

Example: pixel_length = 1.25
