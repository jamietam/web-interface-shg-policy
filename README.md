## The Tobacco Control Policy (TCP) tool
- This repository is used to run the Smoking History Generator (SHG) Policy Module and generate results for the [TCP tool](http://www.tobaccopolicyeffects.org)
- The TCP tool is a web-based user interface for a tobacco policy microsimulation model developed by the [Cancer Intervention and Surveillance Modeling Network (CISNET)](http://cisnet.cancer.gov) Lung consortium. 

## Requirements
- `R version 3.2.3`
- `python version 2.7.12`
- `smoking-history-generator v.6.3.3`
- `shg-policy-module v0.1.2`

## Setup
The code in this repository is currently set up to run policy scenarios in parallel across 20 cores, with error and log files for each. Total run-time varies depending on the number of individuals generated per birth cohort (~1 min to simulate 200,000 individuals from a single birth cohort). There are 300 birth cohorts simulated per scenario, except for MLA which simulates 380 birth cohorts. When spread across 20 cores, this dramatically reduces the total amount of time needed to generate a full set of results. Because of the large number of files generated that need to be organized, the directory structure on your machine must be set up accordingly. 

- Create directories one level above this repository to store each set of results: 
  - `airlaws_results`, `taxes_results`, `tcexp_results`, `mla_results` to store each policy's results
  - `source_data` for state-level and US data
  - `shg-policy-module-parallel` as a copy of `shg-policy-module v0.1.2`. To run the model across 20 cores, create 20 copies of shg-policy-module-parallel directory with `python wrapper.py`. 

- Make necessary changes to the file paths referenced in these python and R scripts:
  - `scenarios_airlaws.py`, `scenarios_taxes.py`, `scenarios_tcexp.py`, `scenarios_mla.py`, `tcptool_airlaws_data.py`,`tcptool_taxes_data.py`, `tcptool_tcexp_data.py`,  `tcptool_mla_data.py`, and `check_files_for_errors.R`

## Overview
<strong>1) Choose one tobacco control policy to simulate results for</strong>
  - `airlaws`: implement and enforce smoke-free air laws up to three venues (1080 possible scenarios / runtime ~14 days)
  - `taxes`: raise the price of a pack of cigarettes via taxes (635 possible scenarios)
  - `tcexp`: increase the level of tobacco control program expenditures (280 possible scenarios)
  - `mla`: raise the minimum age of legal access to tobacco (225 possible scenarios)
    
<strong>2) Run the shg policy module for every scenario for your selected policy</strong>
  - `airlaws`: run `python scenarios_airlaws.py` 
  
<strong>3) Generate national and state-level results under every scenario</strong> 
  - `airlaws`: run `Rscript tcptool_airlaws_data.R`
    - smoking prevalence (`results_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv`)
    - premature deaths avoided (`deaths_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv`)
    - life-years gained (`lyg_w1_r1_b1_pacw0.00_pacr0.00_pacb0.00.csv`)
  
<strong>4) Repeat steps 1-3 for remaining tobacco control policies</strong>
  - `taxes`: run `python scenarios_taxes.py`, `Rscript tcptool_taxes_data.R`
  - `tcexp`: run `python scenarios_tcexp.py`, `Rscript tcptool_tcexp_data.R`
  - `mla`: run `python scenarios_mla.py`, `Rscript tcptool_mla_data.R`

<strong>5) Check for errors across the results files</strong> 
  - run `Rscript check_files_for_errors.R` to check results in the `source_data` directory for missing policy scenarios, missing rows of data, negative sum of deaths avoided across all cohorts, and whether the ratio of deaths avoided between men and women is greater than 2
  
## Help
- Contact jamietam@umich.edu with questions
- Contact shg-distrib@lung.cisnet-group.org to request copies of the `smoking-history-generator v.6.3.3` and `shg-policy-module v0.1.2`

## Policy parameters
  - `airlaws`: 
    - workplaces? 0 (no) or 1 (yes)
    - restaurants? 0 or 1
    - bars? 0 or 1
    - percent of workplaces already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
    - percent of restaurants already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
    - percent of bars already covered by smoke-free air laws? 0%, 25%, 50%, 75%, or 100%
       
  - `taxes`: 
    - initial price per pack? $6.00, $6,50, $7.00, $7.50, $8.00, $8.50, $9.00, $9.50, $10.00, $10.50
    - tax increase? $1.00, $1.50, $2.00, $2.50, $3.00, $3.50, $4.00, $4.50

  - `tcexp`: 
    - existing level of expenditures (as % of CDC recommendations)? 0%, 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, or 100%
    - policy level of expenditures? 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, or 100%
    
  - `mla`: 
    - minimum age? 19, 21, or 25
    - percent of population already covered by MLA 19? 0%, 25%, 50%, 75%, or 100%
    - percent of population already covered by MLA 21? 0%, 25%, 50%, 75%, or 100%
    - percent of population already covered by MLA 21? 0%, 25%, 50%, 75%, or 100%
