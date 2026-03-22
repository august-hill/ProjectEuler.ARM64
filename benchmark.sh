#!/usr/bin/env bash
# benchmark.sh - Run all Project Euler ARM64 assembly solutions and collect benchmark data
# Usage: ./benchmark.sh [--problems 1,2,3] [--output results.json]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
LANG="arm64"
CC="${CC:-clang}"
OUTPUT="${REPO_DIR}/benchmark_results.json"
PROBLEMS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --problems) PROBLEMS="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

if [ -n "$PROBLEMS" ]; then
    IFS=',' read -ra PROB_LIST <<< "$PROBLEMS"
else
    PROB_LIST=()
    for d in "$REPO_DIR"/problem_*/; do
        [ -d "$d" ] || continue
        num=$(basename "$d" | sed 's/problem_//')
        PROB_LIST+=("$num")
    done
fi

IFS=$'\n' PROB_LIST=($(sort <<<"${PROB_LIST[*]}")); unset IFS

PLATFORM=$(uname -m)
COMPILER_VERSION=$($CC --version 2>/dev/null | head -1 || echo "unknown")
AS_VERSION=$(as --version 2>/dev/null | head -1 || echo "Apple as (macOS)")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "Project Euler ARM64 Assembly Benchmarks"
echo "========================================"
echo "Platform: $PLATFORM | Assembler: $AS_VERSION | CC: $COMPILER_VERSION"
echo "Problems: ${#PROB_LIST[@]}"
echo ""

RESULTS_JSON="{\"language\":\"$LANG\",\"platform\":\"$PLATFORM\",\"compiler\":\"$AS_VERSION + $COMPILER_VERSION\",\"timestamp\":\"$TIMESTAMP\",\"problems\":{"

FIRST=true
PASS=0
FAIL=0

for NUM in "${PROB_LIST[@]}"; do
    PROB_DIR="$REPO_DIR/problem_$NUM"

    if [ ! -f "$PROB_DIR/main.c" ]; then
        echo "  SKIP $NUM: no main.c"
        continue
    fi

    cd "$PROB_DIR"

    # Compile: assembly + C if solve.s exists, C-only otherwise
    if [ -f solve.s ]; then
        if ! as -o solve.o solve.s 2>/dev/null; then
            echo "  FAIL $NUM: assembly error"
            FAIL=$((FAIL + 1))
            if [ "$FIRST" = true ]; then FIRST=false; else RESULTS_JSON+=","; fi
            RESULTS_JSON+="\"$NUM\":{\"status\":\"fail\",\"error\":\"assembly error\"}"
            continue
        fi
        if ! $CC -O2 -o main_bench main.c solve.o -lm 2>/dev/null; then
            echo "  FAIL $NUM: link error"
            FAIL=$((FAIL + 1))
            if [ "$FIRST" = true ]; then FIRST=false; else RESULTS_JSON+=","; fi
            RESULTS_JSON+="\"$NUM\":{\"status\":\"fail\",\"error\":\"link error\"}"
            continue
        fi
    else
        if ! $CC -O2 -o main_bench main.c -lm 2>/dev/null; then
            echo "  FAIL $NUM: compile error"
            FAIL=$((FAIL + 1))
            if [ "$FIRST" = true ]; then FIRST=false; else RESULTS_JSON+=","; fi
            RESULTS_JSON+="\"$NUM\":{\"status\":\"fail\",\"error\":\"compile error\"}"
            continue
        fi
    fi

    # Run with /usr/bin/time for RSS
    TIME_OUT=$(mktemp)
    PROG_OUT=$(mktemp)

    /usr/bin/time -l ./main_bench >"$PROG_OUT" 2>"$TIME_OUT" || true

    BENCH_LINE=$(grep '^BENCHMARK|' "$PROG_OUT" 2>/dev/null || echo "")

    if [ -z "$BENCH_LINE" ]; then
        echo "  FAIL $NUM: no BENCHMARK line"
        rm -f main_bench solve.o "$TIME_OUT" "$PROG_OUT"
        FAIL=$((FAIL + 1))
        if [ "$FIRST" = true ]; then FIRST=false; else RESULTS_JSON+=","; fi
        RESULTS_JSON+="\"$NUM\":{\"status\":\"fail\",\"error\":\"no output\"}"
        continue
    fi

    ANSWER=$(echo "$BENCH_LINE" | sed 's/.*answer=\([^|]*\).*/\1/')
    TIME_NS=$(echo "$BENCH_LINE" | sed 's/.*time_ns=\([^|]*\).*/\1/')
    ITERS=$(echo "$BENCH_LINE" | sed 's/.*iterations=\([^|]*\).*/\1/')

    PEAK_RSS=$(grep "maximum resident set size" "$TIME_OUT" 2>/dev/null | awk '{print $1}' || echo "0")

    # Source metrics: count both .s and .c files
    SLOC=0; SBYTES=0
    for sf in main.c solve.s; do
        if [ -f "$sf" ]; then
            SLOC=$((SLOC + $(wc -l < "$sf" | tr -d ' ')))
            SBYTES=$((SBYTES + $(wc -c < "$sf" | tr -d ' ')))
        fi
    done

    if [ "$TIME_NS" -lt 1000 ] 2>/dev/null; then
        DISPLAY_TIME="${TIME_NS} ns"
    elif [ "$TIME_NS" -lt 1000000 ] 2>/dev/null; then
        DISPLAY_TIME="$(echo "scale=1; $TIME_NS / 1000" | bc) us"
    elif [ "$TIME_NS" -lt 1000000000 ] 2>/dev/null; then
        DISPLAY_TIME="$(echo "scale=1; $TIME_NS / 1000000" | bc) ms"
    else
        DISPLAY_TIME="$(echo "scale=2; $TIME_NS / 1000000000" | bc) s"
    fi

    echo "  $NUM: answer=$ANSWER  time=$DISPLAY_TIME  rss=${PEAK_RSS}B  sloc=$SLOC"

    if [ "$FIRST" = true ]; then FIRST=false; else RESULTS_JSON+=","; fi
    RESULTS_JSON+="\"$NUM\":{\"answer\":$ANSWER,\"time_ns\":$TIME_NS,\"iterations\":$ITERS,\"status\":\"pass\",\"peak_rss_bytes\":$PEAK_RSS,\"source_lines\":$SLOC,\"source_bytes\":$SBYTES}"

    PASS=$((PASS + 1))
    rm -f main_bench solve.o "$TIME_OUT" "$PROG_OUT"
