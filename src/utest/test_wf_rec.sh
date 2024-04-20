#!/bin/bash -i

# export PATH=/home/roadelse/recRoot/GitRepos/workFlowRec/bin:$PATH

. wf
date -d "2023/04/01"
date
wf_rec da
if [[ "$(tail -n 1 workflow.md)" == "+ date" ]]; then
    exit 0
else
    exit 1
fi
