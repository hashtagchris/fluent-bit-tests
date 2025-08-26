#!/bin/bash

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

rm -rf logs
mkdir -p logs
# spawn a background job to sleep 5 seconds and then copy test.log to the logs directory
# it's possible Fluent Bit treats pre-existing files differently, even when read_from_head is true
(
  sleep 5
  cp test.log logs/
  echo "Background job: Added log file to the logs directory for fluent bit to process"
) &

# Run Fluent Bit
# Warning: Anything written to stdout may be buffered till the end
time fluent-bit -c fluent-bit.yaml 2>&1 | tee fluent-bit.out
