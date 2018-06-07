## The Tobacco Control Policy (TCP) tool
- This repository is used to run the Smoking History Generator (SHG) Policy Module and generate results for the [TCP tool](http://www.tobaccopolicyeffects.org)
- The TCP tool is a web-based user interface for a tobacco policy microsimulation model developed by the [Cancer Intervention and Surveillance Modeling Network (CISNET)](http://cisnet.cancer.gov) Lung consortium. 

## Help
- Contact jamietam@umich.edu with questions
- Contact shg-distrib@lung.cisnet-group.org to request copies of the `smoking-history-generator v.6.3.3` and `shg-policy-module v0.1.2`

## Requirements
- `R version 3.2.3`
- `python version 2.7.12`
- `smoking-history-generator v.6.3.3`
- `shg-policy-module v0.1.2`

## Overview
<strong>1) Choose a policy to simulate and select parameters</strong>
  - `airlaws`: implement and enforce smoke-free air laws up to three venues (219 possible scenarios)
    - workplaces? 0 (no) or 1 (yes)
    - restaurants? 0 or 1
    - bars? 0 or 1
    - percent of workplaces already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
    - percent of restaurants already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
    - percent of bars already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
    
  - `taxes`: raising the price of a pack of cigarettes via taxes (127 possible scenarios)
    - initial price per pack? $6.00, $6,50, $7.00, $7.50, $8.00, $8.50, $9.00, $9.50, $10.00, $10.50
    - tax increase? $1.00, $1.50, $2.00, $2.50, $3.00, $3.50, $4.00, $4.50

  - `tcexp`: increasing the level of tobacco control program expenditures (56 possible scenarios)
    - existing level of expenditures (as % of CDC recommendations)? 0%, 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, or 100%
    - policy level of expenditures? 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, or 100%
    
  - `mla`: raising the minimum age of legal access to tobacco (45 possible scenarios)
    minimum age? 19, 21, or 25
    - percent of population already covered by MLA 19? 0%, 25%, 50%, 75%, or 100%
    - percent of population already covered by MLA 21? 0%, 25%, 50%, 75%, or 100%
    - percent of population already covered by MLA 21? 0%, 25%, 50%, 75%, or 100%
    
<strong>2) Run the policy module</strong> `python policy_shg.py`
  - for every parameter combination (219 scenarios total)
  - for the baseline scenario (no increase in smoke-free airlaws implemented)

<strong>3) Generate national and state-level results under every scenario</strong> `Rscript tcptool_airlaws_data.R`
  - smoking prevalence (results_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv)
  - premature deaths avoided (deaths_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv)
  - life-years gained (lyg_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv)

<strong>4) Check for errors in the results files</strong> `Rscript check_files_for_errors.R`
  - missing policy scenarios
  - missing rows of data
  - negative sum of deaths avoided across all cohorts
  - ratio of deaths avoided between men and women is greater than 2
