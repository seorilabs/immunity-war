# QA 론칭 계획

- 제품명: 면역 전쟁 (Immunity War)
- 문서 상태: approved
- 소유자: ih@toss.im
- 버전/수정일: v0.1 / 2026-08-23
- Source of truth: QA 매트릭스, 스토어·정책 준비 상태, 출시 게이트, 소프트론칭 기준
- Depends on: 02-gdd v0.1, 06-technical v0.1
- Open blockers: BLK-001 (package/bundle id), BLK-002 (연령 등급 재확인), BLK-003 (AdMob ID), BLK-QA-001 (실기기 매트릭스는 사용자 보유 기기 확인 후 확정)
- 승인 근거: 사용자 승인 "승인한다" / 2026-08-23 (G1 설계 팩 승인)

## 기기와 플랫폼 매트릭스

| Tier | Device/OS | aspect/safe area | GPU/RAM | network | market build | owner |
| --- | --- | --- | --- | --- | --- | --- |
| 필수 Android mid | Galaxy A2x급 / Android 13+ | 20:9 펀치홀 | Mali 저사양 / 4GB | online+airplane | 내부 테스트 트랙 | 사용자 실기기 (BLK-QA-001) |
| 필수 iOS | iPhone SE 2·3 또는 13 이상 / iOS 16+ | notch·Dynamic Island | A13+ / 3GB | 동일 | TestFlight | 동일 |
| 권장 Android high | Galaxy S 계열 | 20:9 | 상위 | 동일 | 동일 | 동일 |
| 시뮬 보조 | Android Emulator + iOS Simulator | compact 360x740 포함 | 해당 없음 | 동일 | 로컬 빌드 | 에이전트 |

## 기능 QA

| Test ID | feature | precondition | steps | expected | data/save | automation/manual |
| --- | --- | --- | --- | --- | --- | --- |
| FT-001 | 전투 승리 플로우 | 1-1 신규 | 출격→클리어→보상 확인 | AC-001 규칙, 보상 지급·저장 | 신규 세이브 | balance_sim + manual |
| FT-002 | 전투 패배·부활 | 부활 가능 상태 | 기지 0→광고 시청 | AC-004 | run 스냅숏 | 광고 목+manual |
| FT-003 | 강화 3택 | 웨이브 클리어 | 3택 표시→선택 | 적용·저장, back 무시 | run | manual |
| FT-004 | 강제 종료 복구 | 웨이브2 클리어 직후 종료 | 재실행 | AC-003 웨이브3 복원 | run 스냅숏 | 자동 라운드트립+manual |
| FT-005 | 해금·레벨업 | 챕터1 보스 클리어 | 해금 확인→레벨업 | AC-006, 잔액 차감 floor | meta | manual |
| FT-006 | 저장 손상 복구 | save.json 임의 손상 | 앱 실행 | `.bak` 폴백, save_error 이벤트 | 손상 픽스처 | 자동 |
| FT-007 | 광고 로드 실패 | 비행기 모드 | 결과·패배 화면 진입 | 광고 버튼 미노출, 진행 무영향 | 무관 | manual |
| FT-008 | 보스 실드 기믹 | 챕터1 보스 | 표식 없이·있이 공격 | AC-005 | 무관 | 시뮬+manual |

## UX와 접근성 QA

| Test | screen/flow | device/input | barrier | expected | screenshot/video | result |
| --- | --- | --- | --- | --- | --- | --- |
| UXQ-001 첫 세션 5분 | FTUE 전체 | 실기기 2종 | 없음 | 03 문서 스토리보드 일치, idle 구간 없음 | 무편집 영상 | Vertical Slice에서 기록 |
| UXQ-002 터치 타깃 | 전투·덱 | compact 360x740 | 조작 | 48dp 미달·겹침 없음 | 오버레이 검사 캡처 | 동일 |
| UXQ-003 safe area | 전 화면 | notch·Dynamic Island 기기 | 없음 | 잘림·가림 없음 | 스크린샷 세트 | 동일 |
| UXQ-004 한글 오버플로 | 전 화면 최장 카피 | reference | 없음 | 말줄임·겹침 없음 | 스크린샷 | 동일 |
| UXQ-005 색각·음소거 | 전투 | 그레이스케일·음소거 | 색각·청각 | 상태 판독 가능, 완주 가능 | 그레이스케일 캡처 | 동일 |
| UXQ-006 reduced motion | 전투·결과 | 설정 온 | 광과민 | 플래시·흔들림 제거 확인 | 영상 | 동일 |
| UXQ-007 중단·복귀 | 전투 중 홈·전화 | 실기기 | 없음 | 일시정지 복귀, 오디오 재개 | 영상 | 동일 |

