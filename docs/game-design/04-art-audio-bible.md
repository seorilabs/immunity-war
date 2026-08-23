# 아트 오디오 바이블

- 제품명: 면역 전쟁 (Immunity War)
- 문서 상태: approved
- 소유자: ih@toss.im
- 버전/수정일: v0.1 / 2026-08-23
- Source of truth: 아트 방향, 팔레트, 캐릭터 시트 기준, 에셋 매니페스트, VFX·오디오·햅틱 언어
- Depends on: 03-ui-ux-spec v0.1
- Open blockers: BLK-ART-001 (스타일 앵커 미생성 — 게이트 2에서 생성·승인 후 배치 생성 가능)
- 승인 근거: 사용자 승인 "승인한다" / 2026-08-23 (G1 설계 팩 승인)

## 아트 방향

- 한 문장 art promise: 어두운 심해 같은 몸속 미시 세계에서, 말랑하고 귀여운 세포 캐릭터들이 네온 빛을 내며 꿈틀꿈틀 싸우는 바이오 판타지.
- style family / 시대 / 문화 / mood: 2D 벡터풍 플랫 셰이딩 + 소프트 글로우, 무국적 미시 세계, 진지한 배경 위 귀여운 캐릭터의 대비. 금지: 실사 의학 일러스트, 공포·혐오 연출, 픽셀아트.
- camera / perspective / target resolution: 측면 뷰 2D, 원근 없음, 세로 390x844 기준. 유닛 소스 256x256(표시 38~68px), 보스 512x512.
- palette와 lighting: 배경 딥그린 계열 #061615 / #0B2D2A. 세포 8종 고정색 — 대식세포 #28D2A3, 호중구 #F2D95C, B세포 #63B3FF, 수지상세포 #B78CFF, 보체 #7FE8D8, 킬러T #FF8FB1, 헬퍼T #FFC978, 기억세포 #9BB8FF. 적 계열 — 군집 #F45656, 두꺼운 #C35CFF, 빠른 #FF8D42, 독소 #A6E22E, 포자 #E06CD9, 보스 #8A2BE2+실드 #BFE9FF. 보상 #FFD966, 위험 #FF6A55. 광원은 유닛 자체 발광(림 글로우), 그림자 없음.
- shape/silhouette와 material: 세포 = 둥근 blob 기반 + 역할별 외곽 변형(대식=크고 넓은 원, 호중구=뾰족 돌기, B세포=Y자 항체 모티브 등). 적 = 캡슐·막대 기반 + 태그별 변형(armored=각진 외피, fast=유선형, toxin=주둥이). 아군은 곡선, 적은 직선·각 위주로 피아 식별. 외곽선 없음, 명도 단차 2단 플랫 셰이딩 + 하이라이트 1점.

prompt-ready 문장:

```text
flat vector 2D game sprite, soft neon glow rim light, dark deep-green microscopic world,
round squishy cell creature with simple face, two-tone flat shading with single highlight,
no outline, cute but composed mood, readable silhouette at 40px,
transparent background, no text in image
```

- IP 유사성 경계: 특정 작품명(예: 유명 세포 의인화 IP)을 프롬프트에 넣지 않는다. 의인화 정도는 "점 눈+단순 입"까지로 제한하고 인체형 의인화는 하지 않는다.

## 시각 문법

| 의미 | shape | color/value | motion | VFX | 사용 금지 |
| --- | --- | --- | --- | --- | --- |
| 아군 세포 | 둥근 blob | 세포 고정색+밝은 하이라이트 | 젤리 squash 1.06배 펄스 | 발광 오라 | 각진 실루엣 |
| 적 박테리아 | 캡슐·막대 | 채도 높은 난색·보라 | 꿈틀 stretch | 없음 (평시) | 아군과 동일 곡률 |
| 표식 (옵소닌화) | Y자 항체 마커 회전 링 | #BFE9FF | 회전 | 명중 시 링 수축 | 다른 상태와 색 공유 |
| 기절 | 별 대신 거품 방울 3개 | #FFF6B8 | 상단 회전 | 없음 | 플래시 |
| 둔화 | 점액 물방울 | #A6E22E 반투명 | 늘어짐 | 바닥 점액 | 파란색 (표식과 혼동) |
| 보상 | 사이토카인 육각 결정 | #FFD966 | 플라이+회전 | 반짝 파티클 | 적 색상 |
| 위험·기지 피해 | 경계선 파열 | #FF6A55 | 플래시+비네트 | 파열 링 | 보상 색과 혼용 |

## 캐릭터와 세계

