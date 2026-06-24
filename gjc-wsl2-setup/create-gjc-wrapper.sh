#!/bin/bash
set -euo pipefail

# Create gjc wrapper script
mkdir -p /home/gjc/bin

cat > /home/gjc/bin/gjc << 'WRAPPER'
#!/bin/bash
export PATH="/home/gjc/.bun/bin:/home/gjc/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec bun /home/gjc/gajae-code/packages/coding-agent/src/cli.ts "$@"
WRAPPER

chmod +x /home/gjc/bin/gjc

# Add ~/bin to PATH in .bashrc.gjc
sed -i 's|export PATH="|export PATH="/home/gjc/bin:|' /home/gjc/.bashrc.gjc

# Test
echo "Testing gjc wrapper..."
/home/gjc/bin/gjc --version

echo "Testing tmux..."
tmux -V

echo "WRAPPER_OK"
