#!/bin/bash

# Create initial log file with 2KB lines, growing until it exceeds 1 GB
target_size=$((1024 * 1024 * 1024))  # 1 GB in bytes

rm -rf test.log
cp 2kb-logfmt.log test.log

# keep doubling the size until it exceeds 1 GB
while [ $(stat -f%z "test.log" 2>/dev/null || stat -c%s "test.log" 2>/dev/null || echo 0) -lt $target_size ]; do
  cat test.log > test.log.1
  cat test.log >> test.log.1

  cat test.log.1 > test.log
  cat test.log.1 >> test.log
done
rm test.log.1

echo "Generated log file: test.log ($(ls -lh test.log | awk '{print $5}'))" >&2

rm -rf fb-output
mkdir -p fb-output

# Run Fluent Bit
time fluent-bit -c fluent-bit.yaml | tee fluent-bit.stdout
