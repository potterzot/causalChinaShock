<!-- README.md is generated from README.Rmd. Please edit that file -->
### Causal China Shock

[![Travis-CI Build Status](https://travis-ci.org/potterzot/CausalChinaShock.svg?branch=master)](https://travis-ci.org/potterzot/CausalChinaShock)

The current version of this paper will be available here: [Potter2016.pdf](blob/master/analysis/Potter2016.pdf).

This repository serves as a research compendium for replication and extension efforts for "The China Shock", a paper by Autor, Dorn, and Hanson (2016) that has caused quite a stir among economists. The goal is to develop the same dataset and thereby replicate some of the results in their paper, and also consider the implications of a causal bayesian approach using the package [CausalImpact](https://google.github.io/CausalImpact/).

This repository also serves as an example of a "reproducible research package" of the type advocated by rOpenScience's [rrrpkg](https://github.com/ropensci/rrrpkg). It is built as an installable R package, and if installed will make available the common functions used in the analysis, as well as at least a subset of the available data. The actual data processing and analysis happens in the [analysis](blob/master/analysis/) folder.

To use this package, you can either install the R package only, which will not provide the analysis files:

``` r
devtools::install_github("potterzot/CausalChinaShock")
```

Alternatively, you can clone the repository and then build the package locally, will will provide both an installed package as well as the analysis scripts and data.

#### References

-   Autor, D.H., Dorn, D. and Hanson, G.H., 2016. The China shock: Learning from labor market adjustment to large changes in trade. *Annual Review of Economics*, 8(1).
