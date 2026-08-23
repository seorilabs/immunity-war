# 경제 콘텐츠 라이브옵스

- 제품명: 면역 전쟁 (Immunity War)
- 문서 상태: draft
- 소유자: ih@toss.im
- 버전/수정일: v0.1 / 2026-08-23
- Source of truth: 재화 공식, 보상·비용 canonical 수치, 콘텐츠 재고·생산 예산, 광고 카탈로그
- Depends on: 02-gdd v0.1
- Open blockers: 없음 (수치는 economy_sim으로 조정하며 본 문서가 canonical)
- 승인 근거: 사용자 승인 전

## 재화 Source와 Sink

단일 소프트 재화: 사이토카인. 유료 재화 없음.

| Currency | Source ID | 양/공식 | 주기/cap | Sink ID | 비용/공식 | unlock | telemetry |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 사이토카인 | SRC-CLEAR 스테이지 반복 클리어 | base(i) = 18 + 6 x i (i = 전역 스테이지 순번 1~28) | 제한 없음 | SNK-LEVEL 세포 레벨업 | cost(lv) = floor(40 x 1.6^(lv-1)), lv 1→10 | 세포 보유 시 | earn_virtual_currency / spend_virtual_currency |
| 사이토카인 | SRC-FIRST 첫 클리어 보너스 | base(i) x 3 (반복 보상 대체, 중복 없음) | 스테이지당 1회 | 동일 | 동일 | 동일 | 동일 |
| 사이토카인 | SRC-BOSS 보스 첫 클리어 | base(i) x 5 | 보스당 1회 | 동일 | 동일 | 동일 | 동일 |
| 사이토카인 | SRC-AD 보상 2배 광고 | 해당 판 획득량 x 1 추가 | 판당 1회 | 동일 | 동일 | 첫 클리어 이후 | ad_reward_claimed |

## 밸런스 모델

```text
클리어 보상   base(i) = 18 + 6 x i                 (i: 전역 스테이지 순번, 1-1=1, 3-10=28)
첫 클리어     first(i) = base(i) x 3               (보스 스테이지는 x5)
반복 클리어   repeat(i) = base(i)                  (첫 클리어의 1/3)
레벨업 비용   cost(lv) = floor(40 x 1.6^(lv-1))    (lv→lv+1, 최대 lv 10)
누적 비용     total(1→10) = sum = 4479
스탯 배율     level_mult(lv) = 1 + 0.12 x (lv - 1) (HP·공격력 공통, 02 문서 CON-006)
반올림        지급·비용 모두 floor, 표시 동일
```

| Vector ID | 입력 | 기대 출력 | 오차/rounding | test |
| --- | --- | --- | --- | --- |
| VEC-001 | base(1) | 24 | 정수 | economy_sim 단위 검증 |
| VEC-002 | first(8) 보스 1-8 | (18+48) x 5 = 330 | 정수 | 동일 |
| VEC-003 | cost(1) | 40 | floor | 동일 |
| VEC-004 | cost(5) | floor(40 x 6.5536) = 262 | floor | 동일 |
| VEC-005 | cost 합 lv1→10 | 4479 | floor 누적 | 동일 |
| VEC-006 | level_mult(10) | 2.08 | 소수 유지 | CombatRules vector |

## 보상 일정

| Time/Trigger | Reward | 목적 | next goal | 반복/중복 | paid interaction |
| --- | --- | --- | --- | --- | --- |
| 스테이지 클리어 | repeat(i) 사이토카인 | 기본 수급 | 다음 스테이지 | 무제한 반복 | 보상 2배 광고 제안 |
| 첫 클리어 | first(i) + 학습 카드 (지정 스테이지) | 진행 보상 집중 | 다음 노드 | 1회 | 동일 |
| 챕터 보스 격파 | base x5 + 세포 해금 | 챕터 마일스톤 | 새 덱 실험 | 1회 | 동일 |
| 스테이지 2-5, 3-5 | 세포 해금 (보체, 헬퍼T) | 중간 리텐션 훅 | 시너지 완성 | 1회 | 없음 |

- 일일 보상·출석은 출시 범위 제외 (오프라인 단순성 유지, Evidence Gate에서 재검토).

## 콘텐츠 재고

| Content ID/type | launch qty | difficulty/tier | prerequisite | production owner | QA cost | localization | reuse |
| --- | ---: | --- | --- | --- | ---: | --- | --- |
| 스테이지 (일반) | 25 | 챕터 내 상승 곡선, 웨이브 3~5 | WaveDef 데이터 | 기획+에이전트 | 스테이지당 시뮬 1회+실플레이 표본 | 한국어만 | WaveDef 조합 재사용 |
| 보스 스테이지 | 3 | 챕터 말 피크 | 보스 씬 | 동일 | 실플레이 필수 | 한국어만 | 보스 1종+파라미터 변형 |
| 세포 | 8종 x 10lv | 메타 | CellDef+스프라이트 5애니 | 기획+아트 | 상성 시뮬 | 한국어만 | 스킬 kind 8종 재사용 |
| 적 | 6종 | 챕터별 등장 | EnemyDef+스프라이트 | 동일 | 시뮬 | 한국어만 | 태그 조합 |
| 강화 카드 | 12종 (common 8, rare 4) | 런 내 | UpgradeDef+아이콘 | 기획 | 시뮬 | 한국어만 | effect_kind 재사용 |
| 시너지 | 4종 | 덱 조건 | SynergyDef | 기획 | 시뮬 | 한국어만 | 태그 카운트 재사용 |
| 학습 카드 | 11장 | 없음 | 카피+일러스트 | 기획+아트+검수 | 카피 검수 | 한국어만 | 없음 |

