# Antigravity 2.0 — 503 Auto-Retry 패치 설정 가이드

> 503 "Model capacity exhausted" 에러 발생 시 자동으로 Retry 버튼을 클릭하는 패치.
> 원본: https://github.com/hjkkjh-hhh/antigravity2.0-auto-retry

---

## 배경

Antigravity 2.0이 AI 모델 호출 시 서버 용량 부족으로 HTTP 503 에러를 던지는 경우가 있다:

```
Agent terminated due to error
UNAVAILABLE (code 503): No capacity available for model claude-sonnet-4-6
```

이때 수동으로 **Retry** 버튼을 클릭해야 하는데, 이 패치가 자동으로 처리한다.

---

## 동작 원리

- Antigravity UI bundle은 `language_server.exe`(136MB Go 바이너리)에 내장되어 있어 JS 파일 직접 수정이 불가능
- 대신 Electron shell의 `app.asar` → `dist/main.js`에 `web-contents-created` 훅을 주입
- `executeJavaScript()`로 **MutationObserver**를 설치하여 DOM에서 에러 카드를 감지하고 자동 클릭

---

## 커스텀 설정값

| 파라미터 | 기본값 | 우리 설정 | 설명 |
|---|---|---|---|
| `MAX_RETRIES` | 50 | **10000** | 연속 실패 최대 재시도 횟수 |
| `DELAY_MS` | 1500 | **500** | Retry 클릭 전 대기 시간 (ms) |
| `RESET_SEC` | 15 | 15 (유지) | 이 시간 동안 에러 없으면 카운터 리셋 |

---

## 설치 순서

### 전제조건

- Windows 10/11
- Python 3.x
- Node.js (npx @electron/asar 사용)
- Antigravity v2.0.10+

### 1. 레포 클론

```powershell
git clone https://github.com/hjkkjh-hhh/antigravity2.0-auto-retry.git D:\etc\antigravity2.0-auto-retry
```

### 2. 설정값 변경

`D:\etc\antigravity2.0-auto-retry\patch.py` 파일 상단의 Configuration 섹션을 수정:

```python
# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
MAX_RETRIES  = 10000   # Max consecutive auto-retries before giving up
RESET_SEC    = 15      # Seconds of silence before the counter resets
DELAY_MS     = 500     # Milliseconds to wait before clicking Retry
```

### 3. 패치 적용

```powershell
python D:\etc\antigravity2.0-auto-retry\patch.py
```

출력 예시:
```
  antigravity2.0-auto-retry
  ─────────────────────────

  Target: C:\Users\<USER>\AppData\Local\Programs\antigravity\resources\app.asar
  Status: [unpatched] patch not yet applied

  Applying patch ...
  Extracting app.asar ...
  Repacking app.asar ...
  Backing up original → app.asar.bak ...
  Deploying patched app.asar ...
  Done!
```

### 4. Antigravity 재시작

패치 적용 후 반드시 Antigravity를 재시작해야 한다.

---

## 패치 확인 방법

### 방법 1: CLI 확인

```powershell
python D:\etc\antigravity2.0-auto-retry\patch.py --check
```

`[patched] auto-retry injection is active` 출력되면 정상.

### 방법 2: DevTools 콘솔 확인

1. Antigravity 창에서 `Ctrl + Shift + I` (DevTools 열기)
2. Console 탭에서 확인:

```
[AutoRetry] Patch active — max 10000 retries, reset after 15s of silence
```

또는 직접 입력:
```javascript
window.__agAutoRetryInstalled  // true면 정상
```

### 방법 3: 실제 503 발생 시

콘솔에 자동 로그 출력:
```
[AutoRetry] Clicking Retry (attempt 1/10000)
[AutoRetry] Clicking Retry (attempt 2/10000)
```

---

## 로그온 시 자동 재패치 (Antigravity 업데이트 대응)

패치는 `app.asar` 파일을 직접 수정하므로 컴퓨터 재시작으로는 사라지지 않는다.
**단, Antigravity가 업데이트되면** `app.asar`가 새 파일로 교체되어 패치가 날아간다.

이를 자동 처리하기 위해 Windows 로그온 시 자동 실행 태스크를 등록한다.

### VBScript 래퍼 생성

`D:\etc\antigravity2.0-auto-retry\auto_patch.vbs`:

```vbs
' auto_patch.vbs — Silently run patch.py at logon
Set objShell = CreateObject("WScript.Shell")
strDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
strCmd = "python """ & strDir & "\patch.py"""
strLog = strDir & "\auto_patch.log"

Set objExec = objShell.Exec("cmd /c " & strCmd & " > """ & strLog & """ 2>&1")
Do While objExec.Status = 0
    WScript.Sleep 500
Loop
```

### 작업 스케줄러 등록

```powershell
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"D:\etc\antigravity2.0-auto-retry\auto_patch.vbs`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "AntigravityAutoRetryPatch" -Action $action -Trigger $trigger -Settings $settings -Description "Auto-patch Antigravity 503 auto-retry on logon" -RunLevel Highest -Force
```

---

## 롤백 (패치 제거)

```powershell
python D:\etc\antigravity2.0-auto-retry\patch.py --restore
```

백업 파일 `app.asar.bak`에서 원본을 복원한다.

---

## 설정 변경 시 재적용 절차

`patch.py`가 "already patched"를 감지하면 스킵하므로, 설정 변경 시 복원 → 재적용이 필요:

```powershell
# 1. 복원
python D:\etc\antigravity2.0-auto-retry\patch.py --restore

# 2. patch.py 설정값 수정 후 재적용
python D:\etc\antigravity2.0-auto-retry\patch.py

# 3. Antigravity 재시작
```

---

## 주요 파일

| 파일 | 역할 |
|---|---|
| `patch.py` | 핵심 패치 스크립트 (추출 → 주입 → 리패킹) |
| `install.bat` | 더블클릭 설치 래퍼 |
| `uninstall.bat` | 더블클릭 언인스톨 래퍼 |
| `auto_patch.vbs` | 로그온 시 무창 자동 실행용 VBS |

## 패치 대상 경로

```
C:\Users\<USER>\AppData\Local\Programs\antigravity\resources\app.asar
```

백업:
```
C:\Users\<USER>\AppData\Local\Programs\antigravity\resources\app.asar.bak
```
