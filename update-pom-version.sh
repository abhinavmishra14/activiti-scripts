#!/usr/bin/env bash

echo update pom versions to ${NEXT_VERSION}

PROJECTS=${PROJECTS:-activiti}
GIT_PROJECT=$(basename $(pwd))
echo "SCRIPT_DIR IS $SCRIPT_DIR"

echo "UPDATING POMS IN $(pwd)"

SED_REPLACEMENTS=''

POM_VERSION=$(mvn help:evaluate -B -Dexpression=project.version | grep -e '^[^\[]' 2>/dev/null) || true
POM_VERSION=${POM_VERSION#"null object or invalid expression"}

SED_REPLACEMENTS="${SED_REPLACEMENTS}-e 's@<version>${POM_VERSION}</version>@<version>${NEXT_VERSION}</version>@g'"

PARENT_VERSION=$(mvn help:evaluate -B -Dexpression=project.parent.version | grep -e '^[^\[]' 2>/dev/null) || true
PARENT_VERSION=${PARENT_VERSION#"null object or invalid expression"}

PARENT_ARTIFACT=$(mvn help:evaluate -B -Dexpression=project.parent.artifactId | grep -e '^[^\[]' 2>/dev/null) || true

if [ -n "${PARENT_VERSION}" ];
  then
    if [ "$PARENT_ARTIFACT" != "spring-boot-starter-parent" ];
      then
        SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<version>${PARENT_VERSION}</version>@<version>${NEXT_VERSION}</version>@g'"
    fi
  else
    echo "${GIT_PROJECT} HAS NO PARENT"
fi

COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    REPO=${REPO_ARRAY[0]}

    SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<${REPO}.version>.*</${REPO}.version>@<${REPO}.version>${NEXT_VERSION}</${REPO}.version>@g'"

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done

SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@version>.*</activiti@version>${NEXT_VERSION}</activiti@g'"

EX_RB_VERSION_KEY="example-runtime-bundle.version"
EX_CONNECTOR_VERSION_KEY="example-cloud-connector.version"
SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<${EX_RB_VERSION_KEY}>.*</${EX_RB_VERSION_KEY}>@<${EX_RB_VERSION_KEY}>${NEXT_VERSION}</${EX_RB_VERSION_KEY}>@g'"
SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's@<${EX_CONNECTOR_VERSION_KEY}>.*</${EX_CONNECTOR_VERSION_KEY}>@<${EX_CONNECTOR_VERSION_KEY}>${NEXT_VERSION}</${EX_CONNECTOR_VERSION_KEY}>@g'"

if [ -n "${EXTRA_SED}" ];
  then
    SED_REPLACEMENTS="${SED_REPLACEMENTS} -e ${EXTRA_SED}"
fi

if [[ "$OSTYPE" == "darwin"* ]]
then
  eval "find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  find . -name pom.xml.bak -delete
else
  eval "find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
fi
