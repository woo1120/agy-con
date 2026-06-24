# GJC WSL2 Setup — Google Antigravity + Claude

WSL2에서 gajae-code(gjc)를 설정하고, google-antigravity 프로바이더를 통해 추가 API 비용 없이 Claude/Gemini 모델을 사용하는 환경 구성.

## 목표
- Gemini Ultra / ChatGPT Plus 구독으로 gjc에서 Claude + Gemini 모델 사용 (cost=0)
- WSL2 Linux 환경에서 tmux + `$team` 전체 기능 활용
- 대림 기업 프록시 SSL 인증서 문제 해결 포함

## 파일 구조

| 파일 | 용도 |
|---|---|
| `setup-gjc-wsl.sh` | WSL2에서 gajae-code 전체 설치 (패키지→Rust→Bun→클론→빌드) |
| `configure-gjc-env.sh` | bashrc 설정 (Windows PATH 격리, gjc alias) |
| `create-gjc-wrapper.sh` | `/home/gjc/bin/gjc` wrapper 스크립트 생성 |
| `gjc-update.sh` | git pull + rebuild 업데이트 (auto-stash) |
| `setup-tmux-persist.sh` | tmux-resurrect + continuum 설치 (세션 영구화) |
| `post-reboot-wsl-setup.bat` | Windows 재부팅 후 Ubuntu 설치 배치 |
| `daelim-ca.pem` | 대림 기업 프록시 SSL 인증서 |
| `walkthrough.md` | 전체 워크스루 (상세 가이드) |
| `implementation_plan.md` | 구현 계획서 |

## 빠른 시작

### 최초 설치 (재부팅 후)
```powershell
# 1. WSL + Ubuntu 설치 (관리자)
post-reboot-wsl-setup.bat

# 2. Ubuntu에서 설정 실행
wsl -d Ubuntu-24.04
bash /mnt/d/etc/setup-gjc-wsl.sh
bash /mnt/d/etc/configure-gjc-env.sh
bash /mnt/d/etc/create-gjc-wrapper.sh
bash /mnt/d/etc/setup-tmux-persist.sh
```

### 일상 사용
```bash
# WSL 진입 (Windows Terminal 기본 프로필로 설정됨)
wsl -d Ubuntu-24.04

# gjc 실행
gjc --tmux --model google-antigravity/gemini-3-pro-high

# 로그인 (최초 1회)
/login google-antigravity

# Claude 전환
/model claude-sonnet-4-6

# 병렬 작업
$team
```

### 업데이트
```bash
gjc-update    # git pull + bun install + native rebuild
```

## 핵심 발견
- `google-antigravity` 프로바이더: `cost: { input: 0, output: 0 }` (구독 기반)
- Claude 지원: `isClaudeModel()`, `needsClaudeThinkingBetaHeader()` 확인됨
- WSL2 필수: `$team` 스킬 = tmux 필수 (Linux only)
- 기업 프록시: DAELIM-CA 인증서를 WSL CA store에 추가 필요

## 대화 ID
- Antigravity Conversation: `1e8a83d8-da40-487b-b113-1efad54cf019`
