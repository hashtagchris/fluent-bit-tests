#!/bin/bash

LOG_DIR=_var/log/containers
LOG_PATH=$LOG_DIR/nginx-7c77b568c8-5xj2k_default_nginx-logger-576accb1c93d1eee32bb4a17f876be4f79927f7594f44a38bc55c376e3add7da.log

rm -rf fb-output
mkdir -p fb-output
ls -la fb-output

rm -rf $LOG_DIR
mkdir -p $LOG_DIR
cp multiline-cri-logfmt.log $LOG_PATH

# Run Fluent Bit
# Warning: Anything written to stdout may be buffered till the end
time fluent-bit -c fluent-bit.yaml 2>&1 | tee fluent-bit.out

ls -la ./fb-output
