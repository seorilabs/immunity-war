# 리서치 조사서

- 제품명: 면역 전쟁 (Immunity War)
- 문서 상태: draft
- 소유자: ih@toss.im
- 버전/수정일: v0.1 / 2026-08-23
- Source of truth: 경쟁작 분석, 출처 원장, 시장 트렌드, 검증 가설
- Depends on: 00-product-brief v0.1
- Open blockers: 실기기 플레이 실측 미수행 (조사 한계에 기재, 후속은 game-teardown 스킬)
- 승인 근거: 사용자 승인 전

## 조사 범위

- 조사일/지역/스토어/플랫폼: 2026-08-23 / KR / Google Play KR + Apple App Store KR / Android·iOS
- 조사 방법: 스토어 페이지 원문 수집·파싱, App Store KR 최신 리뷰 RSS 50건/게임, 언론(공시 기반)·Sensor Tower 자체 블로그 교차 확인. 근거 태그: FACT / OBSERVATION / INFERENCE / HYPOTHESIS
- 답할 제품 질문: (1) 오토배틀 디펜스+로그라이트 3택 루프가 KR에서 유효한가 (2) 면역·세포 테마는 자산인가 리스크인가 (3) 보상형 광고 배치의 안전선은 어디인가 (4) 3~5분 세로 세션이 시장 기대와 맞는가
- 직접 경쟁작 선정 기준: KR 양대 스토어에서 서비스 중인 웨이브 디펜스·랜덤 디펜스·로그라이트 디펜스 상위작
- 인접 경쟁작 선정 기준: 로그라이트 성장 방치형(수익화 참고), 생물학 테마(소비층 확인)
- 접근 제한과 표본 편향: 실기기 플레이 미수행 — 초 단위 루프·광고 노출 시점은 리뷰 기반 관찰로 대체하고 태그 표기. 운빨존많겜 App Store KR 리뷰 RSS는 빈 피드 반환(Play 노출 리뷰로 대체). 리뷰 표본은 게임당 Play 노출 리뷰 10~15건 + App Store 최신 50건

## 출처 원장

접근일은 전부 2026-08-23.

