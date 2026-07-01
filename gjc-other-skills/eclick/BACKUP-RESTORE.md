# PC 도메인 이행 대비 eClick / GJC 백업·복구

Windows 계정이 바뀌면 `C:\Users\기존계정` 아래의 다운로드, 바탕화면, 문서, AppData 기반 설정이 사라지거나 새 프로필로 분리될 수 있습니다. D 드라이브는 유지된다고 했으므로, 복구 기준점은 D 드라이브에 둡니다.

## 1. 이 저장소에 보관되는 것

```text
gjc-other-skills/eclick/
  SKILL.md              # eClick 스킬 본체
  README.md             # 사용법
  eclick.command.md     # /eclick shortcut 원본
  install.sh            # 새 환경에 스킬 설치
  backup-eclick.sh      # 현재 eClick/GJC 관련 상태 백업
  restore-eclick-state.sh
```

## 2. 도메인 이행 전 백업

WSL에서 실행:

```bash
bash /mnt/d/etc/agy-con/gjc-other-skills/eclick/backup-eclick.sh
```

기본 백업 위치:

```text
/mnt/d/etc/eclick-backup/YYYYMMDD-HHMMSS/
```

백업 대상:
- `~/.gjc/agent/skills/eclick/` — 설치된 eClick 스킬
- `~/.gjc/agent/commands/eclick.md` — `/eclick` shortcut
- `~/.gjc/eclick/` — 월별 누적 데이터, entries, sources, rules, Excel 결과
- `~/.gitconfig`
- `~/.ssh/` — GitHub SSH 키가 있을 경우

## 3. 새 계정/새 PC에서 복구

1. GJC/WSL 기본 설치를 먼저 복구합니다. 이 저장소의 `gjc-wsl2-setup/README.md`와 스크립트를 우선 사용합니다.
2. 이 저장소가 D 드라이브에 있는지 확인합니다.
3. eClick 스킬 설치:

```bash
bash /mnt/d/etc/agy-con/gjc-other-skills/eclick/install.sh
```

4. 월별 누적 데이터까지 복구:

```bash
bash /mnt/d/etc/agy-con/gjc-other-skills/eclick/restore-eclick-state.sh /mnt/d/etc/eclick-backup/<백업폴더명>
```

5. GJC를 재시작하고 `/eclick`이 보이는지 확인합니다.

## 4. D 드라이브에 따로 챙길 항목

Windows 프로필에서 사라지기 쉬운 항목은 D 드라이브로 복사합니다.

권장 위치:

```text
D:\etc\pc-migration-backup\
```

체크리스트:
- `C:\Users\기존계정\Downloads` 중 필요한 설치 파일/문서
- `C:\Users\기존계정\Desktop`
- `C:\Users\기존계정\Documents`
- Chrome/Edge 북마크 및 확장 설정
- Windows Terminal 설정
- GitHub/회사 인증서, VPN, 프록시 설정
- SSH 키, PAT, API 키 등 비밀값은 Git에 커밋하지 말고 별도 보관
- `D:\etc\agy-con` 저장소 자체
- `D:\etc\eclick` 기존 작업 파일
- `D:\projects` 작업 프로젝트

## 5. GitHub에 올릴 것과 올리지 말 것

GitHub 저장소에 올릴 것:
- eClick 스킬 본체와 README
- 설치/복구 스크립트
- 일반적인 백업 절차 문서

GitHub에 올리지 말 것:
- `.ssh` 개인키
- API 키, 토큰, 회사 인증 정보
- 실제 월별 eClick 입력 데이터에 민감 정보가 있으면 private 여부 확인 후 결정
- 회사 내부 문서 원문

## 6. 복구 후 확인 명령

```bash
# 스킬 파일 확인
python3 - <<'PY'
from pathlib import Path
for p in [Path.home()/'.gjc/agent/skills/eclick/SKILL.md', Path.home()/'.gjc/agent/commands/eclick.md', Path.home()/'.gjc/eclick']:
    print(p, 'OK' if p.exists() else 'MISSING')
PY
```

GJC 재시작 후:

```text
/eclick 현황
```
