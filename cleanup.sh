#!/bin/bash

find . -name .DS_Store -type f -delete
find . -name .terraform -exec rm -r "{}" \;
find . -name .terraform.lock.hcl -type f -delete
find . -name terraform.tfstate -type f -delete
find . -name terraform.tfstate.backup -type f -delete
