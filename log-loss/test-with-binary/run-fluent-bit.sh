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

# Run Fluent Bit
# Ensure output isn't buffered
time fluent-bit -c fluent-bit.yaml

# Or choose one of these based on fluent-bit's verbosity
# time fluent-bit -c fluent-bit.yaml 2>&1 | tee fluent-bit.out
# time fluent-bit -c fluent-bit.yaml 2>&1 | grep -v '\[static files\] processed' | tee fluent-bit.out
