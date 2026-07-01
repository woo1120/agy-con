---
name: eclick
description: eClick monthly worklog planning, daily accumulation, AX/케미칼 M/H distribution, link analysis, and Excel generation.
---

# eClick Monthly Worklog Skill

Use when the user asks for `eclick`, `gjc-eclick`, monthly eClick worklog planning, daily worklog accumulation, M/H distribution, AX/케미칼 split tracking, or eClick Excel generation.

## Purpose

`eclick` is a persistent monthly worklog assistant. It creates and maintains eClick-ready monthly work records incrementally, so the user can report daily work casually and still finish the month with a validated Excel workbook.

It must:
- Create a monthly schedule from year/month, ratio, holidays, 연차, and 반차.
- Persist state globally under `~/.gjc/eclick/YYYY-MM/`.
- Accumulate daily work entries across sessions.
- Track target vs allocated hours for AX and 케미칼.
- Keep each day within the planned hours and at most 3 tickets.
- Analyze links/files/images/documents when the user provides evidence.
- Generate a one-sheet Excel workbook with internal hyperlinks from titles to processing details.
- Grow over time by preserving user corrections as durable rules.

## Persistent Storage

Never rely on conversation memory. Always load state from disk first.

```text
~/.gjc/eclick/YYYY-MM/
  schedule.json        # calendar, ratio, target hours, exceptions
  entries.jsonl        # append-only entry/correction/delete events
  sources.jsonl        # cached summaries of URLs/files/images/docs
  rules.json           # month-specific learned aliases/rules
  eclick_YYYY_MM.xlsx  # generated workbook
```

`entries.jsonl` is the durable database. Replay it to build the effective current state.

## Category Rules

Default categories:
- `AX`: actual work by default.
- `케미칼`: allocation bucket used when the monthly 0.25 M/M needs to be filled.

Important rule:
> Future work is usually all AX work. If 케미칼 M/M exists, allocate the required portion as support-style titles related to the AX work.

Examples:
- AX: `토목현장 HOME 팔란티어 업무`
- 케미칼: `토목현장 HOME 팔란티어 업무 지원`
- AX: `팔란티어 교육자료 제작 참여`
- 케미칼: `팔란티어 교육자료 제작 지원`

SNOP note:
- `전사 SNOP` was a June-specific workstream. Do not assume SNOP for future months unless the user explicitly says SNOP work happened.

## Calendar Rules

For a new month:
1. Generate all dates from the 1st through month end.
2. Saturday/Sunday are automatic 0h 휴일.
3. User-provided 휴일/연휴 are 0h.
4. 연차 is recordable 8h.
5. 오전반차/오후반차 is total 8h = 4h work + 4h leave.
6. Normal workday is 8h.
7. Default ratio is AX 0.75 / 케미칼 0.25 unless user says otherwise.
8. Round targets to practical whole-hour totals while preserving exact monthly total.

## Constraints

- Day total should match planned day hours.
- Maximum 3 tickets per day.
- Titles must be short and representative.
- Details belong in the 처리내용 section, not the title.
- Business-facing language is preferred for 처리내용.
- Do not call a row `혼합`; each row is either AX or 케미칼.

## Workflow

### Start Month

Example:

```text
/skill:eclick 2026년 7월 시작.
비중 AX 0.75, 케미칼 0.25.
연차 7/14, 7/15.
오전반차 7/23.
공휴일 없음.
매주 금요일 데이터파트 주간회의 1h.
```

Behavior:
- Create `~/.gjc/eclick/2026-07/`.
- Write `schedule.json`.
- Initialize empty `entries.jsonl` and `sources.jsonl` if absent.
- Generate initial workbook.
- Report total/AX/케미칼 target hours and remaining hours.

### Add Work

Example:

```text
/skill:eclick 7/8 오늘 한 일:
토목현장 HOME 관련 문서 확인했고, 아래 링크 참고했어.
https://example.com/doc
```

Behavior:
1. Load schedule and replay entries.
2. Read/analyze links/files/images/docs using `read` first.
3. Summarize evidence into business-readable 처리내용.
4. Convert rough prose into 1-3 tickets.
5. Assign M/H while respecting the day plan.
6. Assign AX by default; use 케미칼 only when needed for the monthly allocation.
7. Append events to `entries.jsonl`.
8. Regenerate workbook.
9. Report cumulative status.

