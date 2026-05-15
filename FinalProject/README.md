# Financial Scars: Prior Financial Distress and Risk-Taking Behavior among U.S. Households

## Project Overview

This project examines whether prior financial distress is associated with more conservative financial behavior among U.S. households. Using data from the Survey of Consumer Finances (SCF), the analysis investigates how experiences such as bankruptcy, foreclosure, and late payments relate to stock market participation and financial risk-taking behavior.

The empirical analysis uses survey-weighted logistic regression models to account for the SCF’s complex survey design. The project contributes to the household finance and behavioral finance literature by exploring whether financial hardship leaves persistent effects on future investment behavior.

---

# Repository Contents

```text
project/
│
├── README.md
├── run_analysis.R
├── output/
├── financial_scars_paper.tex
├── financial_scars_paper.pdf
├── references.bib
└── .gitignore
```

---

# Data Source

This project uses publicly available data from the Federal Reserve Survey of Consumer Finances (SCF).

Data can be downloaded from:

https://www.federalreserve.gov/econres/scfindex.htm

Download the SCF Summary Extract Public Data and save the dataset file in the main project folder.

The script assumes the dataset file is named:

```text
Survey of Consumer Finances.csv
```

The dataset itself is not included in this repository.

---

# Software Requirements

This project was completed using:

- R
- RStudio

Main R packages used:

```r
tidyverse
janitor
skimr
survey
broom
ggplot2
scales
knitr
kableExtra
```

The script automatically installs missing packages if necessary.

---

# Replication Instructions

To reproduce the analysis:

1. Download the SCF Summary Extract Public Data from the Federal Reserve website.
2. Save the dataset file in the main project folder.
3. Rename the dataset file:

```text
Survey of Consumer Finances.csv
```

4. Open `run_analysis.R` in RStudio.
5. Set the working directory to the project folder.
6. Run the script from top to bottom.

The script will automatically:

- clean the data,
- construct variables,
- estimate econometric models,
- generate regression tables,
- create figures,
- export outputs to the `output/` folder.

---

# Main Variables

## Dependent Variables

- `stock_participation`
- `equity_participation`
- `willing_fin_risk`

## Financial Distress Measures

- `prior_loss_proxy`
- `late_payment`
- `late60_payment`
- `bankruptcy5`
- `foreclosure5`

## Financial Controls

- income
- net worth
- debt
- leverage measures

## Demographic Controls

- age
- education
- marital status
- race
- labor force participation
- number of children

---

# Methodology

The analysis uses survey-weighted logistic regression models estimated with the `survey` package in R. Survey weights are incorporated to produce nationally representative estimates for U.S. households.

The econometric specifications examine whether households with prior financial distress exhibit lower participation in risky financial assets after controlling for demographic and financial characteristics.

---

# Output Files

The script automatically generates:

- descriptive statistics tables,
- regression tables,
- predicted probability tables,
- figures,
- cleaned analysis datasets.

All outputs are saved in:

```text
/output/
```

---

# Programming and Reproducibility Notes

The project follows reproducible research practices:

- automatic package installation,
- automated figure and table generation,
- automated output exporting,
- consistent variable naming,
- commented code sections,
- survey-weighted estimation procedures.

No manual editing of tables or figures is required.

---

# Author

Todvwa Dlamini  
University of Oklahoma  
M.A. Economics and B.S. Information Science & Technology

---

# References

Key references used in this project include:

- Kahneman and Tversky (1979)
- Guiso, Sapienza, and Zingales (2008)
- Lusardi and Mitchell (2014)
- Mian, Sufi, and Trebbi (2015)

Full references are available in `references.bib`.



