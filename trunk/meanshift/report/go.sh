#!/bin/bash
## run latex twice to get rid of the "rerun
## to get cross-references right" warning
latex report.tex
latex report.tex
dvipdf report.dvi
rm report.dvi
rm *.aux *.log
