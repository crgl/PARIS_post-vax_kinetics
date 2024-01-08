[![DOI](https://zenodo.org/badge/740166464.svg)](https://zenodo.org/doi/10.5281/zenodo.10467602)
# Antibody kinetics after SARS-CoV-2 mRNA vaccination in PARIS

This repository contains SAS code corresponding to a 2-component nonlinear mixed-effects model used in an upcoming paper (preprint doi: https://doi.org/10.1101/2023.08.26.23294679).

The code can be adapted to other datasets containing longitudinal measurements of humoral immunity after vaccination, but was originally fit using SARS-CoV-2 spike binding IgG titers (AUC). The models can be run directly on the dataset used for the paper (available on ImmPort) after the following changes:
* Age must be approximated by an integer (age ranges are included)
* The directory structure for input and output has to be created in advance (the code generates files but not folders)
* Absolute filepaths for all inputs and outputs must be changed in the body of the code to match the directory structure on your local machine
