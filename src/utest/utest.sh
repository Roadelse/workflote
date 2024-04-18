#!/usr/bin/env bats

setup_file() {
    export utestdir=$BATS_TEST_DIRNAME/ade.utest
    export PATH=$BATS_TEST_DIRNAME/../bin:$PATH
    mkdir -p $utestdir
}

teardown_file() {
    rm -rf $utestdir
}

@test "create workflow" {
    cd $utestdir
    which wf
    ret=$(wf)
    [[ "$ret" =~ directories$ ]]
    ret=$(. wf)
    [[ "$ret" =~ directories$ ]]
    wf -i 1
    wf -i 2
    [[ -e workflow.md ]]
    [[ -e .workflow.md ]]
    rm -f .workflow.md
}

@test "location" {
    cd $utestdir
    which wf
    [[ -e workflow.md ]]
    . wf unload
    wf_path=$(wf)
    [[ $wf_path == "$utestdir/workflow.md" ]]
}

@test "wf_exec" {
    cd $utestdir
    which wf
    [[ -e workflow.md ]]
    . wf
    wf_exec ls
    [[ "$(tail -n 1 workflow.md)" == "+ ls" ]]
    . wf unload
}

@test "wf_say" {
    cd $utestdir
    which wf
    [[ -e workflow.md ]]
    . wf
    wf_say hello
    [[ "$(tail -n 1 workflow.md)" == "+ do: hello" ]]
    . wf unload
}

@test "wf_rec" {
    cd $utestdir
    which wf
    [[ -e workflow.md ]]
    $utestdir/../test_wf_rec.sh
}

@test "source: basic" {
    cd $utestdir
    which wf
    [[ -e workflow.md ]]
    . wf
    wf_auto
    wf_info=$(wf)
    [[ "$wf_info" =~ include ]]
    wf_auto on exclude
    wf_info=$(wf)
    [[ "$wf_info" =~ "exclude" ]]
    . wf unload
}
