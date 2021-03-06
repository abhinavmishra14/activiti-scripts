#!/usr/bin/env bash
set -e

PROJECTS=${PROJECTS:-activiti}
echo "PROJECTS ${PROJECTS}"
echo "SCRIPT_DIR ${SRC_DIR:-$HOME/src}"
mkdir -p ${SRC_DIR:-$HOME/src} && cd ${SRC_DIR:-$HOME/src}

CLONE_MODE=${CLONE_MODE:-SSH}

COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    echo "REPO_LINE ${REPO_LINE}"
    REPO=${REPO_ARRAY[0]}
    echo "REPO ${REPO}"
    TAG=${REPO_ARRAY[1]}

    pushd ${PWD} > /dev/null
    echo "*************** EXECUTE ON ${REPO} :: START ***************"
    if ! [ -d "${REPO}" ]
    then
      REPO_DIR=$(dirname ${REPO})
      mkdir -p ${REPO_DIR}
      cd ${REPO_DIR}
      if [ "${CLONE_MODE}" == "HTTPS" ]
      then
        git clone https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/${REPO}.git
      else
        git clone git@github.com:Activiti/${REPO}.git
      fi
      cd $(basename ${REPO})
    else
      cd ${REPO}
    fi
    git fetch

    BASEBRANCH=${BASEBRANCH:-develop}

    BASEBRANCHEXISTS=$(git ls-remote origin ${BASEBRANCH}) || true

    if [ -n "$BASEBRANCHEXISTS" ];
      then
        echo 'using' $BASEBRANCH 'as base branch'
      else
        BASEBRANCH=master
    fi

    if [ "$(basename ${SCRIPT})" = "clone.sh" ];
    then
      if  git tag --list | egrep -q "^$RELEASE_VERSION$"
      then
        echo "Found tag - released already"
        git checkout $RELEASE_VERSION
      else
        if [ -z "${TAG}" ];
        then
          echo "Using ${BASEBRANCH} branch";
          git checkout ${BASEBRANCH} || ${IGNORE_TAG_CHECKOUT_FAILURE:-false}
        else
          echo "Checking out tag '${TAG}' for $(pwd)";
          git fetch --tags
          git checkout tags/v$TAG || ${IGNORE_TAG_CHECKOUT_FAILURE:-false}
        fi
      fi
    fi

    . ${SCRIPT:-echo I\'m in ${REPO}}
    echo "*************** EXECUTE ON ${REPO} :: END   ***************"
    popd > /dev/null

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done
