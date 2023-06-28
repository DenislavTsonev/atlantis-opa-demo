#!/bin/bash
ATLANTIS_YAML="atlantis.yaml"
TERRAFORM_VERSION="v0.14.3"
ENVIRONMENTS="dev prod"

touch ${ATLANTIS_YAML}

echo "version: 3" > ${ATLANTIS_YAML}
echo "automerge: false" >> ${ATLANTIS_YAML}
echo "projects:" >> ${ATLANTIS_YAML}

find environment | grep "tf$" | xargs -I % dirname % | sort | uniq | grep -wv .terraform | while read line; do

  export SOURCES=""

  SOURCES+="\"*.tf*\""
  SOURCES+=", \"*.yaml*\""

  if [[ -z "$var" ]]
    then
      for env in ${ENVIRONMENTS}; do
        if [[ ${line} =~ /${env} ]]
          then
            ENVIRONMENT=${env}
            PROJECT_NAME="demo-${env}"
            {
              echo "  - name: ${PROJECT_NAME}"
              echo "    dir: ${line}"
              echo "    terraform_version: ${TERRAFORM_VERSION}"
              echo "    autoplan:"
              echo "      when_modified: [${SOURCES}]"
              echo "      enabled: true"
              echo "    workflow: ${ENVIRONMENT}"
            } >> ${ATLANTIS_YAML}
        fi
      done
  fi
done