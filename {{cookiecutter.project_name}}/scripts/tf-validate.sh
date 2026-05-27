#!/bin/sh

set -eu

CI=${CI:-false}

ENVS=$(ls -d tf/*/ | grep -v -E '(modules|terraform)')
TF_BIN="$(pwd)/.terraform-bin/terraform.exe"

for ENV in ${ENVS[@]}; do
  if [[ ${CI} == 'true' ]]
  then
    echo "validating environment ${ENV} in CI"
    terraform -chdir=${GITHUB_WORKSPACE}/${ENV} init -backend=false
    terraform -chdir=${GITHUB_WORKSPACE}/${ENV} validate -json
  else
    echo "validating environment ${ENV}"
    "${TF_BIN}" -chdir=${ENV} init -backend=false
    "${TF_BIN}" -chdir=${ENV} validate -json
  fi
done
