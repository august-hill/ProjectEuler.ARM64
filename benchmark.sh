#!/bin/bash
# benchmark.sh - Run all Project Euler ARM64 assembly solutions
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
LANG="arm64"
OUTPUT="${REPO_DIR}/benchmark_results.json"

while [[ $# -gt 0 ]]; do
    case $1 in
        --problems) PROBLEMS="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

PLATFORM=$(uname -m)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

PROB_LIST=()
for d in "$REPO_DIR"/problem_*/; do
    [ -d "$d" ] || continue
    num=$(basename "$d" | sed 's/problem_//')
    PROB_LIST+=("$num")
done

IFS=$'\n' PROB_LIST=($(sort <<<"${PROB_LIST[*]}")); unset IFS

PASS=0; FAIL=0
RESULTS="["

for p in "${PROB_LIST[@]}"; do
    DIR="$REPO_DIR/problem_${p}"
    [ -f "$DIR/main.c" ] || continue

    cd "$DIR"

    # Compile: assembly + C if solve.s exists, C-only otherwise
    if [ -f solve.s ]; then
        if ! as -o solve.o solve.s 2>/dev/null; then
            echo "  FAIL $p: assembly error"
            RESULTS+=$(printf '{"problem":"%s","status":"fail","reason":"assembly error"},' "$p")
            FAIL=$((FAIL+1)); continue
        fi
        if ! cc -O2 -o main_bench main.c solve.o -lm 2>/dev/null; then
            echo "  FAIL $p: link error"
            RESULTS+=$(printf '{"problem":"%s","status":"fail","reason":"link error"},' "$p")
            FAIL=$((FAIL+1)); continue
        fi
    else
        if ! cc -O2 -o main_bench main.c -lm 2>/dev/null; then
            echo "  FAIL $p: compile error"
            RESULTS+=$(printf '{"problem":"%s","status":"fail","reason":"compile error"},' "$p")
            FAIL=$((FAIL+1)); continue
        fi
    fi

    # Run
    LINE=$(./main_bench 2>/dev/null | grep "^BENCHMARK|" || true)
    if [ -z "$LINE" ]; then
        echo "  FAIL $p: no output or timeout"
        RESULTS+=$(printf '{"problem":"%s","status":"fail","reason":"timeout or no output"},' "$p")
        FAIL=$((FAIL+1)); continue
    fi

    ANSWER=$(echo "$LINE" | sed 's/.*answer=\([^|]*\).*/\1/')
    TIME_NS=$(echo "$LINE" | sed 's/.*time_ns=\([^|]*\).*/\1/')
    ITERS=$(echo "$LINE" | sed 's/.*iterations=\([^|]*\).*/\1/')
    echo "  PASS $p: answer=$ANSWER time=${TIME_NS}ns"
    RESULTS+=$(printf '{"problem":"%s","status":"pass","answer":%s,"time_ns":%s,"iterations":%s},' "$p" "$ANSWER" "$TIME_NS" "$ITERS")
    PASS=$((PASS+1))
done

RESULTS="${RESULTS%,}]"
cat > "$OUTPUT" <<JEOF
{"language":"$LANG","platform":"$PLATFORM","timestamp":"$TIMESTAMP","results":$RESULTS}
JEOF

echo ""
echo "Results: $PASS passed, $FAIL failed"
echo "Written to: $OUTPUT"
