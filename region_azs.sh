#!/bin/bash

REGIONS=$(aws ec2 describe-regions | jq -r '.Regions[] | .RegionName')

for reg in $REGIONS
  do
  AZS=$(aws ec2 describe-availability-zones --region $reg | jq -r '.AvailabilityZones | map(.ZoneName) | join (", ")')
  echo REGION:$reg%AZs:$AZS | column -s % -t
  done
