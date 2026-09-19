Population-Doubling
Population Doubling & Growth Rate Analysis (HEK293 SIP-KO, 2025)

This repository contains R code and data used for analyzing the population 
doubling rate (PDT) of HEK293 CacyBP/SIP knockout cell lines compared with 
wild-type Control. The experiment measures cell proliferation across multiple 
days to assess potential growth defects caused by SIP depletion.


Experimental Groups
| Group | Description |
|-------|-------------|
| Control | Wild-type HEK293 |
| Clone 5 | Full KO |
| Clone 9 | Almost Full KO |
| Clone 44 | Almost Full KO |


Parameters Analyzed
- Cell count over time
- Population Doubling Level (PDL)
- Population Doubling Time (PDT)
- Proliferation curve visualization
- Growth comparison between clones



Output Example

- Growth curve (Control vs KO clones)
- PDT barplot with error bars
- Statistical comparison (ANOVA or Welch depending on test results)

> A decrease or increase in PDT directly reflects changes in proliferation rate.

Credits:
Developed and analyzed by Omid (SIP KO Project, 2024-2025)
Nencki Institute of Experimental Biology, Warsaw
