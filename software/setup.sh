#!/bin/bash

# Setup environment
source /afs/slac.stanford.edu/g/reseng/vol26/anaconda/miniconda3/etc/profile.d/conda.sh
conda activate rogue_v3.3.2
#conda activate rogue_pre-release

export PYTHONPATH=${PWD}/Kcu105Eth-0x00000001-20181108083817-mdewart-0d3fa970.python/python:${PYTHONPATH}