## 콘텐츠 생산 예산

| 단위 | 기획 h | 아트 h/API cost | 구현 h | 카피/번역 | QA h | 월 생산량 | bottleneck |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 스테이지 1개 | 0.5 | 0 (기존 배경 재사용) | 0.3 (데이터만) | 0.1 | 0.3 | 40+ | 밸런스 시뮬 검토 |
| 신규 적 1종 | 1 | 생성 API 5애니 배치 | 2 | 0.2 | 1 | 4 | 아트 QA |
| 신규 세포 1종 | 2 | 동일 | 3 (스킬 포함) | 0.3 | 2 | 3 | 스킬 구현 |
| 신규 챕터 (배경+10스테이지+적1) | 8 | 배경 3레이어+적 배치 | 6 | 1 | 4 | 1 | 아트 앵커 일관성 |
| 학습 카드 1장 | 0.5 | 일러스트 1장 | 0.1 | 0.5 (검수 포함) | 0.2 | 10+ | 생물학 표현 검수 |

- 출시 후 콘텐츠 계획(챕터4)은 월 1챕터 생산량 안에서 실행 가능 — 캘린더가 생산량을 초과하지 않음을 확인.

## 수익화 카탈로그

IAP 없음. 보상형 광고 2개 배치만 운영한다 (02 문서 수익화 표가 트리거·정책 소유).

| Product ID | value | price source | segment | unlock | limit | restore/refund | policy | fallback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD-REVIVE | 기지 30% 복구+적 50% 피해 | 광고 시청 (AdMob rewarded) | 전투 패배 직전 유저 | 스테이지 1-2부터 | 전투당 1회 | 시청 중단 시 미지급·전투는 실패 처리 | 오인 방지 UI, opt-in | 로드 실패 시 버튼 미노출 |
| AD-DOUBLE | 해당 판 사이토카인 x2 | 동일 | 승리 유저 | 첫 클리어부터 | 판당 1회 | 중단 시 기본 보상 유지 | 동일 | 동일 |

## 라이브옵스 캘린더

서버 이벤트 없음. 앱 업데이트 기반 콘텐츠 캘린더로 운영한다.

| Event ID | cadence | duration | audience | content delta | economy delta | art/copy | config | QA/rollback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| LO-001 챕터4 혈류 업데이트 | 출시 +30일 | 상시 콘텐츠 | 챕터3 클리어 유저 | 스테이지 10+보스 변형+적 1종 | base 곡선 연장 | 배경 1세트+카드 3장 | 앱 업데이트 | 스토어 단계적 출시+이전 버전 롤백 |
| LO-002 밸런스 패치 | 필요 시 (GA4 퍼널 근거) | 해당 없음 | 전체 | 없음 | 수치 조정 | 없음 | 앱 업데이트 | economy_sim 회귀 후 배포 |

## 시뮬레이션 증거

시나리오: A 무광고 / B 광고 참여(2배 절반 참여) / C 헤비(2배 상시+반복 플레이 30%). 아래는 공식 기반 추정이며 `godot/tests/economy_sim.gd` 구현 후 산출물로 대체·검증한다 (Content Complete 게이트 조건).

| Scenario | 5m | 30m | D1 | D7 | D30 | wall | currency balance | anomaly |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| A 무광고 | 162 | 1210 | 1810 | 8200 | 반복 수급 | 3-8 (평균 lv4 필요) | D7 소비 후 잔액 약 1500 | 잔액 음수 불가 검증 |
| B 광고 참여 | 200 | 1800 | 2700 | 12300 | 동일 | 3-9 | 약 3000 | 동일 |
| C 헤비 | 324 | 2400 | 3600 | 16400+ | 동일 | 없음 (풀클리어) | 약 5000 | cost 오버플로 없음 |

- 실행 파일/명령: `godot --headless --path godot res://tests/economy_sim.tscn` (Content Complete 전 구현)
- input config version: `godot/data/` .tres 세트 버전 (git 커밋 기준)
- output artifact: `docs/game-design/evidence/economy-sim-report.md`
- sensitivity test: base 계수 6→5/7, cost 성장률 1.5/1.7 스윕에서 wall 이동 확인
- exploit/overflow test: 반복 클리어 무한 수급 시 int 범위, 레벨 10 상한 재확인

## 원격 설정

원격 설정은 출시 범위에서 미도입 (Firebase SDK 없음 — 06 문서 결정). 밸런스 수치는 `godot/data/` 리소스로 앱 업데이트를 통해 배포한다. 아래는 원격 설정 도입 시(Evidence Gate 이후 재검토) 이관할 후보 키 목록이다.

| Key | type/default | min/max | purpose | audience | exposure event | rollback | owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| reward_base_slope (후보) | float / 6.0 | 4~8 | 수급 조정 | 전체 | 도입 시 정의 | 기본값 복귀 | 기획 |
| ad_revive_enabled (후보) | bool / true | 해당 없음 | 광고 배치 킬스위치 | 전체 | 동일 | 동일 | 기획 |
