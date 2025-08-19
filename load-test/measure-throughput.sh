#!/bin/sh

# somehow generate-log.sh generates one extra line. oh well.
LINES=5000000
./generate-log.sh $LINES
ls -lh ./sample.log
/usr/bin/time -p docker compose up --abort-on-container-exit --exit-code-from fluent-bit | grep -E 'real|user|sys'