| ID | 역할/성격 | silhouette | 비율 | color/material | 표정/pose | scale | readability test |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CH-MAC 대식세포 | 듬직한 맏형 | 크고 넓은 원+짧은 위족 | 1:1 원형 | #28D2A3 젤리 | 느긋한 반달 눈 | 표시 46px | 40px 축소 판독 |
| CH-NEU 호중구 | 성급한 돌격병 | 삐죽 돌기 6개 | 0.9:1 | #F2D95C | 부릅뜬 점 눈 | 38px | 동일 |
| CH-BCL B세포 | 침착한 저격수 | 몸통+Y자 안테나 | 1:1.2 세로 | #63B3FF | 차분한 눈 | 40px | 동일 |
| CH-DEN 수지상세포 | 예민한 정찰병 | 가지돌기 별형 | 1.1:1 | #B78CFF | 큰 눈 | 40px | 동일 |
| CH-COM 보체 | 무표정 삼총사 | 작은 링 3개 결합체 | 0.8:1 | #7FE8D8 | 눈 없음 (비생물감) | 36px | 동일 |
| CH-KIL 킬러T | 냉정한 처형자 | 유선형+단검 돌기 | 1:1.1 | #FF8FB1 | 가는 눈 | 40px | 동일 |
| CH-HEL 헬퍼T | 상냥한 지휘관 | 둥근 몸+방송 안테나 | 1:1 | #FFC978 | 미소 | 40px | 동일 |
| CH-MEM 기억세포 | 졸린 기록자 | 책갈피 리본 모티브 | 1:1 | #9BB8FF | 반쯤 감은 눈 | 40px | 동일 |
| EN-계열 적 6종 | 02 문서 적 정의와 1:1 | 태그별 변형 | 캡슐 기반 | 상기 팔레트 | 눈 없음 (세균) | 26~68px | 동일 |

- 애니메이션: SpriteFrames 프레임 애니메이션 idle(4f)/move(4f)/attack(4f)/hit(2f)/death(4f), 8fps + 코드 트윈(squash) 병행. 생성 파이프라인이 프레임 시트를 못 만들면 정지 포즈 3종(idle/attack/hit) + 코드 트윈으로 대체하고 manifest에 한계를 기록한다.
- 세계(챕터 배경): ch1 상처 피부(붉은 절개 라인+표피층), ch2 호흡기(섬모+점액 안개), ch3 장(융털 기둥+점액), 각 배경은 3레이어(원경 조직/중경 구조물/근경 장식)로 분리, 세로 크롭 안전 영역 준수.

## UI 아트 경계

- engine-rendered: 전 레이아웃, 텍스트, 버튼·패널(StyleBoxFlat), 진행 바, 쿨다운 라디얼, 상태 배지
- generated/painted: 세포·적 스프라이트, 스킬 아이콘 8종, 강화 아이콘 12종, 챕터 배경 3종, 학습 카드 일러스트 11종, 키비주얼 1종, 사이토카인 아이콘
- NinePatch/safe margin: 장식 프레임 사용 시 uniform border 24px 확보
- no baked localized text: 이미지에 텍스트 굽기 전면 금지 (prompt에 no text 명시)

## 에셋 매니페스트

경로 규칙: raw는 `assets_src/{category}/{id}_raw.png`, 엔진 final은 `godot/assets/sprites/{category}/{id}.png`. 전체 목록은 배치 생성 시 `assets_src/manifest.json`으로 관리하며 아래는 카테고리 계약이다.

| Asset ID 규칙 | 경로 | 사용 화면 | type | size/aspect | alpha/NinePatch | variants | source/prompt/ref | license | memory budget | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| spr_cell_{id}_{anim} | sprites/cells/ | SCR-004, 003, 007 | character | 256x256 소스 | alpha 투명 | idle/move/attack/hit/death | 스타일 앵커+개체 시트 | 생성형 (기록 필수) | 8종 x 5앤 x 4f 아틀라스 16MB 이하 | 앵커 승인 후 |
| spr_enemy_{id}_{anim} | sprites/enemies/ | SCR-004, 007 | character | 256x256 (보스 512) | alpha | idle/move/attack/death | 동일 | 동일 | 12MB 이하 | 동일 |
| icon_skill_{id} | sprites/icons/ | SCR-004, 003 | icon | 128x128 | alpha | default 단일 | 앵커 | 동일 | 1MB | 동일 |
| icon_upgrade_{id} | sprites/icons/ | SCR-005 | icon | 128x128 | alpha | common/rare 테두리는 엔진 | 앵커 | 동일 | 1MB | 동일 |
| bg_chapter_{n}_layer{1-3} | sprites/backgrounds/ | SCR-004, 002 | bg | 1170x2532 | 불투명 | 3레이어 | 앵커 | 동일 | 챕터당 6MB | 동일 |
| card_learn_{id} | sprites/cards/ | SCR-006, 007 | illustration | 636x400 | 불투명 | 단일 | 앵커 | 동일 | 4MB | 동일 |
| key_visual_home | sprites/key/ | SCR-001 | key art | 1170x1600 | 불투명 | 단일 | 앵커+키스크린 | 동일 | 3MB | 동일 |

## VFX 언어

