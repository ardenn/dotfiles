#!/bin/bash
# Test: echo '{"model":{"display_name":"Opus 5.5"},"workspace":{"current_dir":"'$HOME'/boondocks"},"context_window":{"used_percentage":25,"context_window_size":200000}}' | bash ~/.claude/statusline-command.sh
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "?"')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

cost_s=$(printf '$%.2f' "$cost")

# Prompt segment mirroring starship: [directory] git_branch
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$PWD
dir=${cwd/#$HOME/\~}
# Starship-style truncation to the last 3 components
if [ "$(echo "$dir" | awk -F/ '{print NF}')" -gt 3 ]; then
  dir=$(echo "$dir" | awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$NF}')
fi
# Nerd Font icons (same font as the git branch glyph)
I_DIR=$(printf ''); I_MODEL=$(printf ''); I_COST=$(printf '')
I_CTX=$(printf ''); I_USAGE=$(printf ''); I_TOK=$(printf '')
# 10-cell progress bar for a percentage: bar <pct>
bar() {
  local p=$1 f i s=""
  [ "$p" -gt 100 ] && p=100
  f=$(( (p + 5) / 10 ))
  for ((i = 0; i < 10; i++)); do [ "$i" -lt "$f" ] && s="$s█" || s="$s░"; done
  printf '%s' "$s"
}
prompt=$(printf '[\033[36m%s %s\033[0m]' "$I_DIR" "$dir")
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
[ -n "$branch" ] && prompt="$prompt $(printf '\033[35m\xee\x9c\xa5 %s\033[0m' "$branch")"

out="$prompt $(printf '\033[2m│\033[0m \033[36m%s %s\033[0m | \033[35m%s %s\033[0m' "$I_MODEL" "$model" "$I_COST" "$cost_s")"

# Format a token count as k/M (e.g. 200000 -> 200k, 1000000 -> 1M, 1500000 -> 1.5M)
fmt_tok() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) { v = n/1000000; s = sprintf("%.1f", v); sub(/\.0$/, "", s); print s "M" }
    else if (n >= 1000) { printf "%dk\n", n/1000 }
    else print n }'
}
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
size_s=""
if [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
  size_s=" of $(fmt_tok "$ctx_size")"
fi

if [ -n "$pct" ]; then
  p=$(printf '%.0f' "$pct")
  # Traffic lights, strict on small conversations: green <20, yellow <40, red otherwise
  if [ "$p" -lt 20 ]; then c=32; elif [ "$p" -lt 40 ]; then c=33; else c=31; fi
  out="$out | $(printf '\033[%sm%s %s %s%%\033[0m\033[2m%s ctx\033[0m' "$c" "$I_CTX" "$(bar "$p")" "$p" "$size_s")"
else
  out="$out | $(printf '\033[2m%s %s 0%%%s ctx\033[0m' "$I_CTX" "$(bar 0)" "$size_s")"
fi

# Usage: plan rate limits when present, otherwise session token counts
tl() { if [ "$1" -lt 20 ]; then echo 32; elif [ "$1" -lt 40 ]; then echo 33; else echo 31; fi; }
usage=""
for w in five_hour:5h seven_day:7d; do
  key=${w%%:*}; label=${w##*:}
  up=$(echo "$input" | jq -r ".rate_limits.$key.used_percentage // empty")
  [ -z "$up" ] && continue
  ur=$(echo "$input" | jq -r ".rate_limits.$key.resets_at // empty")
  u=$(printf '%.0f' "$up")
  seg=$(printf '\033[%sm%s %s %s %s%%\033[0m' "$(tl "$u")" "$I_USAGE" "$label" "$(bar "$u")" "$u")
  [ -n "$ur" ] && seg="$seg$(printf '\033[2m (resets %s)\033[0m' "$(date -d "@$ur" +"$([ "$key" = seven_day ] && echo '%a %H:%M' || echo %H:%M)" 2>/dev/null)")"
  usage="${usage:+$usage }$seg"
done
if [ -z "$usage" ]; then
  tin=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
  tout=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
  [ -n "$tin" ] && usage=$(printf '\033[2m%s %sk in / %sk out\033[0m' "$I_TOK" "$((tin / 1000))" "$(( ${tout:-0} / 1000 ))")
fi
[ -n "$usage" ] && out="$out | $usage"
printf '%s' "$out"