| Source ID | 유형 | 제목/발행자 | URL | 게시·수정일 | 접근일 | 지역/버전 | 지지하는 주장 | 신뢰도 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SRC-001 | 스토어 원문 | Google Play KR 운빨존많겜 / 111% | https://play.google.com/store/apps/details?id=com.percent.aos.luckydefense&hl=ko | 상시 갱신 | 2026-08-23 | KR | 4.33/21.4만, 500만+ DL, 2026-08-14 업데이트, 광고+IAP, KR 리뷰 | 높음 |
| SRC-002 | 스토어 API | App Store KR 운빨존많겜 id6482291732 | https://apps.apple.com/kr/app/id6482291732 | 상시 | 2026-08-23 | KR v2.0.10 | 4.46/7.8만, IAP 구간, 세로 화면, 설명 전문 | 높음 |
| SRC-003 | 스토어 원문 | Google Play KR 성 키우기 / RAON GAMES | https://play.google.com/store/apps/details?id=com.raongames.growcastle&hl=ko | 상시 | 2026-08-23 | KR | 4.22/47.2만, 1000만+ DL, 2026-01-07 업데이트 | 높음 |
| SRC-004 | 스토어 API | App Store KR 성키우기 id1133478462 | https://apps.apple.com/kr/app/id1133478462 | 상시 | 2026-08-23 | KR v1.50.14 | iOS 3.93/1,095, 가로 화면 | 높음 |
| SRC-005 | 스토어 원문 | Google Play KR 러쉬 로얄 / MY.GAMES | https://play.google.com/store/apps/details?id=com.my.defense&hl=ko | 상시 | 2026-08-23 | KR | 4.41/77.1만, 5000만+ DL, 광고 게이트 불만 리뷰 | 높음 |
| SRC-006 | 스토어 API+RSS | App Store KR Rush Royale id1526121033 + 리뷰 RSS 50건 | https://apps.apple.com/kr/app/id1526121033 | 상시 | 2026-08-23 | KR v37.1 | 4.08/2,389, 최신 50건 중 1점 22건, 세션 길이 불만 | 높음 |
| SRC-007 | 스토어 원문 | Google Play KR 랜덤 다이스 / 111% | https://play.google.com/store/apps/details?id=com.percent.royaldice&hl=ko | 상시 | 2026-08-23 | KR | 4.23/64.9만, 1000만+ DL, 2026-02-11 이후 업데이트 정체 | 높음 |
| SRC-008 | 스토어 API+RSS | App Store KR 랜덤 다이스 id1462877149 + 리뷰 RSS | https://apps.apple.com/kr/app/id1462877149 | 상시 | 2026-08-23 | KR v9.5.5 | 3.88/7.1만, 방치 운영 불만 다수 | 높음 |
| SRC-009 | 스토어 원문 | Google Play KR 킹덤 가드 / Tap4fun | https://play.google.com/store/apps/details?id=com.tap4fun.odin.kingdomguard&hl=ko | 상시 | 2026-08-23 | KR | 4.69/39.2만, 고액 IAP·허위 광고 소재 불만 | 높음 |
| SRC-010 | 스토어 API+RSS | App Store KR Kingdom Guard id1570095804 + 리뷰 RSS | https://apps.apple.com/kr/app/id1570095804 | 상시 | 2026-08-23 | KR v1.0.587 | 4.72/5,424 (단문 5점 다수 — 프로모션 의심 관찰) | 중간 |
| SRC-011 | 스토어 원문 | Google Play KR 세포 특공대 / Snap Brain Games | https://play.google.com/store/apps/details?id=defense.roguelike.cell.shoot.survivor&hl=ko | 상시 | 2026-08-23 | KR | 4.46/15.8만, 500만+ DL (출시 1년), 광고 남용 불만 압도적 | 높음 |
| SRC-012 | 스토어 API+RSS | App Store KR 세포 특공대 id6746465127 + 리뷰 RSS | https://apps.apple.com/kr/app/id6746465127 | 상시 | 2026-08-23 | KR v3.7 | 4.42/7,457, 설명에 웨이브 간 3택 명시, 판매자 WINLON PTE(싱가포르) | 높음 |
| SRC-013 | 스토어 원문 | Google Play KR 레전드 오브 슬라임 / LoadComplete | https://play.google.com/store/apps/details?id=com.loadcomplete.slimeidle&hl=ko | 상시 | 2026-08-23 | KR | 4.37/17.7만, 1000만+ DL, 초반 광고제거 IAP 패턴 | 높음 |
| SRC-014 | 스토어 API+RSS | App Store KR 레전드 오브 슬라임 id1618701110 | https://apps.apple.com/kr/app/id1618701110 | 상시 | 2026-08-23 | KR v4.14.2 | 4.22/4,573, 4주년 릴리즈노트 | 높음 |
| SRC-015 | 스토어 원문 | Google Play KR 세포 특이점 / ComputerLunch | https://play.google.com/store/apps/details?id=com.computerlunch.evolution&hl=ko | 상시 | 2026-08-23 | KR | 4.76/39.6만, 1000만+ DL, 교육성 호평·번역 불만 | 높음 |
| SRC-016 | 스토어 API+RSS | App Store KR 세포 특이점 id1327555461 | https://apps.apple.com/kr/app/id1327555461 | 상시 | 2026-08-23 | KR v49.33 | 4.83/1,416, 최신 50건 중 5점 43건 | 높음 |
| SRC-017 | 스토어 원문 | Google Play KR Plague Inc. / Ndemic | https://play.google.com/store/apps/details?id=com.miniclip.plagueinc&hl=ko | 상시 | 2026-08-23 | KR | 4.79/405만, 1억+ DL, 14년 운영 | 높음 |
| SRC-018 | 스토어 원문 | Google Play KR 탕탕특공대 / Habby | https://play.google.com/store/apps/details?id=com.dxx.firenow&hl=ko | 상시 | 2026-08-23 | KR | 선택형 보상형 광고를 칭찬하는 KR 리뷰 원문 | 높음 |
| SRC-019 | 데이터사 블로그 | Sensor Tower KR — 타워 디펜스 장르 2월 다운로드 1위 | https://sensortower.com/ko/blog/tower-defense-becomes-the-top-downloaded-subgenre-in-february-for-the-first-ime | 2026-03경 | 2026-08-23 | KR | KR TD 하위장르 2026-02 다운로드 1위·매출 2위, 상위작 목록, 방법론 공개 | 중간 (자체 추정 방법론 공개) |
| SRC-020 | 데이터사 블로그 | Sensor Tower KR — 운빨존많겜 매출 분석 | https://sensortower.com/ko/blog/Lucky-Defense-has-become-the-highest-grossing-Korean-strategy-game | 2024 | 2026-08-23 | KR | 초기 300만 DL·매출 추정, 한국 매출 비중 79.4% | 중간 |
| SRC-021 | 언론 공시 기반 | ZDNet Korea 슈퍼패스트 2024 실적 | https://zdnet.co.kr/view/?no=20250415153323 | 2025-04-15 | 2026-08-23 | KR | 운빨존많겜 모회사 기여 | 높음 |
| SRC-022 | 언론 공시 기반 | 뉴스1 111퍼센트 흑자전환 | https://news.nate.com/view/20250414n30727 | 2025-04-14 | 2026-08-23 | KR | 111% 2024 매출 1,058억, 운빨존많겜 누적 750만 DL·1,200억+ (회사 발표) | 높음 |
| SRC-023 | 언론 | ZDNet Korea 랜덤다이스2 출시 | https://zdnet.co.kr/view/?no=20260813154840 | 2026-08-13 | 2026-08-23 | KR | 랜덤다이스2 출시, 원작 누적 2,156만 DL | 높음 |
| SRC-024 | 언론 | 디지털투데이 랜덤다이스2 가챠 제거 | https://www.digitaltoday.co.kr/news/articleView.html?idxno=692700 | 2026-08-13 | 2026-08-23 | KR | 확률형 뽑기 전면 제거·협동 메인 전환 | 높음 |
| SRC-025 | 커뮤니티 위키 | namu.wiki 운빨존많겜 (본문+게임 모드) | https://namu.wiki/w/%EC%9A%B4%EB%B9%A8%EC%A1%B4%EB%A7%8E%EA%B2%9C | 상시 | 2026-08-23 | KR | 협동 구조, 재화, VVIP 광고 제거, 확률 편향 사과 이력 — 교차 확인용 보조 | 중간 (단독 인용 금지) |
| SRC-026 | 커뮤니티 위키 | namu.wiki 성 키우기 | https://namu.wiki/w/%EC%84%B1%20%ED%82%A4%EC%9A%B0%EA%B8%B0 | 상시 | 2026-08-23 | KR | 웨이브 75 자동사냥, 보상형 광고 용처 — 보조 | 중간 |
| SRC-027 | 팬위키+매체 | Cells at Work 모바일 TD 서비스 종료 | https://cellsatwork.fandom.com/wiki/Itsudemo_Hataraku_Saibou | 2020 전후 | 2026-08-23 | JP | 유명 세포 IP TD도 10개월 만에 종료 — 테마만으로 리텐션 불가 | 중간 |
| SRC-028 | 공식 정책 | Apple HIG Designing for games | https://developer.apple.com/design/human-interface-guidelines/designing-for-games | 상시 | 2026-08-23 | 글로벌 | 03 문서 터치 타깃·safe area 기준 (구현 시 재확인) | 높음 |
| SRC-029 | 공식 정책 | Android accessibility touch targets | https://developer.android.com/guide/topics/ui/accessibility/views/apps-views | 상시 | 2026-08-23 | 글로벌 | 48dp 터치 타깃 기준 | 높음 |
| SRC-030 | 공식 문서 | GA4 권장 게임 이벤트 | https://support.google.com/analytics/answer/9267735 | 상시 | 2026-08-23 | 글로벌 | 06 문서 이벤트 설계 (level_start 등 재사용) | 높음 |
| SRC-031 | 공식 문서 | Godot 4.7 마이그레이션 가이드 | https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html | 2026-06 이후 | 2026-08-23 | 글로벌 | 06 문서 엔진 업그레이드 영향 2건 판정 | 높음 |

