#! /bin/bash

cd ../../e90
aws s3 cp --recursive ./ s3://$1/e90/ 