done

RESULTS_JSON+="}}"

echo "$RESULTS_JSON" | python3 -m json.tool > "$OUTPUT" 2>/dev/null || echo "$RESULTS_JSON" > "$OUTPUT"

echo ""
echo "Results: $PASS passed, $FAIL failed"
echo "Written to: $OUTPUT"

# Generate BENCHMARKS.md
python3 -c "
import json
with open('$OUTPUT') as f:
    data = json.load(f)
lines = ['# ARM64 Assembly Benchmarks\n']
lines.append(f'Platform: {data[\"platform\"]} | Compiler: {data[\"compiler\"]} | Date: {data[\"timestamp\"][:10]}\n')
lines.append('| # | Answer | Time | Peak RSS | SLOC |')
lines.append('|---|--------|------|----------|------|')
problems = data.get('problems', {})
total_ns = 0
for prob in sorted(problems.keys()):
    p = problems[prob]
    if 'time_ns' not in p: continue
    ns = p['time_ns']
    total_ns += ns
    if ns < 1000: t = f'{ns} ns'
    elif ns < 1000000: t = f'{ns/1000:.1f} us'
    elif ns < 1000000000: t = f'{ns/1000000:.1f} ms'
    else: t = f'{ns/1000000000:.2f} s'
    rss_mb = p.get('peak_rss_bytes', 0) / (1024*1024)
    lines.append(f'| {prob} | {p[\"answer\"]} | {t} | {rss_mb:.1f} MB | {p[\"source_lines\"]} |')
lines.append(f'\n## Summary\n')
lines.append(f'- Problems benchmarked: {len([p for p in problems.values() if \"time_ns\" in p])}')
lines.append(f'- Total time: {total_ns/1e9:.2f}s')
with open('$REPO_DIR/BENCHMARKS.md', 'w') as f:
    f.write('\n'.join(lines))
print('Generated BENCHMARKS.md')
" 2>/dev/null || echo "BENCHMARKS.md generation skipped"
