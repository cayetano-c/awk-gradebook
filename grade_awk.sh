#!/usr/bin/env bash
set -u
REPONAME="awk-gradebook"; DATA_NAME="Lab03-data.csv"
REF=""; CSV=""; STUDENTS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)      REF="$2"; shift 2;;
    --csv)      CSV="$2"; shift 2;;
    --reponame) REPONAME="$2"; shift 2;;
    -f|--file)  while IFS= read -r ln; do ln="${ln%%#*}"; ln="$(echo "$ln" | xargs)"; [ -n "$ln" ] && STUDENTS+=("$ln"); done < "$2"; shift 2;;
    -*)         echo "Unknown option: $1"; exit 1;;
    *)          STUDENTS+=("$1"); shift;;
  esac
done
if [ -z "$REF" ] && [ -f "$DATA_NAME" ]; then REF="$DATA_NAME"; fi
if [ -z "$REF" ] || [ ! -f "$REF" ]; then echo "Error: Reference data file '$DATA_NAME' not found."; exit 1; fi
norm() { tr -d '\r' | awk '{$1=$1;print}' | grep -v '^$'; }
nsort() { norm | sort -f; }
add() { awk "BEGIN {print $1 + $2}"; }
sub2() { awk "BEGIN {print $1 - $2}"; }
E1=$(awk -F',' 'NR>1{c++} END{print c}' "$REF")
E2=$(awk -F',' 'NR>1 && !seen[$1]++{n++} END{print n}' "$REF")
E3=$(awk -F',' '$3=="FINAL"{printf "%-10s %3d\n",$1,$4}' "$REF")
E4=$(awk -F',' 'NR>1 && $4 < 0.6*$5 {c++} END{print c}' "$REF")
E5=$(awk -F',' 'NR>1 { s[$3]+=$4; n[$3]++; if(!($3 in lo)||$4<lo[$3]) lo[$3]=$4; if(!($3 in hi)||$4>hi[$3]) hi[$3]=$4 } END { printf "%-8s %5s %5s %9s\n","Name","Low","High","Average"; for(a in s) printf "%-8s %5d %5d %9.2f\n",a,lo[a],hi[a],s[a]/n[a] }' "$REF")
E6=$(awk -F',' 'NR>1{ e[$1]+=$4; p[$1]+=$5 } END{ for(st in e){ if(p[st]>0){ pct=100*e[st]/p[st]; if(pct>=90)g="A";else if(pct>=80)g="B";else if(pct>=70)g="C";else if(pct>=60)g="D";else g="E"; printf "%-10s %7.2f %s\n",st,pct,g } } }' "$REF")
E7=$(printf "%-10s %7s %s\n" "Name" "Percent" "Letter"; echo "$E6" | sort -f)
extract_cmd() {
  local f="$1" t="$2"
  awk -v t="$t" '
    BEGIN { IGNORECASE=1; found=0 }
    $0 ~ "^##[[:space:]]*(Task|Bonus)[[:space:]]*" t { found=1; next }
    found && /^##/ { exit }
    found && /^[[:space:]]*Command:[[:space:]]*/ { sub(/^[[:space:]]*Command:[[:space:]]*/, ""); print; exit }
  ' "$f"
}
grade_one() {
  local target="$1"; local tmp; tmp=$(mktemp -d); local SRC="$target"; local sid="."
  if [[ "$target" =~ ^(https://|git@) ]] || [ ! -d "$target" ]; then
    local url="$target"
    if [[ ! "$url" =~ ^(https://|git@) ]]; then
      if [[ "$url" =~ / ]]; then url="https://codeberg.org/$url"; else url="https://codeberg.org/$url/$REPONAME"; fi
    fi
    sid=$(basename "$(dirname "$url")")
    git clone --quiet "$url" "$tmp/repo" &>/dev/null
    if [ $? -ne 0 ]; then
      printf '============================================================\n'
      printf 'STUDENT: %s   SOURCE: %s   TOTAL: 0.00/4.00\n' "$sid" "$target"
      printf '  - Error: Could not clone repository.\n============================================================\n\n'
      rm -rf "$tmp"; return
    fi
    SRC="$tmp/repo"
  fi
  local ANS="$SRC/answers.md"
  if [ ! -f "$ANS" ]; then
    printf '============================================================\n'
    printf 'STUDENT: %s   SOURCE: %s   TOTAL: 0.00/4.00\n' "$sid" "$target"
    printf '  - Error: answers.md not found in the repository root.\n============================================================\n\n'
    rm -rf "$tmp"; return
  fi
  local TOTAL=0.00; local DED=(); local ROWS=(); local TPTS=(0 0 0 0 0 0 0)
  cp "$REF" "$SRC/$DATA_NAME"; cd "$SRC" || exit
  for t in {1..7}; do
    local cmd; cmd=$(extract_cmd "$ANS" "$t")
    if [ -z "$cmd" ]; then
      DED+=("Task $t: -0.40 - command not found in answers.md under '## Task $t'.")
      ROWS+=("Task $t correctness|0.00|0.40"); continue
    fi
    local got; got=$(timeout 20s bash -c "$cmd" 2>/dev/null); local status=$?
    local exp; eval "exp=\$E$t"
    if [ "$status" -ne 0 ]; then
      DED+=("Task $t: -0.40 - command failed to run or timed out.")
      ROWS+=("Task $t correctness|0.00|0.40")
    else
      # EL TRUCO GANADOR DE LA PURIFICACIÓN DE ESPACIOS
      g="$(printf '%s\n' "$got" | nsort | norm)"; e="$(printf '%s\n' "$exp" | nsort | norm)"
      if [ "$g" = "$e" ]; then
        TOTAL=$(add "$TOTAL" 0.40); TPTS[$((t-1))]=0.40; ROWS+=("Task $t correctness|0.40|0.40")
      else
        DED+=("Task $t: -0.20 - the produced table does not match the expected values.")
        TOTAL=$(add "$TOTAL" 0.20); TPTS[$((t-1))]=0.20; ROWS+=("Task $t correctness|0.20|0.40")
      fi
    fi
  done
  local doc=0.60; local dnote=""
  for t in {1..7}; do
    if ! grep -qE "^##[[:space:]]*(Task|Bonus)[[:space:]]*$t" "$ANS"; then doc=0.00; dnote="missing Task $t block;"; break; fi
    if ! extract_cmd "$ANS" "$t" &>/dev/null; then doc=0.00; dnote="missing Command line;"; break; fi
    if ! awk -v t="$t" 'BEGIN{IGNORECASE=1;f=0} $0~"^##[[:space:]]*(Task|Bonus)[[:space:]]*"t{f=1;next} f&&/^##/{exit} f&&/^[[:space:]]*Result:/{f=2} END{if(f==2)exit 0; exit 1}' "$ANS"; then doc=0.00; dnote="missing Result line;"; break; fi
    if ! awk -v t="$t" 'BEGIN{IGNORECASE=1;f=0} $0~"^##[[:space:]]*(Task|Bonus)[[:space:]]*"t{f=1;next} f&&/^##/{exit} f&&/^[[:space:]]*Explanation:/{f=2} END{if(f==2)exit 0; exit 1}' "$ANS"; then doc=0.00; dnote="missing Explanation line;"; break; fi
  done
  ROWS+=("Documentation (answers.md)|$doc|0.60")
  [ -n "$dnote" ] && DED+=("Documentation: -$(sub2 0.60 "$doc") - $dnote")
  TOTAL=$(add "$TOTAL" "$doc")
  local repo_pts=0.40; local rnote=""
  if [ -d .git ]; then
    local cc; cc=$(git rev-list --count HEAD 2>/dev/null || echo 0)
    if [ "$cc" -lt 3 ]; then repo_pts=0.10; rnote="requires >=3 commits (found $cc);"; fi
  else
    repo_pts=0.00; rnote="not a git repository;";
  fi
  ROWS+=("Repository & commits|$repo_pts|0.40")
  [ -n "$rnote" ] && DED+=("Repository & commits: -$(sub2 0.40 "$repo_pts") -$rnote")
  TOTAL=$(add "$TOTAL" "$repo_pts")
  local tech=0.00; local tnote=""; local n_awk=0; local hdr_ok=0
  local allcmd=""; for t in {1..7}; do allcmd="$allcmd $(extract_cmd "$ANS" "$t")"; done
  local catawk=""
  for f in *.awk; do
    [ -f "$f" ] || continue
    n_awk=$((n_awk+1)); catawk="$catawk $(cat "$f")"
    if head -n 1 "$f" | grep -qE '^[[:space:]]*#'; then hdr_ok=$((hdr_ok+1)); fi
  done
  if [ "$n_awk" -gt 0 ] && [ "$hdr_ok" -eq "$n_awk" ]; then tech=$(add "$tech" 0.10); else tnote="$tnote .awk scripts must start with a comment header ($hdr_ok/$n_awk ok);"; fi
  if grep -qE "(-F|FS[[:space:]]*=)" <<<"$allcmd$catawk" && grep -qE 'printf' <<<"$allcmd$catawk"; then tech=$(add "$tech" 0.10); else tnote="$tnote use FS (-F or FS=) and printf;"; fi
  ROWS+=("awk technique|$tech|0.20")
  [ -n "$tnote" ] && DED+=("awk technique: -$(sub2 0.20 "$tech") -$tnote")
  TOTAL=$(add "$TOTAL" "$tech")
  printf '============================================================\n'
  printf 'STUDENT: %s   SOURCE: %s   TOTAL: %s/4.00\n' "$sid" "$SRC" "$TOTAL"
  printf -- '------------------------------------------------------------\n'
  printf 'CRITERION|POINTS|MAX\n'
  printf '%s\n' "${ROWS[@]}"
  printf -- '------------------------------------------------------------\n'
  printf 'DEDUCTIONS (why points were lost):\n'
  if [ "${#DED[@]}" -eq 0 ]; then printf '  None - full marks (4.00/4.00).\n'; else printf '  - %s\n' "${DED[@]}"; fi
  printf '============================================================\n\n'
  cd "$tmp" || exit; rm -rf "$tmp"
}
if [ ${#STUDENTS[@]} -eq 0 ]; then grade_one "."; else for s in "${STUDENTS[@]}"; do grade_one "$s"; done; fi
