# CHANGES IN radiant.multivariate VERSION 0.7.5

## NEW FEATURES
- Added k-medians, from the Gmedians package, as an option in _Multivariate > K-clustering_
- Added additional rotation options in _Multivariate > Factor_
- Added predict tab for conjoint
- Added option to analyse conjoint data for multiple respondents (`By`) or for a specific respondent (`Show`)
- Store PWs or IWs from conjoint analysis for multiple respondents
- Derive and store predictions based on conjoint analysis for multiple respondents
- Show dataset name in output if dataframe passed directly to analysis function
- As an alternative to using the Estimate button to run a model you can now also use CTRL-enter or CMD-enter

## BUG FIXES
- Import from `GPArotation`

## DEPRECATED
- kmeans_clus was replaced by kclus
- hier_clus was replaced by hclus
