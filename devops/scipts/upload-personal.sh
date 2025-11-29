#! /bin/bash

cd ../../personal
aws s3 cp --recursive ./ s3://$1/personal/ 