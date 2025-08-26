# test-from-binary
This tests for log loss due to insufficient throughput by executing a Fluent Bit binary directly. No Docker, no kubernetes.

## Installing Fluent Bit
### macOS

To install the current version, use `brew install fluent-bit`

#### Older versions

Version | Formula
-|-
3.2.2 | https://raw.githubusercontent.com/Homebrew/homebrew-core/84e22a71ecb93818719df6ccf951d7e697c57878/Formula/f/fluent-bit.rb

```
# Create a custom tap
brew tap-new <username>/fluent-bit-old

# Download the old formula
curl -o /opt/homebrew/Library/Taps/<username>/homebrew-fluent-bit-old/Formula/fluent-bit.rb \
  "https://raw.githubusercontent.com/Homebrew/homebrew-core/84e22a71ecb93818719df6ccf951d7e697c57878/Formula/f/fluent-bit.rb"

# Uninstall current version if needed
brew uninstall fluent-bit

# Install the old version
brew install <username>/fluent-bit-old/fluent-bit

fluent-bit --version
```

### Ubuntu

Start by following https://docs.fluentbit.io/manual/installation/linux/ubuntu

When you get to the "Install Fluent Bit" section:

```
sudo apt-get install fluent-bit=3.2.2
sudo ln -s /opt/fluent-bit/bin/fluent-bit /usr/local/bin/fluent-bit

fluent-bit --version
```

### Debug log comparison

Fluent Bit v3.2.2 gracefully exiting after reading the full log file:
```
[2025/08/26 11:46:47] [ info] [input:tail:tail.0] inode=94076514 file=logs/test.log ended, stop
[2025/08/26 11:46:47] [debug] [input:tail:tail.0] inode=94076514 file=logs/test.log promote to TAIL_EVENT
[2025/08/26 11:46:47] [debug] [input:tail:tail.0] [static files] processed 0b, done
[2025/08/26 11:46:47] [ info] [input] pausing tail.0
[2025/08/26 11:46:48] [ info] [input] pausing tail.0
[2025/08/26 11:46:48] [debug] [input:tail:tail.0] inode=94076514 removing file name logs/test.log
```

Fluent Bit v3.2.2 detecting the log file its processing has been deleted:
```
[2025/08/26 11:42:04] [debug] [input:tail:tail.0] [static files] processed 31.7K
[2025/08/26 11:42:04] [debug] [input:tail:tail.0] purge: monitored file has been deleted: logs/test.log
[2025/08/26 11:42:04] [debug] [input:tail:tail.0] inode=94076131 removing file name logs/test.log
[2025/08/26 11:42:04] [debug] [input:tail:tail.0] [static files] processed 0b, done
...
[2025/08/26 11:42:05] [debug] [input:tail:tail.0] scanning path logs/*.log
[2025/08/26 11:42:05] [debug] [input:tail:tail.0] cannot read info from: logs/*.log
[2025/08/26 11:42:05] [debug] [input:tail:tail.0] 0 new files found on path 'logs/*.log'
[2025/08/26 11:42:07] [debug] [input:tail:tail.0] scanning path logs/*.log
[2025/08/26 11:42:07] [debug] [input:tail:tail.0] cannot read info from: logs/*.log
[2025/08/26 11:42:07] [debug] [input:tail:tail.0] 0 new files found on path 'logs/*.log'
...
```
