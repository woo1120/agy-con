# 크롬 프로필 자동 복원 스크립트

회사 보안정책으로 매일 아침 크롬이 **"일시중지됨"** 상태로 초기화되는 문제를 해결합니다.

## 원리

1. 퇴근 전 크롬 프로필(`Default` 폴더 + `Local State`)을 통째로 백업
2. 보안 프로그램이 밤사이 쿠키/로그인 데이터를 삭제
3. 출근 시 백업에서 복원 → 크롬 정상 로그인 상태 유지

## 파일 구성

| 파일 | 용도 |
|------|------|
| `chrome_backup.bat` | 수동 백업 (대화형) |
| `chrome_restore.bat` | 수동 복원 (대화형) |
| `chrome_backup_silent.bat` | 작업 스케줄러용 백업 (무인) |
| `chrome_restore_silent.bat` | 작업 스케줄러용 복원 (무인) |
| `test_simulate_reset.bat` | 보안 초기화 시뮬레이션 (테스트용) |

## 설치 방법

### 1. 원하는 위치에 폴더 복사

```
예: C:\Users\{사용자명}\Downloads\restoreChrome\
```

### 2. 최초 테스트

1. 크롬에 로그인하여 정상 동기화 상태 확인
2. `chrome_backup.bat` 실행 → 정상 상태 백업
3. `test_simulate_reset.bat` 실행 → "일시중지됨" 상태 재현
4. 크롬 열어서 "일시중지됨" 확인 후 크롬 닫기
5. `chrome_restore.bat` 실행 → 복원
6. 크롬 열어서 정상 복원 확인

### 3. 작업 스케줄러 등록 (자동화)

> **⚠️ 중요**: 복원은 고정 시간(예: 8:15)이 아닌 **로그온 후 지연 실행**으로 등록해야 합니다.
> 보안 프로그램이 로그인 시점에 실행되므로, 고정 시간 복원은 보안 프로그램에 의해 다시 삭제될 수 있습니다.

PowerShell에서 아래 명령어 실행 (경로를 본인 환경에 맞게 수정):

```powershell
# 평일 오후 5:30 백업
schtasks /Create /TN "ChromeProfileBackup" /TR 'cmd /c "C:\Users\{사용자명}\Downloads\restoreChrome\chrome_backup_silent.bat"' /SC WEEKLY /D MON,TUE,WED,THU,FRI /ST 17:30 /F

# 로그온 후 10분 지연 복원 (보안 프로그램 완료 후 실행)
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument '/c "C:\Users\{사용자명}\Downloads\restoreChrome\chrome_restore_silent.bat"'
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$trigger.Delay = "PT10M"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "ChromeProfileRestore" -Action $action -Trigger $trigger -Settings $settings -Force
```

> 10분이 부족하면 `PT10M`을 `PT15M`(15분) 또는 `PT20M`(20분)으로 변경하세요.

## 백업 위치

스크립트와 같은 폴더 아래 `backup/` 디렉토리에 저장됩니다:

```
restoreChrome/
├── backup/
│   ├── Default/          ← 크롬 Default 프로필 전체
│   └── Local State       ← 크롬 전역 설정
├── backup_log.txt        ← 자동 백업 로그 (스케줄러용)
├── restore_log.txt       ← 자동 복원 로그 (스케줄러용)
└── *.bat                 ← 스크립트들
```

## 주의사항

- 스크립트 실행 시 **크롬이 자동으로 종료**됩니다
- 최초 1회는 반드시 **정상 로그인 상태**에서 백업을 만드세요
- 백업 데이터에는 로그인 쿠키가 포함되므로 **타인과 공유하지 마세요**
- `.gitignore`에 `backup/`과 `*_log.txt`가 포함되어 있어 백업 데이터는 Git에 올라가지 않습니다

## 스케줄러 제거

```cmd
schtasks /Delete /TN "ChromeProfileBackup" /F
schtasks /Delete /TN "ChromeProfileRestore" /F
```