## 성능과 안정성

| Metric | Scene/device | target | tool | duration | result | blocker |
| --- | --- | --- | --- | --- | --- | --- |
| FPS/frame pacing | 전투 최대 물량 / mid Android | 60fps, 최저 30 | Godot profiler + GPU Inspector | 스테이지 3연속 | Hardening에서 기록 | 미달 시 파티클·유닛 상한 하향 |
| memory | 전투 / 양 플랫폼 | 400MB 이하 (iOS 350) | 프로파일러 | 20분 | 동일 | 아틀라스 재압축 |
| cold start | 부트→홈 | Android 4s, iOS 3s | 수동 계측 x5 평균 | 해당 없음 | 동일 | 로딩 분할 |
| thermal | 전투 20분 | 스로틀 시 30fps 유지 | 실기기 관찰 | 20분 | 동일 | 프레임 상한 옵션 |
| crash/ANR | 전 플로우 | 크래시 0건 (QA 세션 내) | 수동+콘솔 사전 리포트 | QA 전체 | 동일 | 원인 수정 전 출시 불가 |
| offline | 비행기 모드 전 플로우 | 광고 외 전 기능 정상 | manual | 1세션 | 동일 | 없음 |
| resume | 백그라운드 10분 후 복귀 | 상태 보존 | manual | 해당 없음 | 동일 | 저장 flush 검증 |

## 개인정보 정책과 연령등급

| Data/Content | purpose | SDK/source | collection/share | consent/delete | store disclosure | rating impact |
| --- | --- | --- | --- | --- | --- | --- |
| 익명 client_id (로컬 UUID) | 분석 집계 | GA4 MP 자체 구현 | 수집·GA4 전송, 제3자 공유 없음 | 계정 없음, 앱 삭제 시 소멸 (설정 화면 고지) | Play Data safety·Apple 라벨에 분석 목적 기기 식별자 아님(자체 UUID)으로 정확 기재 | 없음 |
| 게임플레이 이벤트 | 밸런스·퍼널 | 동일 | 동일 | 동일 | 분석 데이터로 기재 | 없음 |
| 광고 (AdMob) | 보상형 광고 | AdMob SDK | AdMob 고지 요건 따름 — 비개인화 광고 구성으로 시작 (ATT 프롬프트 미사용) | Google UMP는 대상 지역 요구 시 활성 | 광고 SDK 수집 항목을 Data safety에 반영 (제출 시점 공식 문서 재확인) | 광고 포함 고지 |
| 콘텐츠 (만화적 세균 전투) | 게임 | 자체 | 해당 없음 | 해당 없음 | 폭력성: 만화적·추상적 | 전체이용가 예상 (BLK-002 — IARC 설문·Apple 등급 문항으로 확정) |

- 개인정보처리방침 문서: 출시 전 작성, 설정 화면·스토어 등재 (수집 항목: 익명 분석 이벤트, 광고 SDK 고지 포함)
- 아동 대상 아님 (전 연령 이용 가능하되 아동 타깃 마케팅 없음) — Play 대상 연령 설문에 반영

## 스토어와 정책

| Market | package/bundle | listing/assets | billing/ads | privacy/rating | signing/build | console verification | blocker |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Google Play | BLK-001 (후보: com.seorilabs.immunitywar — 사용자 결정 항목이라 blocker 유지) | google-play-publishing 스킬로 등록 (아이콘·피처그래픽·스크린샷 8종) | 광고 포함 표기, IAP 없음 | Data safety+IARC | Play App Signing, AAB x64 Linux 빌드, seorilabs-credentials | 내부 테스트 트랙 업로드·처리 상태 확인 | BLK-001~003 |
| App Store | BLK-001 | apple-app-store-registration 스킬 | 광고 포함, IAP 없음 | 개인정보 라벨+연령 등급 문항 | Xcode Cloud archive·upload | TestFlight 처리 상태 확인 | 동일 |

## 출시 포지셔닝과 획득

| Channel/Surface | audience | promise/creative hypothesis | asset/copy | target action | metric | cost/source | experiment |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Play·App Store listing | KR 전략·캐주얼 유저 | 몸속 면역 부대를 지휘하는 오토배틀 디펜스 | 전투 키스크린 3장+덱·강화 2장, 15s 영상 후보 | install | 노출 대비 설치율 (콘솔 지표) | 0 (오가닉) | 스크린샷 첫 장 A/B는 콘솔 실험 기능 사용 |
| organic/community | 과학·게임 커뮤니티 | 면역학을 게임 시스템으로 녹인 디펜스 | 학습 카드·상성 소개 이미지 | install·공유 | 유입 추적 불가 명시 (UTM 없음) | 0 | 없음 |
| paid test | 실행 안 함 (출시 범위 외) | 해당 없음 | 해당 없음 | 해당 없음 | 해당 없음 | 0 | Evidence Gate 후 재검토 |