## 경쟁작 매트릭스

| 항목 | COMP-01 세포 특공대 | COMP-02 운빨존많겜 | COMP-03 성 키우기 | COMP-04 러쉬 로얄 | ADJ-01 세포 특이점 | 우리 결정 |
| --- | --- | --- | --- | --- | --- | --- |
| 포지셔닝 | 세포 vs 세균 로그라이트 TD (SRC-011) | 운빨 소환·합성 디펜스 (SRC-001) | 무한 성장 웨이브 디펜스 (SRC-003) | 덱 빌딩 PvP 랜덤 디펜스 (SRC-005) | 진화 교양 클리커 (SRC-015) | 면역학이 시스템에 녹은 국산 전략 오토배틀 (DEC-011) |
| 10초/3분 loop | 오토 슈팅+웨이브 간 3택 (SRC-012 설명 명시) | 소환 연타→3개 합성→등급업 | 오토+수동 스킬→골드→업그레이드 | 마나 소환→합병→PvP 버티기 | 탭→해금→방치 | 오토배틀+스킬·증원 개입+3택 |
| 첫 10분 | 빠른 전투 진입, 1시간 내 광고 의존 구조 (OBSERVATION) | 즉시 소환 루프 | 즉시 웨이브 | 튜토리얼 후 PvP | 탭 루프 | 1-1이 튜토리얼 겸용, 첫 스테이지 광고 0 |
| 화면 hierarchy | 세로, 전장 중심 | 세로, 전장+소환 UI | 가로, 성 중심 | 세로, 보드 중심 | 가로, 트리 중심 | 세로, 전장 70%+ (03 문서) |
| 세션 | 순수 3~5분 (광고 포함 15분 불만 리뷰) | 10~20분 추정 — 길다는 불만 존재 | 웨이브 1~2분 반복+방치 | 3분+ — 그것도 길다는 리뷰 존재 | 방치 | 3~5분 고정 (ASM-001 강화) |
| 경제/monetization | 보상형 광고 하드 의존+IAP — 최대 불만 | IAP 중심+광고 보조 | 광고+소액 IAP 관대 | IAP 중심, 유료도 광고 — 반발 | 선택형 광고+소액 IAP | 광고 2지점 한정, IAP 없음 (DEC-003) |
| art/audio/game feel | 세포·세균 캐주얼 | 귀여운 SD 유닛+뽑기 연출 | 심플 2D | 카툰 유닛 | 3D 트리 | 귀여운 세포 blob (04 문서) |
| 콘텐츠/liveops | 던전·패스, 무고지 너프 불만 | 모드 다수+시즌 | 10년 누적 콘텐츠 | 시즌·이벤트 상시 | 지속 확장 | 챕터 업데이트 (05 문서) |

