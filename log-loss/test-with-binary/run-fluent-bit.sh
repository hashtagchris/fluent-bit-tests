#!/bin/bash

LOG_DIR=_var/log/containers
LOG_PATH=$LOG_DIR/nginx-7c77b568c8-5xj2k_default_nginx-logger-576accb1c93d1eee32bb4a17f876be4f79927f7594f44a38bc55c376e3add7da.log

# LOG_DIR=logs
# LOG_PATH=$LOG_DIR/test.log

function get_file_size() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
}

# Create initial log file with 2KB lines, growing until it exceeds 1 GB
target_size=$((1 * 1024 * 1024 * 1024))

if [ $(get_file_size "test.log") -lt $target_size ]; then
  cp 2kb-logfmt.log test.log

  # keep doubling the file contents until it reaches our target size
  while [ $(get_file_size "test.log") -lt $target_size ]; do
    cp test.log test.log.1
    cat test.log.1 >> test.log
  done
  rm test.log.1

  echo "Generated log file: test.log ($(ls -lh test.log | awk '{print $5}'))" >&2
else
  echo "Using existing log file: test.log ($(ls -lh test.log | awk '{print $5}'))" >&2
fi

rm -rf fb-output
mkdir -p fb-output

rm -rf $LOG_DIR
mkdir -p $LOG_DIR
# spawn a background job to sleep 5 seconds and then copy test.log to the logs directory
# it's possible Fluent Bit treats pre-existing files differently, even when read_from_head is true
(
  sleep 5
  cp test.log $LOG_PATH
  echo -e "\n***Background job***: Added log file to the log directory for fluent bit to process\n"

  # spawn a second background job to delete the test log file 10 seconds later
  ( sleep 10; rm $LOG_PATH; echo -e "\n***Background job***: Removed log file from the log directory to test for abandoned log segments\n" ) &
) &

# Run Fluent Bit
# Warning: Anything written to stdout may be buffered till the end
time fluent-bit -c fluent-bit.yaml 2>&1 | tee fluent-bit.out
