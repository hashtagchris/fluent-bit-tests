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
