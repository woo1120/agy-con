# 구독 기반 LLM 사용: ChatGPT Plus + Gemini Ultra로 gajae-code 사용하기

## 배경

사용자는 추가 API 비용 없이 기존 구독(ChatGPT Plus, Gemini Ultra)만으로 gajae-code를 사용하고 싶다.
API 키 방식이 아닌 **OAuth 인증**으로만 가능한 상황이다.

## 소스 코드 분석 결과

> [!IMPORTANT]
> **gajae-code는 이미 두 구독 모두를 지원하는 프로바이더를 내장하고 있다.** 코드 수정이 아닌 **설정과 로그인**만 하면 된다.

### 경로 1: ChatGPT Plus → `openai-codex` 프로바이더

소스 코드 증거:
- [openai-codex.ts](file:///d:/etc/gajae-code/packages/ai/src/utils/oauth/openai-codex.ts) — **ChatGPT OAuth 플로우** (`auth.openai.com/oauth/authorize`)
- JWT에서 `chatgpt_account_id`를 추출 (라인 28-51)
- [openai-codex-responses.ts](file:///d:/etc/gajae-code/packages/ai/src/providers/openai-codex-responses.ts) — 엔드포인트: `chatgpt.com/backend-api` (라인 194)
- [openai-codex usage](file:///d:/etc/gajae-code/packages/ai/src/usage/openai-codex.ts) — `plan_type` 필드로 구독 플랜 확인 (라인 160), `used_percent` 기반 사용량 추적

**작동 원리:**
1. `/login openai-codex` → 브라우저에서 ChatGPT 로그인
2. OAuth 콜백으로 `access_token` + `refresh_token` 수신
3. JWT에서 `chatgpt_account_id` 추출
4. `chatgpt.com/backend-api`로 Responses API 호출
5. ChatGPT Plus 구독 한도 내에서 **무료 사용**

**사용 가능 모델:** GPT-5.3 (openai-code), GPT-5.5, GPT-4.1, o3, o4-mini 등 (ChatGPT Plus 구독에 포함된 모든 모델)

### 경로 2: Gemini Ultra → `google-gemini-cli` 프로바이더

소스 코드 증거:
- [google-gemini-cli.ts (OAuth)](file:///d:/etc/gajae-code/packages/ai/src/utils/oauth/google-gemini-cli.ts) — Google OAuth (`accounts.google.com`)
- `TIER_FREE = "free-tier"` 상수 (라인 41) — 무료 티어 프로비저닝 지원
- Cloud Code Assist 엔드포인트: `cloudcode-pa.googleapis.com` (라인 25)
- [google-gemini-cli.ts (Provider)](file:///d:/etc/gajae-code/packages/ai/src/providers/google-gemini-cli.ts) — Cloud Code Assist API 스트리밍

**작동 원리:**
1. `/login google-gemini-cli` → 브라우저에서 Google 계정 로그인
2. `cloud-platform` 스코프 OAuth 토큰 수신
3. `loadCodeAssist` API로 프로젝트 자동 프로비저닝
4. `free-tier` 또는 구독 티어로 Gemini 모델 접근
5. Gemini Ultra 구독 한도 내에서 **무료 사용**

**사용 가능 모델:** Gemini 2.5 Pro, Gemini 2.5 Flash, Gemini 3 Pro, Gemini 3 Flash 등

### 경로 3: Gemini Ultra → `google-antigravity` 프로바이더 (추가 모델)

소스 코드 증거:
- [google-antigravity.ts](file:///d:/etc/gajae-code/packages/ai/src/utils/oauth/google-antigravity.ts) — 별도 OAuth 크레덴셜 (라인 1-4)
- `ideType: "ANTIGRAVITY"` 메타데이터 (라인 45-49)
- [google-gemini-cli.ts (Provider)](file:///d:/etc/gajae-code/packages/ai/src/providers/google-gemini-cli.ts#L91-L102) — Claude, GPT 모델도 Google 경유 제공

**추가 모델:** Gemini 3 시리즈 + **Claude** (Anthropic) + **GPT-OSS** (OpenAI) — Google Cloud 경유

---

## 구현 계획

> [!IMPORTANT]
> **코드 수정은 불필요하다.** gajae-code를 빌드하고 로그인만 하면 된다.

### Phase 1: gajae-code 빌드

```bash
cd d:\etc\gajae-code
bun install
bun run build          # 또는 bun --cwd=packages/coding-agent run build
```

### Phase 2: ChatGPT Plus 연결 (OpenAI Codex)

```bash
gjc /login openai-codex
# → 브라우저에서 ChatGPT 계정 로그인
# → OAuth 콜백 (localhost:1455/auth/callback)
# → access_token + refresh_token 저장됨
```

또는 device-code 플로우 (포트 문제 시):
```bash
gjc /login openai-codex --device
# → 브라우저에서 https://auth.openai.com/codex/device 접속
# → 코드 입력
```

로그인 후:
```bash
gjc --model openai-codex/gpt-5.3-openai-code
```

### Phase 3: Gemini Ultra 연결

```bash
gjc /login google-gemini-cli
# → 브라우저에서 Google 계정 로그인
# → Cloud Code Assist 프로젝트 자동 프로비저닝
# → OAuth 토큰 저장됨
```

로그인 후:
```bash
gjc --model google-gemini-cli/gemini-2.5-pro
```

### Phase 4: 기본 모델 설정 (선택)

`~/.gjc/agent/models.yml`에 모델 바인딩 설정:

```yaml
modelBindings:
  modelRoles:
    default: openai-codex/gpt-5.3-openai-code:high
    # 또는: google-gemini-cli/gemini-2.5-pro:high
  agentModelOverrides:
    executor: openai-codex/gpt-5.3-openai-code:high
    architect: google-gemini-cli/gemini-2.5-pro:high
    planner: google-gemini-cli/gemini-2.5-pro:high
    critic: google-gemini-cli/gemini-2.5-pro:high
```

이렇게 하면 ChatGPT Plus로 코드 작성, Gemini Ultra로 리뷰/계획을 분산 사용.

---

## Open Questions

> [!WARNING]
> **빌드 환경 확인 필요:** `bun`이 설치되어 있는지, 그리고 Windows에서 Rust 네이티브 크레이트 빌드가 가능한지 확인 필요. `bun install`이 실패하면 pre-built 바이너리가 있는지 확인해야 한다.

> [!IMPORTANT]
> **사용량 한도 주의:** ChatGPT Plus는 시간당/주당 사용량 한도가 있다. `openai-codex` 프로바이더는 `used_percent` 기반 사용량 추적을 내장하고 있으므로 한도 초과 시 자동 경고가 뜬다. Gemini Ultra도 유사한 한도가 있을 수 있다.

1. **bun이 이미 설치되어 있는가?** 아니면 설치부터 해야 하는가?
2. **두 구독 모두 활용하고 싶은가, 아니면 하나만?** (둘 다 설정 가능하고, 역할별 분산 사용 가능)
3. **gjc CLI를 직접 빌드해서 쓸 것인가, 아니면 npm/bun 글로벌 설치를 원하는가?**

## Verification Plan

### 자동 테스트
```bash
# 빌드 확인
bun run check:ts

# 로그인 확인 (대화형)
gjc /login openai-codex
gjc /login google-gemini-cli

# 모델 목록 확인
gjc --list-models
```

### 수동 검증
- `/login` 후 `gjc` 실행하여 구독 기반 모델로 대화 테스트
- 사용량 추적 확인 (`/usage` 또는 stats 대시보드)
