# Fluent Bit Tail Plugin Load Test

This directory contains a minimal load test harness for Fluent Bit's `tail` input plugin using the official `fluent/fluent-bit` Docker image and the `exit_on_eof` option. When Fluent Bit reaches end-of-file (EOF) on the specified log file, it will flush remaining buffers and exit—useful for batch / one‑shot benchmarking.

## Contents

- `docker-compose.yml` – Runs Fluent Bit with the provided config.
- `fluent-bit.conf` – Configures a single `tail` input and `stdout` output; `exit_on_eof true` makes the process quit after ingesting the file.
- `sample.log` – Small example log file (you can replace or overwrite for bigger tests).
- `generate-log.sh` – Helper script to create a large synthetic log file (optional).

## How it works

`fluent-bit.conf` snippet (tail input):
```
[INPUT]
    Name         tail
    Path         /var/log/sample.log
    Tag          test.log
    exit_on_eof  true
```
`exit_on_eof` causes Fluent Bit to terminate (cleanly) once the tail plugin reaches the end of the file (and no new data arrives within its internal checks). This enables deterministic, repeatable runs: start → fully process file → exit.

## Run a basic test

```bash
cd load-test
# View or replace sample.log if desired
docker compose up --remove-orphans --abort-on-container-exit --exit-code-from fluent-bit
```
The container will emit parsed records to stdout and then exit. Use the `--abort-on-container-exit` and `--exit-code-from` flags to make Compose stop once Fluent Bit finishes.

## Generate a larger log file

Use the helper script (fast, uses `seq`):
```bash
cd load-test
chmod +x generate-log.sh   # first time only
./generate-log.sh 500000   # generates 500k lines into sample.log
```
Or ad‑hoc without the script:
```bash
seq 1 1000000 | sed 's/^/2025-08-18 12:00:00 INFO load-test line /' > sample.log
```
Then rerun Fluent Bit:
```bash
docker compose up --abort-on-container-exit --exit-code-from fluent-bit
```

## Re-running considerations

- The current config does NOT persist offsets (no filesystem state volume), so every run rereads the whole file—ideal for batch tests.
- If you modify `sample.log` while Fluent Bit is running, it will continue ingesting appended lines until EOF, then exit.
- To test different file sizes or line patterns, just overwrite `sample.log` before starting a new run.

## Tweaks & ideas

| Goal | Change |
|------|--------|
| Increase ingestion speed | Remove `Flush 1` or set smaller flush if output plugin supports it (stdout just prints). |
| Emulate JSON logs | Replace generated lines with JSON objects. |
| Multiple files | Add more `[INPUT]` sections with different `Path` patterns. |
| Persistent offsets | Mount a writable directory and set `DB` & `DB.sync`. Disable `exit_on_eof` if you want long-lived. |
| Throughput timing | Wrap `docker compose up` in `time` or parse timestamps. |

## Measuring throughput (simple)

```bash
LINES=500000
./generate-log.sh $LINES
/usr/bin/time -p docker compose up --abort-on-container-exit --exit-code-from fluent-bit | grep -E 'real|user|sys'
```
Count lines processed:
```bash
wc -l sample.log
```
Because there is one output line per input line (stdout), elapsed time roughly approximates end-to-end handling cost.

## Cleaning up

```bash
docker compose down -v
```
Removes the container; no persistent state is kept.

## Next steps (optional enhancements)

- Add a JSON output plugin (e.g., forward to local TCP) for more realistic pipeline tests.
- Parameterize path and tag via environment variables (`env` + `${VAR}` substitution in config requires a small wrapper entrypoint or templating step).
- Capture container stats (`docker stats`) to profile CPU / memory under larger loads.

Feel free to request any of these enhancements and they can be added quickly.