- 추가 직접 경쟁 관찰: 랜덤 다이스(SRC-007·008 — 운영 방치가 IP 신뢰 소진, 후속작이 가챠 제거로 선회 SRC-023·024), 킹덤 가드(SRC-009·010 — 허위 광고 소재·고액 IAP 반발). 인접: 레전드 오브 슬라임(SRC-013·014 — 초반 광고제거 소액 IAP 패턴), Plague Inc(SRC-017 — 생물 테마 1억 DL), 탕탕특공대(SRC-018 — 선택형 광고 칭찬 리뷰).

## 리뷰와 플레이어 문제 종합

| Theme ID | 근거 | 빈도/표본 | 심각도 | 현재 버전 확인 | 기회/비기회 |
| --- | --- | ---: | ---: | --- | --- |
| REV-01 광고 강제성·광고 오류 (보상 미지급, 닫기 불가, 타 앱 실행) | SRC-011·012·015 리뷰 원문 | 높음 (세포 특공대 최신 리뷰 지배적) | 높음 (1점 직행) | 예 | 기회 — 광고 2지점 한정+지급 실패 자동 보정 |
| REV-02 난이도 절벽 = 과금 압박 체감 | SRC-001·011 리뷰 | 높음 | 높음 | 예 | 기회 — 상성·덱 교체로 돌파 가능한 벽 설계 |
| REV-03 확률 불신 (편향 사과 이력, 천장 부재) | SRC-025(공식 사과 교차), SRC-007·005 리뷰 | 높음 | 중간 | 예 | 기회 — 가챠 자체 없음, 3택도 시드 공정 |
| REV-04 계정·저장 유실 | SRC-007·003·017 리뷰 | 높음 | 높음 (게임 무관 1점) | 예 | 부분 리스크 — 우리도 클라우드 저장 없음. 설정에 명시 고지+Evidence Gate에서 클라우드 저장 재검토 |
| REV-05 업데이트 방치·운영 불신 (무고지 너프) | SRC-007·008·011 리뷰 | 높음 | 중간 | 예 | 기회 — 패치 노트 정직 운영, 리뷰 답글 (SRC-001 방식) |
| REV-06 세션이 길다 | SRC-006 리뷰(3분도 길다), SRC-001 리뷰 | 중간 | 중간 | 예 | 기회 — 3~5분 고정 세션 |
| REV-07 선택의 재미 (3택·조합) | SRC-011 리뷰(옵션 고르는 재미), SRC-008 | 높음 (긍정) | 해당 없음 | 예 | 자산 — 코어에 이미 반영 |
| REV-08 귀여운 캐릭터 | SRC-001·013 리뷰 | 높음 (긍정) | 해당 없음 | 예 | 자산 — DEC-004 |
| REV-09 교육적 가치 (생물 테마 한정) | SRC-015·016·017 리뷰 | 높음 (긍정) | 예 | 자산 — 학습 카드 (PIL-003) |
| REV-10 번역·텍스트 품질 (과학 테마 소비층 1번 불만) | SRC-015·017 리뷰 | 높음 | 중간 | 예 | 기회 — 한국어 네이티브 제작 자체가 차별화 |

