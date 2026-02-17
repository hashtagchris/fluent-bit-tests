# fluent-bit-tests

## Installing Fluent Bit

If you're not using a docker image

```
brew install fluent-bit
```

## Simple Command-line test

https://docs.fluentbit.io/manual/data-pipeline/inputs/dummy#command-line

```
fluent-bit -i dummy -o stdout
```

### Simple test with config file

```
fluent-bit -c ./fluent-bit.yaml
```