| Event | anticipation | action | impact | settle | color/shape | duration | intensity tiers |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 스킬 대식 (포식 돌진) | 리더 팽창 0.15s | 흡인 나선 | 원형 파동+기절 방울 | 위족 수축 | 세포색 나선 | 0.55s | reduced: 나선 제거 |
| 스킬 호중구 (염증 폭발) | 점멸 0.1s | 확산 링 | 다중 파열 | 잔광 | 노랑-주황 링 | 0.45s | 파열 수 1/3 |
| 스킬 B세포 (항체 표식) | 안테나 발광 | Y마커 투척 | 대상 링 형성 | 링 회전 지속 | #BFE9FF Y자 | 0.7s | 발광만 |
| 처치 | 없음 | 파열 | 색상 링+파편 4개 | 페이드 | 적 고유색 | 0.34s | 파편 제거 |
| 기지 피해 | 없음 | 경계 파열 | 붉은 비네트 | 페이드 | #FF6A55 | 0.4s | 비네트 알파 50% |
| 보스 실드 파괴 | 실드 균열 0.3s | 유리 파열 | 전장 섬광 1프레임 | 파편 낙하 | #BFE9FF 파편 | 0.8s | 섬광 제거 |

- z-order: VFX는 유닛 아래(바닥 효과)와 위(파열) 2개 레이어 고정, HUD 위 배치 금지. 동시 파티클 노드 상한 24 (06 성능 예산과 동기).

## 오디오와 햅틱

| Audio ID | event/scene | type | mood/instruments | loudness role | loop | ducking/bus | haptic | accessibility |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bgm_home | SCR-001, 002, 003, 007 | BGM | 신비로운 앰비언트, 부드러운 신스 패드+물방울 텍스처 | 배경 -18LUFS | seamless loop 60~90s | 전투 진입 시 크로스페이드 | 없음 | 음소거 무영향 |
| bgm_battle | SCR-004 | BGM | 긴장 유지 미드템포, 펄스 베이스+바이오 텍스처 | -16LUFS | seamless loop | 보스 시 bgm_boss로 | 없음 | 동일 |
| bgm_boss | 보스전 | BGM | 고조 리듬+저역 강조 | -14LUFS | loop | 클리어 스팅어에 duck | 없음 | 동일 |
| stg_win / stg_fail / stg_unlock | 결과·해금 | stinger | 승리 상승 프레이즈 / 하강 / 반짝임 | 전경 | 없음 | BGM duck 50% | win=medium | 시각 배너 병행 |
| sfx_skill_{cell} 8종 | 스킬 발동 | core SFX | 세포별 질감 (흡인/파열/투척 등) | 전경 | 없음 | 없음 | medium | 시각 VFX 병행 |
| sfx_hit / sfx_kill / sfx_base_hit | 전투 | core SFX | 젤리 타격 / pop 파열 / 둔탁 경고 | 중경 | 없음 | 동시 발음 6 상한 | kill=light, base=strong | 동일 |
| sfx_ui_tap / confirm / error | 전 UI | UI SFX | 짧은 물방울 계열 | 전경 소음량 | 없음 | 없음 | tap=light | 동일 |
| sfx_reward / sfx_upgrade | 보상·강화 | UI SFX | 결정 반짝임 / 상승 톤 | 전경 | 없음 | 없음 | light | 동일 |

- 제작: game-sound-pipeline 사용 (BGM·스팅어). 단순 SFX는 CC0 소스 우선 후 부족분만 생성. 청취 QA 없이 승인 금지.
- 인터럽트: 전화·백그라운드 시 전체 정지, 복귀 시 BGM 재개. iOS 무음 스위치 존중.

## 생성과 라이선스

| Asset | tool/model/source | input refs | prompt/version | human edits | license/provenance | market review |
| --- | --- | --- | --- | --- | --- | --- |
| 전 생성 스프라이트·배경·카드 | game-asset-pipeline (배치 생성 시 모델·버전 기록) | 스타일 앵커 + 캐릭터 시트 | manifest.json에 프롬프트 보존 | 배경 제거·리사이즈·아틀라스 | 생성물 상업 사용 조건을 생성 시점에 기록 | Play·App Store AI 생성물 고지 요건을 제출 시점에 재확인 |
| BGM·SFX | game-sound-pipeline (Stability AI Stable Audio) | 무드 어휘 (본 문서) | manifest에 보존 | 루프 포인트 편집 | 동일 | 동일 |
| NotoSansKR 폰트 | Google Fonts | 해당 없음 | 해당 없음 | 없음 | OFL (godot/assets/fonts/OFL-NotoSansKR.txt 보관) | 문제 없음 |

## 승인 게이트

| Gate | 필수 증거 | 상태 |
| --- | --- | --- |
| 1 아트 방향 | 본 문서 팔레트·문법·금지 규칙 | 본 문서 승인 시 통과 |
| 2 스타일 앵커 | 대표 세포 1종+적 1종 앵커 이미지 사용자 승인 | 대기 (BLK-ART-001) |
| 3 키스크린 | SCR-004 실물 비율 키스크린 (HUD 포함) | 대기 |
| 4 캐릭터 시트 | 세포 8종+적 6종 상태 시트 | 대기 |
| 5 배치 QA | contact sheet, 40px 축소, 명암 배경 검사 | 대기 |
| 6 런타임 | 실기기 스크린샷·성능 | 대기 |
| 7 오디오 | 루프 seam 지표+청취 QA | 대기 |

- 게이트 2 승인 전에 유료 배치 생성을 시작하지 않는다.