## 기회와 위험

| Opportunity/Risk | Evidence | 우리 대응 | 검증 비용 | 우선순위 |
| --- | --- | --- | ---: | ---: |
| 기회: 세포 특공대 이탈층 흡수 — 동일 테마·루프 검증됨, 불만(광고 남용·운영)은 구조적 | SRC-011·012·019 | 국산·절제된 광고·상성 전략 포지셔닝 (DEC-011), ASO에서 세포·세균 키워드 | 낮음 | 1 |
| 기회: KR TD 장르 상승기 (2026-02 다운로드 1위 하위장르) | SRC-019 | 출시 시점 유리, 국산 강세 흐름 부합 | 없음 | 1 |
| 기회: 랜덤성 피로 반작용 (랜다2 가챠 제거 선회) | SRC-023·024 | 결정론적 상성·덱 전략 전면화 | 낮음 | 2 |
| 기회: 3~5분 세션 기대치 | SRC-006·011 | ASM-001 유지 | 낮음 | 2 |
| 위험: 클라우드 저장 부재 = 장르 공통 1점 리뷰 생산지 | SRC-007·003·017 | 설정 화면 명시 고지, Evidence Gate에서 클라우드 저장(어댑터 교체) 재검토 | 중간 | 2 |
| 위험: 테마만으로 리텐션 불가 (세포 IP TD 10개월 종료) | SRC-027 | 루프·운영 우선, 테마는 획득 자산으로만 | 없음 | 1 |
| 위험: 광고 SDK 품질 문제로 인한 평점 하락 | SRC-011·015 | 보상 지급 실패 시 재지급 보정 로직 (06 문서 반영 예정) | 낮음 | 1 |

## 검증할 가설

