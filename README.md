# activiti-scripts
Activiti Scripts for Building Projects

Includes a script to checkout and build all the Activiti repositories.

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./build-all.sh

will build all the repositories listed in the index files:

* [activiti](./repos-activiti.txt)
* [activiti-cloud](./repos-activiti-cloud.txt)
* [activiti-cloud-examples](./repos-activiti-examples.txt)

To clone all:

    PROJECTS=activiti,activiti-cloud,activiti-cloud-examples ./clone-all.sh

To release:

    PROJECTS=release ./release-all.sh

To include a push first:

    export PUSH=true

To resume a release set the RELEASE_VERSION. The release job that invokes this is in bamboo.

To test cloud versions in the txt file are consistent:
   
   export CHECK_VERSIONS=true
   PROJECTS=activiti-cloud ./remove-all.sh
   PROJECTS=activiti-cloud ./build-all.sh

To test a release, building images locally:

    export BRANCH=<RELEASE_TAG_NAME>
    export MAVEN_ARGS="-Pdocker clean install -DskipTests"
    PROJECTS=release ./remove-all.sh
    PROJECTS=release ./clone-all.sh
    PROJECTS=release ./build-all.sh
