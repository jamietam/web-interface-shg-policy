## Help
- Contact Ben Racine with any questions:
	- Email: ben.racine@cornerstonenw.com
	- Skype: csnw.ben.racine
	- I can recommend [join.me](https://join.me/) as a tool for easily sharing your screen with me if necessary.

## Table of Contents
- [Git basics](https://github.com/CSNW/shg-policy-module/wiki/Git-Basics)
- [Issue Tracking](https://github.com/CSNW/shg-policy-module/issues?state=open)
- [Installation](https://github.com/CSNW/shg-policy-module/wiki/Installation)
- [Execution](https://github.com/CSNW/shg-policy-module/wiki/Execution)
- [Obtaining the Results Viewer](https://github.com/CSNW/shg-policy-module/wiki/Results-Viewer)

## SHG Information
The SHG itself is provided in binary form in this project. Its development is tracked elsewhere. The latest [source code](https://cisnet.flexkb.net/files/shg-v6.2.4.zip) is available as is [further information](https://cisnet.flexkb.net/wc.dll?cisnet~LungBaseCaseSmokingHistoryGeneratorParameter).

## Quickstart
- If you have not already, obtain the codebase: `git clone git@github.com:CSNW/shg-policy-module.git`
- Move to the latest branch, e.g. 0.1.1. This branch includes all v6.3.1 SHG efforts: 
  - `git fetch --all`
  - `git checkout v0.1.1`
- Run the policy module: `python policy_shg.py`
- Clean up the results of a policy module run: `python cleanup_runs.py`
