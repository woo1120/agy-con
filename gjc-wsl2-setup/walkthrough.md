# Gajae-Code WSL2 + Google Antigravity Claude 설정 워크스루

## 목표
Gemini Ultra 구독을 사용하여 WSL2에서 gajae-code(gjc)를 **전체 기능**(tmux, team, worktree 포함)으로 사용하고, **google-antigravity를 통해 Claude 모델에 추가 비용 없이** 접근.

---

## 완료된 작업

### Windows 기반 사전 작업
| 항목 | 상태 | 세부사항 |
|---|---|---|
| bun | ✅ v1.3.14 | npm install -g bun@latest |
| 의존성 | ✅ 408 packages | bun install (166s) |
| VS Build Tools | ✅ 2022 | MSVC link.exe 확보 |
| 네이티브 빌드 | ✅ win32-x64 | bun --cwd=packages/natives run build (9m 26s) |
| gjc CLI | ✅ v0.4.2 | Windows에서 정상 작동 확인 |

### WSL2 환경 준비
| 항목 | 상태 | 세부사항 |
|---|---|---|
| WSL 기능 | ✅ 활성화 | dism.exe Microsoft-Windows-Subsystem-Linux |
| VM 플랫폼 | ✅ 활성화 | dism.exe VirtualMachinePlatform |
| WSL | ✅ v2.7.3 | winget install Microsoft.WSL |
| Ubuntu | ✅ 설치됨 | wsl --install -d Ubuntu |
| 설정 스크립트 | ✅ 작성 | [setup-gjc-wsl.sh](file:///d:/etc/setup-gjc-wsl.sh) |

### 코드 분석 핵심 발견

**google-antigravity + Claude 지원 증거:**
- [google-gemini-cli.ts:L4](file:///d:/etc/gajae-code/packages/ai/src/providers/google-gemini-cli.ts#L4): *"Uses the Cloud Code Assist API endpoint to access Gemini and **Anthropic** model models."*
- [google-gemini-cli.ts:L91-97](file:///d:/etc/gajae-code/packages/ai/src/providers/google-gemini-cli.ts#L91-L97): `isClaudeModel()`, `needsClaudeThinkingBetaHeader()` — Claude thinking/reasoning 지원
- [antigravity.ts:L233-237](file:///d:/etc/gajae-code/packages/ai/src/utils/discovery/antigravity.ts#L233-L237): `cost: { input: 0, output: 0 }` — 구독 기반 무료

**WSL2 필수 이유:**
- [team/SKILL.md:L83-84](file:///d:/etc/gajae-code/packages/coding-agent/src/defaults/gjc/skills/team/SKILL.md#L83-L84): `$team` 스킬 = tmux 필수
- tmux는 Linux 전용 → Windows 네이티브에서는 `$team`, `--tmux` 사용 불가

---

## ⚠️ 재부팅 필요

> [!CAUTION]
> VirtualMachinePlatform을 활성화했으므로 **PC 재부팅이 필수**입니다.
> 재부팅 없이는 WSL2가 작동하지 않습니다.

---

## 재부팅 후 실행 단계

### Step 1: Ubuntu 초기 설정
```powershell
# Windows 터미널에서
wsl
```
첫 실행 시 사용자명/비밀번호 설정 요청이 나옵니다.

### Step 2: 설정 스크립트 실행
```bash
# WSL Ubuntu 안에서
bash /mnt/d/etc/setup-gjc-wsl.sh
```
이 스크립트가 자동으로:
1. 시스템 패키지 설치 (build-essential, tmux, git, curl 등)
2. Rust 설치
3. Bun 설치
4. gajae-code 클론 및 의존성 설치
5. 네이티브 Rust 애드온 빌드 (Linux x64)
6. gjc CLI 동작 확인
7. `gjc` alias 설정

### Step 3: gjc 실행 및 로그인
```bash
source ~/.bashrc

# 기본 실행
gjc --model google-antigravity/gemini-3-pro-high

# 인터랙티브 UI에서 로그인
/login google-antigravity
```
브라우저가 열리면 **Gemini Ultra 구독 Google 계정**으로 로그인.

### Step 4: Claude 모델 사용
로그인 후 Claude가 디스커버리 목록에 나타나면:
```
/model claude-sonnet-4-6
```
또는 `Ctrl+P`로 모델 전환.

### Step 5: tmux + team 전체 기능 사용
```bash
# tmux 세션 시작
tmux new -s gjc

# tmux 안에서 gjc 실행
gjc --tmux --model google-antigravity/gemini-3-pro-high

# team 사용 예시 (인터랙티브 UI에서)
$team
```

---

## 트러블슈팅

### WSL2가 시작되지 않는 경우
```powershell
# 관리자 PowerShell에서
wsl --update
wsl --set-default-version 2
```

### OAuth 브라우저가 WSL에서 열리지 않는 경우
WSL2에서 Windows 브라우저를 자동으로 사용합니다. 만약 열리지 않으면:
```bash
export BROWSER=wslview
# 또는
export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
```

### 네이티브 빌드 실패 시
```bash
# 빌드 의존성 확인
sudo apt-get install build-essential pkg-config libssl-dev
# 재빌드
bun --cwd=packages/natives run build
```