| Hypothesis ID | 가설 | 선행 근거 | Prototype/Experiment | 성공 | 중단 | 기한 |
| --- | --- | --- | --- | --- | --- | --- |
| H1 | 광고 2지점 한정이 다지점 배치보다 리텐션·평점에서 우세 | REV-01 | 출시 후 GA4 광고 퍼널+리뷰 감성 관찰 (A/B는 원격 설정 도입 후) | D7·평점 방어 | 광고 수익 심각 부족 시 지점 추가 재검토 | Evidence Gate |
| H2 | 3~5분 1판 고정이 세션당 판수를 늘려 총 플레이타임 우세 | REV-06 | GA4 판 길이·세션당 판수 분포 | 세션당 3판+ | 1판 이탈 다수 | Evidence Gate |
| H3 | 상성·표식은 3판 내 학습 가능하며 학습 유저의 리텐션이 높다 | REV-07, PIL-001 | 약점 타격 비율 로깅 → 코호트 비교 | 상관 확인 | 학습률 30% 미만 시 튜토리얼 보강 | Evidence Gate |
| H4 | 학습 카드가 도감 열람·추천 의향을 만든다 | REV-09 | card_seen·codex 열람 이벤트 | 열람률 40%+ | 스킵 지배적이면 축소 | Evidence Gate |
| H5 | 3택 리롤은 무료 1회 제공이 광고 리롤보다 만족 우세 | REV-01 (세포 특공대 리롤 광고 반발) | 출시는 리롤 없음으로 시작, 요구 리뷰 모니터링 | 불만 없음 | 리롤 요구 다수 시 무료 1회 추가 | 출시 후 30일 |
| H6 | 8종 로스터로 정답 덱 고착을 피하려면 스테이지별 적 구성 변주 필수 | SRC-005 미러덱 불만 | 덱 사용 분포 로깅, 특정 덱 점유 50% 초과 시 개입 | 다양성 유지 | 고착 시 밸런스 패치 | 상시 |
| H7 | KR 스토어 카피는 구어 훅이 CVR 우세 | SRC-001 카피 성공 | Play 스토어 리스팅 실험 | CVR 개선 | 무차이 | Release 후 |
| H8 | 협동 부재는 매출 상한을 낮추나 MVP 솔로가 옳다 | SRC-001·024 협동 중심 흐름 | 리텐션 안정화 후 수요 설문 | 수요 확인 시 로드맵 | 수요 낮으면 유지 | Evidence Gate 이후 |
| H9 | 세포 특공대 광고 이탈층은 동일 테마 대체재로 전환 의향이 있다 | REV-01 | ASO 키워드+스토어 카피에 절제된 광고 메시지 | 오가닉 유입 | 무반응 | Release 후 |
| H10 | 첫 광고 노출을 첫 승리 이후로 늦추면 D1 개선 | SRC-012 1시간 내 광고 의존 반발 | 설계에 선반영 (1-1 광고 0) — 퍼널로 사후 확인 | D1 25%+ | 해당 없음 | Evidence Gate |

## 결정 반영

| Decision ID | GDD 반영 위치 | 근거 | 버린 대안 | 재검토 Gate |
| --- | --- | --- | --- | --- |
| DEC-003 (광고 2지점·IAP 없음) | 02 수익화, 05 카탈로그 | REV-01, SRC-018 선택형 칭찬 | 다지점 광고, IAP 병행 | Evidence Gate (H1) |
| DEC-011 (포지셔닝: 국산·절제 광고·상성 전략) | 00 차별점, 07 포지셔닝 | SRC-011·019·023 | 순수 교육 게임 포지셔닝 | G1 승인 시 확정 |
| 3~5분 세션 고정 (ASM-001 → 확정 승격 제안) | 02 콘텐츠 단위 계약 | REV-06, SRC-011 | 10분+ 장세션 | G1 |
| 1-1 광고 0 정책 | 02 수익화 | H10, SRC-012 | 첫 판부터 광고 | 없음 |
| 가챠 없음 유지 | 00 하지 않을 것 | REV-03, SRC-024 | 세포 뽑기 도입 | Evidence Gate 이후에도 미도입 원칙 |
| 광고 보상 재지급 보정 로직 | 06 플랫폼 연동 (구현 시 추가) | REV-01 광고 오류 1점 리뷰 | 미보정 | Phase 4 |
