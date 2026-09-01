#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_dir="$repo_root/godot"
presets_file="$project_dir/export_presets.cfg"

fail() {
  echo "native export contract: $*" >&2
  exit 1
}

section_value() {
  local section="$1"
  local key="$2"

  awk -v section="$section" -v key="$key" '
    $0 == section { in_section = 1; next }
    /^\[/ { in_section = 0 }
    in_section && index($0, key "=") == 1 {
      print substr($0, length(key) + 2)
      exit
    }
  ' "$presets_file"
}

unquote() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  printf '%s' "$value"
}

require_value() {
  local section="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(section_value "$section" "$key")"
  [[ "$actual" == "$expected" ]] || fail "$section $key must be $expected (got ${actual:-missing})"
}

[[ -f "$presets_file" ]] || fail "missing godot/export_presets.cfg"
[[ -f "$project_dir/project.godot" ]] || fail "missing godot/project.godot"
grep -Fxq 'textures/vram_compression/import_etc2_astc=true' "$project_dir/project.godot" || fail "Android ETC2/ASTC import is not enabled"

require_value "[preset.0]" "name" '"Web"'
require_value "[preset.0]" "platform" '"Web"'
require_value "[preset.1]" "name" '"Android"'
require_value "[preset.1]" "platform" '"Android"'
require_value "[preset.1.options]" "gradle_build/use_gradle_build" "true"
require_value "[preset.1.options]" "gradle_build/export_format" "1"
require_value "[preset.1.options]" "gradle_build/min_sdk" '"24"'
require_value "[preset.1.options]" "architectures/arm64-v8a" "true"
require_value "[preset.2]" "name" '"iOS"'
require_value "[preset.2]" "platform" '"iOS"'
require_value "[preset.2.options]" "architectures/arm64" "true"
require_value "[preset.2.options]" "application/min_ios_version" '"15.0"'
require_value "[preset.2.options]" "application/export_project_only" "true"

while IFS= read -r resource; do
  relative_path="${resource#res://}"
  [[ -e "$project_dir/$relative_path" ]] || fail "missing referenced resource: $resource"
done < <(grep -Eo 'res://[^" ]+' "$presets_file" | sort -u)

if grep -Eq '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|keystore/(release|debug)(_password)?=.+|password=.+)' "$presets_file"; then
  fail "signing material must not be stored in export_presets.cfg"
fi

android_package="$(unquote "$(section_value "[preset.1.options]" "package/unique_name")")"
ios_bundle="$(unquote "$(section_value "[preset.2.options]" "application/bundle_identifier")")"
ios_team="$(unquote "$(section_value "[preset.2.options]" "application/app_store_team_id")")"

if [[ "$android_package" == "확정 필요" || "$ios_bundle" == "확정 필요" || "$ios_team" == "확정 필요" ]]; then
  echo "native export identity gate: HUMAN_INPUT_REQUIRED (BLK-001)"
else
  [[ "$android_package" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || fail "invalid Android package identifier"
  [[ "$ios_bundle" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]] || fail "invalid iOS bundle identifier"
  [[ "$ios_team" =~ ^[A-Z0-9]{10}$ ]] || fail "invalid App Store team identifier"
  echo "native export identity gate: RESOLVED"
fi

if [[ "${REQUIRE_GODOT_EXPORT_TEMPLATES:-0}" == "1" ]]; then
  [[ -n "${GODOT_VERSION:-}" ]] || fail "GODOT_VERSION is required when template verification is enabled"
  template_dir="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${GODOT_VERSION}.${GODOT_STATUS:-stable}"
  [[ -d "$template_dir" ]] || fail "missing Godot export templates: $template_dir"
  for template_name in android_source.zip android_release.apk ios.zip; do
    [[ -s "$template_dir/$template_name" ]] || fail "missing Godot native export template: $template_name"
  done
fi

if [[ "${VERIFY_EXPORT_PACKS:-0}" == "1" ]]; then
  command -v godot >/dev/null 2>&1 || fail "godot executable is required for export-pack verification"
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/immunity-war-export-contract.XXXXXX")"
  cleanup() {
    [[ -n "${temp_dir:-}" && "$temp_dir" != "/" ]] && rm -rf -- "$temp_dir"
  }
  trap cleanup EXIT
  for preset_name in Android iOS; do
    preset_slug="$(printf '%s' "$preset_name" | tr '[:upper:]' '[:lower:]')"
    if ! godot --headless --path "$project_dir" --export-pack "$preset_name" "$temp_dir/$preset_slug.pck" >"$temp_dir/$preset_slug.log" 2>&1; then
      sed -n '1,200p' "$temp_dir/$preset_slug.log" >&2
      fail "$preset_name export-pack verification failed"
    fi
    if grep -Eq 'SCRIPT ERROR|ERROR:' "$temp_dir/$preset_slug.log"; then
      sed -n '1,200p' "$temp_dir/$preset_slug.log" >&2
      fail "$preset_name export-pack emitted an engine error"
    fi
  done
  [[ -s "$temp_dir/android.pck" && -s "$temp_dir/ios.pck" ]] || fail "export-pack verification did not produce both artifacts"
fi

echo "native export contract: OK"
