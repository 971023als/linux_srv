#!/bin/bash

# 스크립트 위치 기준으로 동작 (다른 디렉터리에서 실행해도 동일하게 동작)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# function.sh 파일을 소스로 가져옴 (없으면 경고 후 계속)
if [ -f "$SCRIPT_DIR/function.sh" ]; then
  . "$SCRIPT_DIR/function.sh"
else
  echo "[경고] function.sh를 찾을 수 없습니다. 공통 함수 없이 진행합니다."
fi

# 로그 파일 설정
TMP1=$(basename "$0").log          # 실행 기록 (상태 + stdout/stderr 전체)
VERDICTS=".vuln_verdicts.tmp"      # 판정 집계용 임시 파일

# 로그 파일 초기화
> "$TMP1"
> "$VERDICTS"

# 지난 실행의 개별 결과 로그는 삭제하지 않고 남겨둔다.
# 이번 실행에 추가된 내용만 집계하기 위해 실행 전 내용의 스냅샷을 임시 디렉터리에 둔다.
SNAP_DIR=$(mktemp -d)
MARKER=$(mktemp)

# 실행 결과 집계 (실행 성공/실패/건너뜀을 구분)
ran=0
failed=0
skipped=0
failed_list=""
skipped_list=""

# 001부터 174까지 순회하면서 파일명 생성 및 실행
for i in $(seq -w 1 174); do
  target=""
  interpreter=""
  if [ -f "SRV-$i.py" ]; then
    target="SRV-$i.py"
    interpreter="python3"
  elif [ -f "SRV-$i.sh" ]; then
    target="SRV-$i.sh"
    # 현재 SRV-*.sh 파일은 모두 shebang 없는 Python 스크립트다.
    # 첫 줄이 shebang이면 해당 셸로, 아니면 python3로 실행한다.
    first_line=$(head -n 1 "$target")
    case "$first_line" in
      "#!"*bash*|"#!"*sh) interpreter="bash" ;;
      *)                 interpreter="python3" ;;
    esac
  else
    skipped=$((skipped + 1))
    skipped_list="$skipped_list SRV-$i"
    continue
  fi

  ran=$((ran + 1))
  echo "Executing $target ($interpreter)" >> "$TMP1"
  # 기존 결과 로그의 스냅샷 (원본은 삭제/수정하지 않음)
  for cand in "SRV-$i.log" "SRV-$i.py.log" "SRV-$i.sh.log"; do
    [ -f "$cand" ] && cp -p "$cand" "$SNAP_DIR/$cand"
  done
  # 이 스크립트 실행 직전 시각 (내용이 같은 파일의 갱신 여부 판별용)
  touch "$MARKER"
  # 표준 출력/오류는 실행 기록과 판정 집계 양쪽에 남긴다
  out=$("$interpreter" "$target" 2>&1)
  rc=$?
  printf '%s\n' "$out" >> "$TMP1"
  printf '%s\n' "$out" >> "$VERDICTS"
  if [ $rc -ne 0 ]; then
    failed=$((failed + 1))
    failed_list="$failed_list SRV-$i"
    echo "[오류] $target 실행 실패 (종료 코드 $rc)" >> "$TMP1"
  fi
  # 점검 스크립트의 개별 결과 로그를 판정 집계에 포함
  # (파일명 규칙이 스크립트마다 달라 알려진 형태를 모두 확인.
  #  추가 기록 방식 스크립트는 이번 실행에 추가된 부분만 포함하고,
  #  이전 내용은 파일에 그대로 보존)
  for cand in "SRV-$i.log" "SRV-$i.py.log" "SRV-$i.sh.log"; do
    [ -f "$cand" ] || continue
    if [ -f "$SNAP_DIR/$cand" ]; then
      if cmp -s "$SNAP_DIR/$cand" "$cand" && [ ! "$cand" -nt "$MARKER" ]; then
        continue  # 이번 실행에 쓰지 않은 기존 로그 (집계 제외, 파일은 보존)
      fi
      snap_size=$(stat -c%s "$SNAP_DIR/$cand")
      cur_size=$(stat -c%s "$cand")
      if [ "$cur_size" -gt "$snap_size" ] && head -c "$snap_size" "$cand" 2>/dev/null | cmp -s - "$SNAP_DIR/$cand"; then
        # 기존 내용 뒤에 추가 기록된 경우: 새로 추가된 부분만 추출
        tail -c "+$((snap_size + 1))" "$cand" >> "$VERDICTS"
      else
        # 파일을 새로 쓴 경우(덮어쓰기): 현재 내용 전체가 이번 실행 결과
        cat "$cand" >> "$VERDICTS"
      fi
    else
      # 이번 실행에 새로 만들어진 로그는 전체 포함
      cat "$cand" >> "$VERDICTS"
    fi
  done
done
rm -rf "$SNAP_DIR" "$MARKER"

# 판정 집계: stdout과 개별 로그를 모두 쓰는 스크립트가 있어
# 동일한 줄은 한 번만 센다
good_count=$(grep -E 'OK:|결과 : 양호' "$VERDICTS" | awk '!seen[$0]++' | wc -l)
bad_count=$(grep -E 'WARN:|결과 : 취약' "$VERDICTS" | awk '!seen[$0]++' | wc -l)
na_count=$(grep -F 'N/A' "$VERDICTS" | awk '!seen[$0]++' | wc -l)
rm -f "$VERDICTS"

echo ""  >> "$TMP1"
echo "================================ 진단 결과 요약 ================================" >> "$TMP1"
echo ""  >> "$TMP1"
echo "                              ★ 실행 항목 개수 = $ran (건너뜀 $skipped, 실행 오류 $failed)" >> "$TMP1"
echo "                              ☆ 양호 개수 = $good_count" >> "$TMP1"
echo "                              ★ 취약 개수 = $bad_count" >> "$TMP1"
echo "                              ☆ N/A 개수 = $na_count" >> "$TMP1"
if [ -n "$failed_list" ]; then
  echo "                              ★ 실행 실패:$failed_list" >> "$TMP1"
fi
if [ -n "$skipped_list" ]; then
  echo "                              ☆ 스크립트 없음(건너뜀):$skipped_list" >> "$TMP1"
fi
echo ""  >> "$TMP1"
echo "==============================================================================" >> "$TMP1"
echo ""  >> "$TMP1"

# 실행 오류가 있으면 0이 아닌 코드로 종료 (건너뜀은 오류가 아님)
if [ "$failed" -gt 0 ]; then
  exit 1
fi
