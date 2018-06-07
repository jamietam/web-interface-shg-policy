## The Tobacco Control Policy (TCP) tool
- This repository is used to run the Smoking History Generator (SHG) Policy Module and generate results for the [TCP tool](http://www.tobaccopolicyeffects.org)
- The TCP tool is a web-based user interface for a tobacco policy microsimulation model developed by the [Cancer Intervention and Surveillance Modeling Network (CISNET)](http://cisnet.cancer.gov) Lung consortium. 

## Help
- Contact jamietam@umich.edu with questions

## Requirements
-`smoking-history-generator v.6.3.3` (contact shg-distrib@lung.cisnet-group.org for requests)
-`shg-policy-module v0.1.2`(contact shg-distrib@lung.cisnet-group.org for requests)
- `R version 3.2.3`
- `python version 2.7.12`

## Overview
<strong>1) Choose a policy to simulate</strong>
  - `airlaws`: implementing and enforcing smoke-free air laws (219 possible scenarios)
  - `taxes`: raising the price of a pack of cigarettes via taxes (127 possible scenarios)
  - `tcexp`: increasing the level of tobacco control program expenditures (56 possible scenarios)
  - `mla`: raising the minimum age of legal access to tobacco (45 possible scenarios)

<strong>2) Run the policy module</strong> `python policy_shg.py`
  - for every parameter combination (219 scenarios total)
  - for the baseline scenario (no increase in smoke-free airlaws implemented)
  

<strong>3) Generate national and state-level results under every scenario</strong> `Rscript tcptool_airlaws_data.R`
  - smoking prevalence (results_[parameters].csv)
  - premature deaths avoided (deaths_[paremeters].csv)
  - life-years gained (lyg_[parameters].csv)
  

<strong>4) Check for errors in the results files</strong> `Rscript check_files_for_errors.R`
  - missing policy scenarios
  - missing rows of data
  - negative sum of deaths avoided across all cohorts
  - ratio of deaths avoided between men and women is greater than 2
