# 면역 전쟁 (immunity-war) Agent Instructions

## 프로젝트

- 면역 세포 vs 박테리아 전략 오토배틀 모바일 게임. Godot **4.7.2** (GDScript strict typing).
- 출시 대상: Google Play, Apple App Store 우선. AppsInToss(Web export wrapper)는 후속 단계.
- 수익화: 보상형 광고 중심(AdMob — REVIVE, DOUBLE_REWARD). 분석: GA4 Measurement Protocol (Firebase SDK 미도입).

## Source Of Truth

- 제품 설계 원장은 `docs/game-design/` (game-planning-production 설계 팩). 승인 상태와 결정은 `docs/game-design/decision-log.md`.
- 콘솔에서만 바뀐 값은 release-ready로 보지 않는다. 마켓 값은 `play-store/`, `app-store/` repo-local config에 남긴다.
- 확정 필요한 값은 `확정 필요`로 남기고 임의로 채우지 않는다.

## 구조 원칙

- Godot 프로젝트는 `godot/`. 정적 게임 데이터는 typed Resource(`godot/data/**/*.tres`), 세이브는 JSON(`user://save.json`, version 필드 + 순차 migration).
- 전투 로직(BattleController 등)은 UI 노드를 참조하지 않는다 — 헤드리스 밸런스 시뮬(`godot/tests/balance_sim.gd`)이 가능해야 한다.
- 광고/분석 등 플랫폼 SDK는 `godot/scripts/services/`의 Backend 어댑터 뒤에 격리한다. Web/에디터에서는 Noop으로 강등된다.
- 한국어 UI는 번들 폰트(`godot/assets/fonts/NotoSansKR-wght.ttf`)를 사용한다. 시스템 폰트 폴백에 의존하지 않는다.
- GDScript 컨벤션: typed return을 가진 메서드의 오버라이드는 모든 경로에서 명시적 return (Godot 4.7 요구사항).

## 검증

- 게이트: `bash scripts/godot_quality_gate.sh --project godot --smoke-scene res://tests/test_runner.tscn`
  - Godot headless exit code만 믿지 말고 로그의 `SCRIPT ERROR` / `ERROR:`도 실패로 처리한다 (스크립트가 수행).
- 로컬 Godot 준비: `bash scripts/ensure_godot.sh` (GODOT_VERSION 기본 4.7.2).

## GitHub Actions / ARC

- CI는 `.github/workflows/godot-checks.yml` → org 재사용 워크플로우(`seorilabs/.github`) 호출, `godot_version: 4.7.2`.
- private repo 정적 게이트는 `seorilabs-rpi-arm64`. Android AAB release build는 x64 Linux, Apple 빌드는 Xcode Cloud — RPI ARC로 보내지 않는다.
- ARC/러너 작업은 `seorilabs-arc-runners` 스킬과 `/Users/syous/Workspace/kubectl/github-actions-runners/global-versions.yaml`을 따른다.

## 배포 게이트

- 설계 팩 승인 전에는 store registration, package/bundle id를 확정하지 않는다.
- 유료 생성 API(에셋·사운드)는 스타일 앵커 승인 후에만 호출한다.
- 빌드 성공 ≠ 배포 완료, 업로드 성공 ≠ 공개 출시로 표현하지 않는다.

## Git / PR

- main 직접 push 허용 (사용자 지시 2026-08-23 "굳이 PR 안해도 되는데 바로 메인에 병합해"). 단 push 전 로컬 quality gate + balance_sim 통과가 필수다.
- PR을 쓰는 경우(대규모 리뷰 필요 시) 제목/Description은 한글, 운영은 `seori-pr-workflow` 스킬을 따른다.
