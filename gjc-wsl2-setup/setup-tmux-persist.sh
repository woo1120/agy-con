#!/bin/bash
set -euo pipefail

# 1. Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm /home/gjc/.tmux/plugins/tpm 2>/dev/null || echo "TPM already installed"

# 2. Write tmux.conf
cat > /home/gjc/.tmux.conf << 'TMUXCONF'
# === Gajae-Code tmux config ===

# 세션 자동 저장/복원
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# continuum: 15분마다 자동 저장 + WSL 시작 시 자동 복원
set -g @continuum-save-interval '15'
set -g @continuum-restore 'on'

# resurrect: 패널 내용까지 저장
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-bun 'off'

# 트루컬러 지원
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# 마우스 지원
set -g mouse on

# 히스토리 늘리기
set -g history-limit 50000

# 상태바
set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
set -g status-left '#[fg=#89b4fa,bold] #S '
set -g status-right '#[fg=#a6adc8] %H:%M '

# TPM 초기화 (맨 마지막에 위치해야 함)
run '~/.tmux/plugins/tpm/tpm'
TMUXCONF

# 3. Install plugins
/home/gjc/.tmux/plugins/tpm/bin/install_plugins

echo "TMUX_CONFIGURED"