### Status

Example:

```text
/skill:eclick 현황
```

Show:

```text
YYYY-MM eClick 현황
AX:       allocated / target h
케미칼:   allocated / target h
전체:     allocated / target h
남은 근무일:
남은 시간:
필요 AX:
필요 케미칼:
상태: 정상 | 주의 | 초과 | 부족
```

Warn about:
- Not enough remaining workdays.
- Too much 케미칼 remaining late in month.
- Day over/under planned hours.
- More than 3 tickets in a day.
- Missing 처리내용.

### Rebalance

Example:

```text
/skill:eclick 7월 리밸런싱해줘
```

Behavior:
- Preserve real work facts.
- Adjust M/H/category/support-style naming only when safe.
- Keep day totals and 3-ticket limit.
- Keep monthly AX/케미칼 targets exact.
- Report before/after changes.

### Modify / Undo

Examples:

```text
/skill:eclick 7/8 두 번째 항목 제목을 "토목현장 HOME 업무 분석"으로 바꿔줘
/skill:eclick 마지막 입력 취소
```

Append correction events to `entries.jsonl`; do not silently erase history.

### Close Month

Example:

```text
/skill:eclick 7월 마감
```

Validate:
- Total target equals allocated.
- AX target equals AX allocated.
- 케미칼 target equals 케미칼 allocated.
- Every recordable day is filled correctly.
- 0h days have no entries unless explicitly allowed.
- Max 3 tickets/day.
- Every title has 처리내용.

Then generate final workbook and report the path.

## Evidence Analysis

When input includes URLs, file paths, images, PDFs, Excel files, or docs:
- Use `read` for URLs/files/images/docs.
- Use `web_search` only when current public web context is necessary or `read` is insufficient.
- Cache concise source summaries in `sources.jsonl`.
- Use source facts to write 처리내용.
- Do not paste raw long source content into entries.

## Excel Workbook

Output:

```text
~/.gjc/eclick/YYYY-MM/eclick_YYYY_MM.xlsx
```

Default: one primary sheet.

Top section columns:

```text
No | 날짜 | 요일 | 제목 | M/H | 구분 | 목표(h) | 할당(h) | 비고
```

Bottom section:
- `처리내용 상세`
- One detail block per title.
- Same-sheet hyperlinks:
  - Title cell in top list links to detail block.
  - Detail title links back to first matching list row.

Formatting:
- Freeze header.
- AX: white/default.
- 케미칼: light blue.
- 연차: light yellow.
- 반차: light green.
- Show daily target/allocated on first row of each date.
- Add validation summary below the table.

## Business Wording Guidance

Avoid overly developer-like wording in visible 처리내용. Translate implementation into business outcomes.

Developer-like:

```text
plan_parser_v2.py, generate_fact_plan_v2.py, DuckDB export, validation scripts
```

Business-facing:

```text
- 전사 S&OP 경영계획 데이터 정리 및 표준화
- 사업부별 계획/전망/실적 데이터 통합 기준 검토
- 계정별 집계 기준 및 데이터 정합성 확인
- 리포트 연계를 위한 기준 데이터 구조 정리
```

## Suggested Event Shapes

```json
{"type":"entry_added","date":"2026-07-01","title":"AX크루 교육","mh":2,"category":"AX","detail_key":"AX크루 교육","source_refs":[],"created_at":"..."}
{"type":"entry_modified","target":{"date":"2026-07-01","title":"AX크루 교육"},"patch":{"mh":3},"reason":"user correction","created_at":"..."}
{"type":"entry_deleted","target":{"date":"2026-07-01","title":"AX크루 교육"},"reason":"user undo","created_at":"..."}
```

## Verification

Before saying work is complete:
- Confirm storage files exist.
- Confirm workbook was written.
- Load workbook with `openpyxl.load_workbook`.
- Validate monthly totals and day constraints.

## Upgrade Discipline

When the user corrects a rule, update durable guidance in this skill/README or the month `rules.json`.

Known durable rules:
- 하루 최대 티켓은 3개.
- 구분은 AX/케미칼만 사용하고 혼합은 쓰지 않는다.
- 케미칼은 실제 별도 업무라기보다 0.25 M/M 배분용 지원 표기다.
- 처리내용은 같은 시트 아래에 두고 제목에서 내부 링크로 이동한다.
