---
title: 'A web application to estimate differences in diagnostic efficiency based on differences between single-condition cases'
tags:
  - diagnostics
  - effect size
  - auc
  - accuracy metrics
  - classification
  - power
  - shinyapp
authors:
 - name: Gáspár Lukács
   orcid: 0000-0001-9401-4830
   affiliation: 1
affiliations:
 - name: University of Vienna, Department of Cognition, Emotion, and Methods in Psychology, Austria
   index: 1
date: 24 June 2020
bibliography: paper.bib
---

# Summary

Prospective (a priori) power analysis to determine the required sample size is crucial for behavioral experiments [e.g., @perugini_2018]. To determine the smallest effect of interest required for the power analysis, the ideal way is to rely on objective justification [@cohen_1988; @lakens_2013; @lakens_2018]. For example, to compare two different diagnostic methods (e.g. an old one and a new one with a potential improvement), one may consider the real life implications of a given increase in the rate of correct detections of a disease in relation to the costs of the sample size required to show statistical evidence for that given increase. A researcher may make the informed and careful decision that it is worth to collect, say, 120 participants to detect an increase of at least 8% in detection accuracy: A 2% or even 0.1% increase could also have important real life benefit, but due to limited resources it is not worth collecting the much larger sample sizes required to detect such smaller changes.

However, the practical implication are not always so straightforward to assess. In one specific scenario in experimental design, two diagnostic methods may be validly compared using single-condition cases, omitting controls (a.k.a. "baseline" or "negative condition") to spare resources. This scenario can occur in any of the many fields applying binary classification, perhaps most characteristically in medicine. A hypothetic disease might be diagnosed with a continous measure X, which is typically higher for persons with a given disease (such as a small bump or redness in reaction to a skin prick test; positive cases), while it is generally the same for healthy persons (such as no or little reaction to a skin prick test; negative cases). Thereby positive cases can be detected with a certain accuracy – but not perfectly, because some of the measurements are to some extent faulty and give mistakenly low values for positive cases too. If someone proposed an improvement on the procedure to achieve higher values in measure X, it would be possible to directly compare the two methods on positive cases only: Since the measure will always be constant (low) in negative cases (healthy persons), higher values for positive cases means that the procedure will also have better diagnostic efficiency.

The problem here is that the effect size for the potential power calculation is between two positive conditions, which have no direct implication for the practical consequences in diagnostics. The presented software is a Shiny R application that helps by providing estimations for diagnostic efficiency values (correct detection rates and areas under the curves) for given effect sizes between positive conditions alone. This is the first software to address this specific issue – and in fact, to my knowledge, the present paper is the first one to take note of this issue at all.

The application can be used online via https://gasparl.shinyapps.io/esdi/, with detailed documentation along with source code at https://github.com/gasparl/esdi.

# Note

This work was actually inspired by a frequently researched lie detection test: 13 out of 24 studies (selected out of hundreds of other studies for reasons unrelated to the present paper) collected in a recent meta-analysis used single-condition comparison without any objective justification for sample sizes [@lukacs_2020].

# Acknowledgments

Gáspár Lukács is a recipient of a DOC Fellowship of the Austrian Academy of Sciences at the Department of Cognition, Emotion, and Methods in Psychology at the University of Vienna.

# References
