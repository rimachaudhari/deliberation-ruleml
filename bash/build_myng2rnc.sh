#!/bin/bash
# Fully local build script for RNC
# Dependencies
# indep_valid_modules/*.rnc
# aux_valrnc.sh
# batch_rnc2rng.sh
# batch_config2rnc.sh
# batch_config2rnc4simp.sh
# batch_rnc_test_suite.sh
# batch_rnc2simp.sh
shopt -s nullglob
BASH_HOME=$( cd "$(dirname "$0")" ; pwd -P )/
REPO_HOME="${BASH_HOME}../"
RNC_HOME=${REPO_HOME}relaxng/
#
# Validate modules individually
for file in ${RNC_HOME}indep_valid_modules/*.rnc
do
  ${BASH_HOME}aux_valrnc.sh "${file}" >> /dev/null 2>&1
  if [ "$?" -ne "0" ]; then
     echo "Module Validation Failed"
     exit 1
  fi
done
# Validate modules all together
for file in "${RNC_HOME}all_"*.rnc
do
  ${BASH_HOME}aux_valrnc.sh "${file}" >> /dev/null 2>&1
  if [ "$?" -ne "0" ]; then
     echo "Driver Validation Failed"
     exit 1
  fi
done
# Generate RNC and convert to RNG, and validate
${BASH_HOME}batch_rnc2rng.sh  >> /dev/null 2>&1
if [ "$?" -ne "0" ]; then
     echo "Validation Against Design Failed"
     exit 1
fi
# Generate RNC for Testing
${BASH_HOME}batch_config2rnc.sh  >> /dev/null 2>&1
if [ "$?" -ne "0" ]; then
     echo "Local Configuration of RNC Schemas Failed"
     exit 1
fi
# Validate Examples in Relax NG Test Suites
${BASH_HOME}batch_rnc-test-suite.sh  >> /dev/null 2>&1
if [ "$?" -ne "0" ]; then
     echo "Local Testing of RNC Schemas Failed"
     exit 1
fi
# Generate RNC for Simplification
${BASH_HOME}batch_config2rnc4simp.sh  >> /dev/null 2>&1
if [ "$?" -ne "0" ]; then
     echo "Local Configuration of RNC Schemas for Simplification Failed"
     exit 1
fi
# Simplify, and validate
${BASH_HOME}batch_rnc2simp.sh  >> /dev/null 2>&1
if [ "$?" -ne "0" ]; then
     echo "Simplification Failed"
     exit 1
fi
