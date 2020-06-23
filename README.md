### ESDI: Effect Sizes versus DIagnostics

Using simulations for the given input values, this Shiny R application shows how diagnostic efficency (as measured by rates of correct detection or areas under the curves) changes in relation to standardized mean difference (_SMD_) effect size differences between single-condition cases (when these are directly compared for lack of controls).

### How to Use

#### Access / Installation

The application is available online (to be simply opened in any web browser): https://gasparl.shinyapps.io/esdi/

However, it is also easy to run it from your PC. You just need to run the following command in **R**:

```R
shiny::runGitHub("esdi", "gasparl")`
```

For this latter alternative, if you don't have them already, you need to install [**R**](https://www.r-project.org/ "R project") and then install the `shiny` package within **R** e.g. by entering `install.packages("shiny")` into the console. Then copy the line `shiny::runGitHub("esdi", "gasparl")` e.g. in the console and press Enter. The necessary components will be automatically downloaded and the application will open up in a new window.

Finally, to use the application any time without internet access, you can download the entire repository (or just _app.R_) and run the code in the _app.R_ file. For this, you would need to install all R packages used in the code (listed in the first lines).

#### Interface

To quickly grasp the essence of the application, see the _Example_ section below, or see _Background_ for the general motivation. What follows here is a detailed technical explanation.

The only settings that influence the key SMD-diagnostics relation is the standard deviation (_SD_) of the values in "case 1" and "case 2", which represent the positive cases (as opposed to baseline controls) in two different condition to be compared (such as method 1 and method 2; for more explanation, see the _Background_ and _Example_ sections below). The SDs should be estimated based on the typical SDs for cases and controls in the given research area. However, SD differences have relatively little impact on the results, and for most cases (where the SD is not known or cannot be easily estimated) it can be assumed that leaving the default settings (`1` for both SDs) will still give approximately correct results. In other words, the default settings of this software are probably applicable for most scenarios.

Based on the given SDs, means of the samples are automatically calculated for each of the SMDs specified under the other settings. _Note: To be brief and yet avoid abbreviation, SMD (Standardized Mean Difference) is indicated as "Effect Size" for option and plot labels on the interface._ Datasets are generated for all the different means (using the two constant SDs) with near-perfect normal distribution. The specification of SMDs is fairly straightforward: a starting value, an end value, and a step must be given. For example, a start of `0.2`, an end of `0.6`, and a step of `0.1` will define the following SMDs: `0.2`, `0.3`, `0.4`, `0.5`, `0.6`. Smaller step (or more distant start and end) means more datapoints to calculate, and therefore these settings can substantially increase calculation time.

It is very important to understand the difference between (a) SMD between single-conditions ("case 1" vs. "case 2") and (b) the SMD between the case and control of a single condition ("case" vs. "control"). The first one (a) is indicative of differences in diagnostic efficiency between two conditions (e.g. an old method and a new improved method), while the second one (b) is merely an alternative measurement for diagnostic efficiency within a given method (e.g. the diagnostic efficiency of the old method), and this latter is always in direct positive correlation with the other diagnostic efficiency measures (so larger "case" vs. "control" SMD always means larger rate of correct detection and larger area under the curve).

The initial "case 1" vs. "control" SMD represents the assumed diagnostic efficiencies of the method to be improved (method 1). (It probably makes little sense in practice to give zero for start value, unless for demonstration purposes, since that would mean that the method 1 perform at chance level, so it's useless in the first place.) The plots depict the improved method's (method 2's) diagnostic efficiency (_Accuracy: "case 2" vs. "control"_)  in relation to the "case 1" vs. "case 2" SMD. It is always good to keep the start value of the "case 1" vs. "case 2" SMD at zero, which then illustrates the point where there is no difference at all between the two methods. Then it can be seen how the increases in the SMD between "case 1" and "case 2" lead to certain extents of improved accuracy. And this is the essence of this entire application.

The values are depicted in two different ways: as total accuracy, and as accuracy gained. Accuracy gained is calculated simply as total accuracy minus initial accuracy. The combined plot contains both types, while the subplots depict these types separately, and may be explored interactively by hovering over the lines with the cursor to read the precise values of SMDs and accuracies at the given points on the plot (see the _Example_ section below).

Since the sample size is not infinite, the distribution can never be truly perfect, and therefore there will be small deviations in the calculated SMD results as compared to the given SMD settings: for example, one initial SMD may be given as `0.5` in the settings, but the actual results may be, for example, `0.51`. Sample size (number of generated datapoints) can be set under the label `N`: larger number leads to somewhat increased calculation time, but more precise results. An `N` of around `4000` will typically give precision up to two fractional digit, while `15000` my be precise up to three fractional digits. Importantly, regardless of sample size (and the correspondance of settings and results), the relation of SMD and diagnostics for the given results is always exact and correct.

The Plot settings relate to the depiction of the data, and should be self-explanatory. All values for the calculation of the plots are available under the Table tab in an interactive data table.

### Background

Prospective (_a priori_) power analysis to determine the required sample size is crucial for behavioral experiments (e.g., Perugini, 2018). However, the magnitude of the expected effect is often hard to estimate. To determine the smallest effect of interest required for the power analysis, the ideal way is to rely on objective justification (Lakens, 2013; Lakens et al, 2018). For example, to compare two different diagnostic methods, one may consider the sample size required for a reasonable increase in the rate of correct detections of a disease in relation to the costs of the required sample size. A researcher may make the informed and careful decision that it is worth to collect, say, 150 participants to detect an increase of at least 5%: A 2% or even 0.1% increase could also have important real life benefit, but due to limited resources it is not worth collecting the much larger sample sizes required to detect such smaller changes.

However, the practical implication are not always so straightforward to assess. In one specific scenario in experimental design, two diagnostic methods may be validly compared using single condition cases, omitting controls (a.k.a. "baseline condition" or "negative condition") to spare resources. This scenario can occur in any of the many fields applying binary classification, perhaps most characteristically in medicine. A hypothetical disease might be diagnosed with a continous measure _X_, which is typically higher for persons with a given disease (positive cases, such as a bump or redness in reaction to a skin prick test), while it is generally the same for healthy persons (such as no or little reaction to a skin prick test; negative cases). Thereby positive cases can be detected with a certain accuracy, though not perfectly, because some of the measurements are faulty and give mistakenly low values for positive cases. If someone proposed an improvement on the procedure to achieve higher values in measure _X_, it would be possible to directly compare the two methods on positive cases only: Since the measure will always be constant (low) in negative cases (healthy persons), higher values for positive cases means that the procedure will also have better diagnostic efficiency.

The problem here is that the effect size for the potential power calculation is between two positive conditions, which have no direct implication for the practical consequences in diagnostics. The present software helps by calculating estimated diagnostic efficiency values (correct detection rates and areas under the curves) for given effect sizes between positive conditions alone.


### Example

Coming ...


### Testing

Coming ...

### Support

If you have any questions or find any issues (bugs, desired features), [write an email](mailto:lkcsgaspar@gmail.com) or [open a new issue](https://github.com/gasparl/esdi/issues "Issues").

### References

Cohen, J. (1988). Statistical power analysis for the behavioral sciences (2nd ed.). Hillsdale, NJ: Erlbaum.

Lakens, D. (2013). Calculating and reporting effect sizes to facilitate cumulative science: A practical primer for t-tests and ANOVAs. Frontiers in Psychology, 4. https://doi.org/10.3389/fpsyg.2013.00863

Lakens, D., Scheel, A. M., & Isager, P. M. (2018). Equivalence Testing for Psychological Research: A Tutorial. Advances in Methods and Practices in Psychological Science, 1(2), 259–269. https://doi.org/10.1177/2515245918770963

Perugini, M., Gallucci, M., & Costantini, G. (2018). A Practical Primer To Power Analysis for Simple Experimental Designs. International Review of Social Psychology, 31(1), 20. https://doi.org/10.5334/irsp.181