- store 포지셔닝과 first-session 약속 일치: 스크린샷 1장 = 실제 SCR-004 전투 화면 (연출 컷 아님)
- screenshot 3대 메시지: 세포 부대 전투 / 덱·상성 전략 / 웨이브 간 강화 선택
- 금지 과장: 실사 그래픽 연출, 미구현 멀티플레이 암시, 의학 효능 문구

## 현지화와 고객지원

| Locale | game/listing | font/glyph | text expansion | culturalization/rating | QA owner | support language |
| --- | --- | --- | --- | --- | --- | --- |
| ko-KR (출시) | 게임·리스팅 한국어 | NotoSansKR 번들 | 기준 언어 | GRAC 자체등급(Play IARC 경유) | 에이전트+사용자 | 한국어 |
| en-US (후속, ASM-002) | Evidence Gate 후 | NotoSans 라틴 포함 확인 | +30% 여백 검증 필요 | ESRB 문항 | 후속 | 후속 |

- 고객지원: cs@seorilabs.com (스토어·설정 화면 표기), FAQ는 스토어 설명 하단 3문항 (저장 이전 불가·광고·오프라인)
- 리뷰 대응: 저장 손실·진행 불가 리뷰는 24h 내 확인, 재현 시 핫픽스 우선
- 데이터 삭제 문의: 로컬 저장 안내 (수집 개인정보 없음)

## 소프트론칭

| Stage | country/audience | duration/sample assumption | primary metric | guardrails | content/economy | decision |
| --- | --- | --- | --- | --- | --- | --- |
| SL-1 내부 테스트 | 내부 기기 (Play 내부 트랙+TestFlight) | 1주 | 크래시 0, QA 매트릭스 완료 | 해당 없음 | 전체 | Release Gate 진입 |
| SL-2 KR 오픈 (사실상 정식) | KR 양 스토어 | 출시 후 2주 관찰 | D1 25%+, 첫 세션 스테이지 3+ 도달 60%+ (제품 가설 — 00 문서와 동일) | 크래시율 1% 미만, 부정 리뷰 광고 테마 급증 없음 | 챕터 1~3 | 유지: 챕터4 진행 / 미달: 퍼널 병목 수정 패치 후 재관찰 |

- 별도 국가 소프트론칭은 하지 않는다 (KR 단일 언어 출시라 KR 자체가 검증 시장). 표본·시즌 편향은 GA4 리포트에 기록.

## 론칭 게이트

| Gate | required evidence | owner | status | blocker | approval date |
| --- | --- | --- | --- | --- | --- |
| G0 research | 01 문서 + 출처 원장 | 에이전트 | 완료 | 없음 | 2026-08-23 |
| G1 design | 00~07 approved + validator strict 통과 | 사용자 | 통과 | 없음 | 2026-08-23 |
| G2 vertical slice | 챕터1 최종 품질 영상 + UI Gate EV-001~004 | 사용자 | 대기 | G1, 아트 앵커 | 대기 |
| G3 content complete | 28 스테이지 + balance/economy_sim 리포트 | 에이전트 | 대기 | G2 | 대기 |
| G4 release candidate | 서명 빌드 실기기 QA 전 항목 + 스토어 메타 등록 | 사용자 | 대기 | BLK-001~003 | 대기 |
| G5 launch | 양 스토어 심사 통과·공개 + 스모크 확인 | 사용자 | 대기 | G4 | 대기 |
| G6 evidence | SL-2 지표 리포트 + 챕터4 결정 | 사용자 | 대기 | G5+2주 | 대기 |

## 롤백과 운영

| Incident | detection | kill switch/rollback | player remediation | data repair | communication | owner |
| --- | --- | --- | --- | --- | --- | --- |
| 진행 불가 버그 | 리뷰·GA4 퍼널 급락 | 스토어 단계적 출시 중단 + 이전 버전 재출시 (Play 단계적 출시 사용) | 핫픽스 우선 배포 | 저장 migration 복구 코드 | 스토어 답글·업데이트 노트 | 에이전트+사용자 |
| 저장 손상 다발 | save_error 이벤트 급증 | 동일 | `.bak` 폴백 로직 점검·핫픽스 | 손상 픽스처 재현 후 migration 수정 | 동일 | 동일 |
| 광고 SDK 장애 | ad_reward result=failed 급증 | 광고 버튼 자동 미노출 (설계상 자동 강등) | 게임 진행 무영향 확인 | 해당 없음 | 필요 시 공지 | 에이전트 |
