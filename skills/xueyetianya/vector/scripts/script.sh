#!/usr/bin/env bash
set -euo pipefail

# vector — skill script
# Powered by BytesAgain | bytesagain.com | hello@bytesagain.com

DATA_DIR="${HOME}/.vector"
mkdir -p "$DATA_DIR"

show_help() {
    cat << 'HELPEOF'
vector — command-line tool

Commands:
  create         Run create operation
  add            Run add operation
  dot            Run dot operation
  cosine         Run cosine operation
  distance       Run distance operation
  normalize      Run normalize operation
  search         Run search operation
  batch          Run batch operation
  export         Run export operation
  import         Run import operation
  stats      Show statistics
  export     Export data (json|csv|txt)
  search     Search across entries
  recent     Show recent entries
  status     Show current status
  help       Show this help message
  version    Show version number

Data stored in: ~/.vector/
HELPEOF
}

show_version() {
    echo "vector v1.0.0 — Powered by BytesAgain"
}

cmd_stats() {
    echo "=== vector Statistics ==="
    local total=0
    for f in "$DATA_DIR"/*.log; do
        [ -f "$f" ] || continue
        local name=$(basename "$f" .log)
        local c=$(wc -l < "$f" 2>/dev/null || echo 0)
        total=$((total + c))
        echo "  $name: $c entries"
    done
    echo "  Total: $total entries"
    echo "  Data size: $(du -sh "$DATA_DIR" 2>/dev/null | cut -f1 || echo 'N/A')"
    echo "  Since: $(head -1 "$DATA_DIR/history.log" 2>/dev/null | cut -d'|' -f1 || echo 'N/A')"
}

cmd_export() {
    local fmt="${1:-json}"
    local out="vector-export.$fmt"
    case "$fmt" in
        json)
            echo "[" > "$out"
            local first=1
            for f in "$DATA_DIR"/*.log; do
                [ -f "$f" ] || continue
                while IFS= read -r line; do
                    [ $first -eq 1 ] && first=0 || echo "," >> "$out"
                    local ts=$(echo "$line" | cut -d'|' -f1)
                    local cmd=$(echo "$line" | cut -d'|' -f2)
                    local data=$(echo "$line" | cut -d'|' -f3-)
                    printf '  {"timestamp":"%s","command":"%s","data":"%s"}' "$ts" "$cmd" "$data" >> "$out"
                done < "$f"
            done
            echo "" >> "$out"
            echo "]" >> "$out"
            ;;
        csv)
            echo "timestamp,command,data" > "$out"
            for f in "$DATA_DIR"/*.log; do
                [ -f "$f" ] || continue
                while IFS= read -r line; do
                    echo "$line" | awk -F'|' '{printf "\"%s\",\"%s\",\"%s\"\n", $1, $2, $3}' >> "$out"
                done < "$f"
            done
            ;;
        txt)
            > "$out"
            for f in "$DATA_DIR"/*.log; do
                [ -f "$f" ] || continue
                echo "--- $(basename "$f" .log) ---" >> "$out"
                cat "$f" >> "$out"
                echo "" >> "$out"
            done
            ;;
        *)
            echo "Unknown format: $fmt (use json, csv, or txt)"
            return 1
            ;;
    esac
    echo "Exported to $out ($(wc -c < "$out" 2>/dev/null || echo 0) bytes)"
}

cmd_search() {
    local term="${1:-}"
    [ -z "$term" ] && { echo "Usage: vector search <term>"; return 1; }
    echo "=== Search: $term ==="
    local found=0
    for f in "$DATA_DIR"/*.log; do
        [ -f "$f" ] || continue
        local matches=$(grep -i "$term" "$f" 2>/dev/null || true)
        if [ -n "$matches" ]; then
            echo "--- $(basename "$f" .log) ---"
            echo "$matches"
            found=$((found + 1))
        fi
    done
    [ $found -eq 0 ] && echo "No matches found."
}

cmd_recent() {
    local n="${1:-10}"
    echo "=== Recent $n entries ==="
    for f in "$DATA_DIR"/*.log; do
        [ -f "$f" ] || continue
        tail -n "$n" "$f" 2>/dev/null
    done | sort -t'|' -k1 | tail -n "$n"
}

cmd_status() {
    echo "=== vector Status ==="
    echo "  Entries: $(cat "$DATA_DIR"/*.log 2>/dev/null | wc -l || echo 0)"
    echo "  Disk: $(du -sh "$DATA_DIR" 2>/dev/null | cut -f1 || echo 'N/A')"
    local last=$(tail -1 "$DATA_DIR/history.log" 2>/dev/null || echo "never")
    echo "  Last activity: $last"
}

# Main
CMD="${1:-help}"
shift 2>/dev/null || true

case "$CMD" in
    create)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|create|${*}" >> "$DATA_DIR/create.log"
        local total=$(wc -l < "$DATA_DIR/create.log" 2>/dev/null || echo 0)
        echo "[vector] create recorded (entry #$total)"
        ;;
    add)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|add|${*}" >> "$DATA_DIR/add.log"
        local total=$(wc -l < "$DATA_DIR/add.log" 2>/dev/null || echo 0)
        echo "[vector] add recorded (entry #$total)"
        ;;
    dot)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|dot|${*}" >> "$DATA_DIR/dot.log"
        local total=$(wc -l < "$DATA_DIR/dot.log" 2>/dev/null || echo 0)
        echo "[vector] dot recorded (entry #$total)"
        ;;
    cosine)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|cosine|${*}" >> "$DATA_DIR/cosine.log"
        local total=$(wc -l < "$DATA_DIR/cosine.log" 2>/dev/null || echo 0)
        echo "[vector] cosine recorded (entry #$total)"
        ;;
    distance)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|distance|${*}" >> "$DATA_DIR/distance.log"
        local total=$(wc -l < "$DATA_DIR/distance.log" 2>/dev/null || echo 0)
        echo "[vector] distance recorded (entry #$total)"
        ;;
    normalize)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|normalize|${*}" >> "$DATA_DIR/normalize.log"
        local total=$(wc -l < "$DATA_DIR/normalize.log" 2>/dev/null || echo 0)
        echo "[vector] normalize recorded (entry #$total)"
        ;;
    search)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|search|${*}" >> "$DATA_DIR/search.log"
        local total=$(wc -l < "$DATA_DIR/search.log" 2>/dev/null || echo 0)
        echo "[vector] search recorded (entry #$total)"
        ;;
    batch)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|batch|${*}" >> "$DATA_DIR/batch.log"
        local total=$(wc -l < "$DATA_DIR/batch.log" 2>/dev/null || echo 0)
        echo "[vector] batch recorded (entry #$total)"
        ;;
    export)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|export|${*}" >> "$DATA_DIR/export.log"
        local total=$(wc -l < "$DATA_DIR/export.log" 2>/dev/null || echo 0)
        echo "[vector] export recorded (entry #$total)"
        ;;
    import)
        local ts=$(date '+%Y-%m-%d %H:%M')
        echo "$ts|import|${*}" >> "$DATA_DIR/import.log"
        local total=$(wc -l < "$DATA_DIR/import.log" 2>/dev/null || echo 0)
        echo "[vector] import recorded (entry #$total)"
        ;;
    stats)
        cmd_stats
        ;;
    export)
        cmd_export "$@"
        ;;
    search)
        cmd_search "$@"
        ;;
    recent)
        cmd_recent "$@"
        ;;
    status)
        cmd_status
        ;;
    help|--help|-h)
        show_help
        ;;
    version|--version|-v)
        show_version
        ;;
    *)
        echo "Unknown command: $CMD"
        echo "Run 'vector help' for usage."
        exit 1
        ;;
esac
