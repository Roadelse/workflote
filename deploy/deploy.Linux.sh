#!/bin/bash

#@ Introduction
###############################################################################
# This scripts aims to deploy the workflote (workflow-note) in system         #
# Support flexible deployment method, inlcuding:                              #
#    ● setenv bash script                                                     #
#    ● modulefile                                                             #
# ----------------------------------------------------------------------------#
#                                                                             #
# 2024-04-18  Roadelse  Mitigated                                             #
###############################################################################

#@ Prepare
#@ .general
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "\033[31mError!\033[0m The script can only be executed rather than be sourced!"
    exit 101
fi
scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && readlink -f .)
workDir=$PWD
cd $scriptDir

#@ .preliminary-functions
function error() {
    echo -e '\033[31m'"Error"'\033[0m' "$1"
    exit 101
}
function success() {
    echo -e '\033[32m'"$1"'\033[0m'
}
function progress() {
    echo -e '\033[33m-- '"($(date '+%Y/%m/%d %H:%M:%S')) ""$1"'\033[0m'
}

#@ <.pre-check>
#@ <..python3>
py_aval=1
if [[ -z $(which python 2>/dev/null) ]]; then
    py_avail=0
else
    pyver=$(python --version | cut -d' ' -f2)
    if [[ $(echo $pyver | cut -d. -f1) != 3 || $(echo $pyver | cut -d. -f2) -lt 6 ]]; then
        py_aval=0
    fi
fi

#@ <.arguments>
#@ <..default>
deploy_mode="setenv" #@ exp | ENUM<setenv, setenv+, module>
profile=
show_help=0
modulepath=
utest=0
verbose=0
binarypath=
#@ <..resolve>
while getopts ":hd:p:m:uvb:" arg; do
    case $arg in
    h)
        show_help=1
        ;;
    u)
        utest=1
        ;;
    d)
        deploy_mode=$OPTARG
        ;;
    p)
        profile=$OPTARG
        ;;
    m)
        modulepath=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    b)
        binarypath=$OPTARG
        ;;
    ?) ;;
    esac
done

#@ .help
if [[ $show_help == 1 ]]; then
    echo "
deploy.Linux.sh [options]

[options]
    ● -h
        show this information
    ● -d deploy_mode
        select deployment target, supporting install, append, setenv, setenv+, module, module+
    ● -p profile
        select profile to be added
    ● -m modulepath
        set modulepath to put generated modulefile
    ● -u
        Do unit test
    ● -v
        Turn on verbose mode
    ● -b binarypath
        set path to link the binaries, will ignore <deploy_mode> if set <binarypath>
"
    exit 0
fi

#@ .python-necessity
if [[ -n $profile && $py_avail == 0 ]]; then
    error "profile argument requires python availability!"
fi

#@ .dependent-variables
VERSION=$(cat $scriptDir/../VERSION)
proj=$(basename $(realpath $scriptDir/..))

#@ Core
if [[ $utest == 0 ]]; then
    if [[ -d "$binarypath" ]]; then
        ln -sf $scriptDir/../src/bin/wf $binarypath
        success "Succeed to link binaries in $binarypath"
        exit 0
    fi

    mkdir -p $scriptDir/export/bin
    ln -sf $scriptDir/../src/bin/wf $scriptDir/export/bin
    text_setenv="# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
export PATH=${scriptDir}/export/bin:\$PATH
alias iwf='source wf'

"

    if [[ $deploy_mode == "setenv" ]]; then
        echo "$text_setenv" >$scriptDir/export/setenv.$proj.sh
        success "Succeed to generate setenv script: $scriptDir/export/setenv.$proj.sh"

        if [[ -n $profile ]]; then
            cat <<EOF >.temp.$proj
# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
source $scriptDir/export/setenv.$proj.sh

EOF
            python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj

            if [[ $? -eq 0 ]]; then
                success "Succeed to add source statements in $profile"
            else
                error "Failed add source statements in $profile"
            fi
            rm -f .temp.$proj
        fi

    elif [[ $deploy_mode == "setenv+" ]]; then
        if [[ -z $profile ]]; then
            error "Must provide profile in setenv+ deploy mode"
        fi
        echo "$text_setenv" >.temp.$proj
        python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj
        if [[ $? -eq 0 ]]; then
            success "Succeed to add setenv statements in $profile"
        else
            error "Failed to add setenv statements in $profile"
        fi
        rm -f .temp.$proj

    elif [[ $deploy_mode =~ "module" ]]; then
        mkdir -p $scriptDir/export/modulefiles/$proj
        cat <<EOF >$scriptDir/export/modulefiles/$proj/default
#%Module1.0

prepend-path PATH $scriptDir/export/bin
set-alias iwf "source wf"

EOF
        success "Succeed to generate modulefile in $scriptDir/export/modulefiles"

        if [[ $deploy_mode == "module" && -n "$profile" ]]; then
            cat <<EOF >.temp.$proj
# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
module use $scriptDir/export/modulefiles

EOF
            python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj
            if [[ $? -eq 0 ]]; then
                success "Succeed to add 'module use' statements in $profile"
            else
                error "Failed to add 'module use' statements in $profile"
            fi
            rm -f .temp.$proj

        elif [[ $deploy_mode == "module+" ]]; then
            if [[ -z "$modulepath" ]]; then
                error "module+ mode required modulepath provided"
            fi
            if [[ ! -d "$modulepath" ]]; then
                error "modulepath must be an existed directory"
            fi
            ln -sfT $scriptDir/export/modulefiles/$proj $modulepath/$proj
            if [[ $? -eq 0 ]]; then
                success "Succeed to put modulefiles into modulepath=$modulepath"
            else
                error "Failed to put modulefiles into modulepath=$modulepath"
            fi
        fi
    else
        error "Unexpected deploy_mode=${deploy_mode}"
    fi

else
    bash deploy.Linux.sh -b $scriptDir/tools
    if [[ $? -ne 0 ]]; then
        error "Failed to depoy ${proj} "
    fi
    rm $scriptDir/tools/wf
fi
