#! /bin/bash

cd ../../resume
aws s3 cp --recursive ./ s3://$1/resume/ 