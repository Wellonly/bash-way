#!/bin/bash
# Comment out a deploy(installation)! All content of the file will be included to deploy(installation).
# To test configure: run: configure-deploy test.sh or configure-remote-deploy test.sh
# To test deploy(installation): run generated: install-....sh
# Prerequisite: specify a list of required functions, files, folders and export it as DEPLOY array;
# - each deploy element may contain a function, file or folder name that were diployed to;
# - .sh files may optionally has a parameters and optionally follow by commands joined by '&&', '||' or ';';
# - folders may optionally has an install.sh file that was auto included as source file to deploy installer;
# - LIB array used for load deployed functions that not loaded yet. Files may have absolute path or relative to devops;
# - you may write any bash code that will be copied directly to installer file of deploy;
# - you may define POST_CMD variable to specify an installation command that will be executed after all;
# - you may define COMMENT_INCLUDE variable to include lines with matched comment content(on default all comment lines excluded);
# - preconfigure() if defined then be called and may use next variables and all the power of bash:
#   - arguments that were passed to configure-deploy();
#   - DEPLOYTODIR variable, it has the target dir of deploy that just created;
#   - INSTALLER variable, it has the installer script that just created with content of the deploy-config and may be also filled by this;
#   - LIBPATH variable, it has the dir from where all relative DEPLOY and LIB files were searched;
export POST_CMD='deploy_test_example.sh && doExample postConfig $@ && echo test successfully done'

export DEPLOY=( 
  'deploy/test/example.sh param1 param2; doExample outsideCall $@'
  deploy/test/example2.sh
  'deploy/test/example-dir dirParam1 dirParam2 && exampleDirInit.sh oneParam twoParam threeParam'
)
export LIB=( 
)

function preconfigure {
  local usage="..usage: ${FUNCNAME[0]} ; : preconfigure function helps compose installation on configure-deploy stage"
  echo "..preconfigure params: $@"
  echo "..preconfigure sources: ${BASH_SOURCE[@]}"
  echo "..preconfigure funcnames: ${FUNCNAME[@]}"
  echo "..preconfigure DEPLOY: ${DEPLOY[@]}"
  echo "..DEPLOYTODIR: $DEPLOYTODIR"
  echo "..INSTALLER: $INSTALLER"
  echo "..LIBPATH: $LIBPATH"
  # next: some preconfigure logic as code...
}
