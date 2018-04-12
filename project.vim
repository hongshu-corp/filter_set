#! /usr/bin/vim -S
set expandtab
set shiftwidth=2
set tabstop=2

let g:test_all_test=['/bin/bash', '-c', "rspec && cucumber -c"]
let g:test_current_ut=['rspec']
let g:test_current_at=['cucumber', '-c']
let g:test_bdd_features=['cucumber', '-c']
