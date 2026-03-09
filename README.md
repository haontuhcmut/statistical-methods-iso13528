## Statistical Methods ISO 13528

This repository implements statistical methods for proficiency testing (PT) and interlaboratory comparisons according to **ISO 13528:2015**.  
It provides R code and templates to:

- Import and validate PT data
- Calculate assigned values and their uncertainties
- Compute participant performance statistics (e.g. z-scores)
- Generate summary tables and graphical reports (histograms, density plots, z-score charts, uncertainty charts)

The workflow is designed to be reproducible and transparent for PT providers and analysts.

---

### 1. Project Structure

- **`src/`**  
  - `main.R`: Main analysis script that orchestrates data import, calculations, and output generation.
- **`data_template/`**  
  - `data_ref_iso13528.xlsx`: Example/reference data set following ISO 13528 structure.  
  - `homogeneity_ISO_13528_2015_v2_ref_Dr. Michael Koch.xlsx`: Example data for homogeneity and stability testing according to ISO 13528.
- **`output/`** *(generated)*  
  - `ISO13528_Results.csv`: Summary of calculated statistics (assigned values, standard deviations, z-scores, etc.).  
  - `Histogram_Density.png`: Histogram and density plot of participant results.  
  - `Zscore_Chart.png`: Plot of participant z-scores.  
  - `Uncertainty_Chart.png`: Illustration of uncertainties associated with assigned values and/or participant results.  
  - `Analysis_Console_Log.txt`: Console log of the analysis run (messages, warnings, errors).
- **`LICENSE`**  
  - Licensing information for this project.
- **`README.md`**  
  - Project documentation (this file).

---

### 2. Requirements

- **Operating system**: macOS, Linux, or Windows
- **Software**:
  - [R](https://cran.r-project.org/) (version X.Y.Z or later – update this to what you use)
- **R packages** (examples; adapt to your project):
  - `readxl`
  - `dplyr`
  - `ggplot2`
  - `tidyr`
  - `stringr`

You can install required packages in R, for example:

```r
install.packages(c("readxl", "dplyr", "ggplot2", "tidyr", "stringr"))
```

If you maintain a dedicated dependency file (e.g. `renv.lock` or a custom script), refer to it here.

---

### 3. Getting Started

#### 3.1. Clone the repository

```bash
git clone <your-repo-url>.git
cd statistical-methods-iso13528
```

#### 3.2. Open R or RStudio

Open the project directory in R or RStudio and ensure the working directory is set to the repository root.

```r
setwd("/path/to/statistical-methods-iso13528")
```

#### 3.3. Install dependencies

Install the required R packages (see **Requirements**). If you provide a dedicated script, mention it here, for example:

```r
source("src/install_packages.R")
```

---

### 4. Usage

#### 4.1. Input data

Place your PT data files in `data_template/` following the structure of the provided example files:

- **Participant results file** (similar to `data_ref_iso13528.xlsx`):
  - Columns might include: participant ID, result, uncertainty, flags, etc.
- **Homogeneity/stability file** (similar to `homogeneity_ISO_13528_2015_v2_ref_Dr. Michael Koch.xlsx`):
  - Data required to assess homogeneity and stability as per ISO 13528.

Document your exact expected column names and formats here if they are fixed.

#### 4.2. Run the main analysis

From R:

```r
source("src/main.R")
```

The script will typically:

1. Read input data from `data_template/`.
2. Validate and clean data.
3. Calculate:
   - Assigned value(s)
   - Standard deviation(s) for proficiency assessment
   - z-scores (and, if implemented, z′-scores or other performance statistics)
4. Produce summary tables and graphics in `output/`.
5. Log relevant messages to `output/Analysis_Console_Log.txt`.

If there are configurable parameters (e.g. selected method for assigned value, robust statistics options, exclusion rules), briefly describe how to set them in `main.R` or in a separate configuration file.

---

### 5. Implemented Statistical Methods (ISO 13528)

Describe which ISO 13528 methods you implement. For example (adjust to match your code):

- **Assigned value**:
  - Robust mean (Algorithm A)  
  - Classical mean (with outlier removal rules)
- **Standard deviation for proficiency assessment**:
  - Robust standard deviation (Algorithm A)  
  - Fixed standard deviation (predefined by PT provider)
- **Performance statistics**:
  - z-score
  - z′-score (if uncertainty of assigned value is taken into account)
  - Other indices as implemented
- **Homogeneity and stability**:
  - Analysis of variance (ANOVA) for homogeneity testing
  - Trend analysis or other methods for stability (if applicable)

If you rely on specific clauses of ISO 13528:2015, you can list them here (e.g. Clause 5.1, Annex C, etc.).

---

### 6. Example Workflow

1. **Prepare data**:  
   - Copy your PT data into `data_template/` following the provided examples.
2. **Check configuration**:  
   - Open `src/main.R` and review any configuration sections (file paths, method choices, parameters).
3. **Run analysis**:  
   - Execute `source("src/main.R")` in R.
4. **Review results**:  
   - Open `ISO13528_Results.csv` to inspect numerical results.  
   - Inspect `Histogram_Density.png`, `Zscore_Chart.png`, and `Uncertainty_Chart.png` for graphical summaries.  
   - Review `Analysis_Console_Log.txt` for any warnings or issues during the run.

---

### 7. Troubleshooting

- **Missing packages**:  
  - Ensure all required R packages are installed (see **Requirements**).
- **File not found errors**:  
  - Confirm that your input files are located in `data_template/` and that filenames in `main.R` match exactly.
- **Unexpected results or NA values**:  
  - Check data for missing or non-numeric entries in result columns.  
  - Verify that all required columns are present and correctly named.

If you encounter persistent issues, collect `Analysis_Console_Log.txt` and a subset of your input data for debugging.

---

### 8. Contributing

Contributions are welcome. Typical ways to contribute:

- Reporting bugs or suggesting improvements via issues
- Adding or improving documentation
- Extending the implementation to cover additional ISO 13528 methods or use cases

Before opening a pull request, please:

- Ensure code is clearly written and documented where necessary
- Include example data or tests if you add new methods

---

### 9. License

This project is licensed under the terms described in the `LICENSE` file.  
Please review the license before using the code in production or redistributing it.

---

### 10. References

- ISO 13528:2015 – *Statistical methods for use in proficiency testing by interlaboratory comparison*. 
- Other relevant publications or guidance documents you rely on (add as needed).
