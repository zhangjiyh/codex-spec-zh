#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && -d "$1" ]]; then
  ROOT="$1"
  shift
fi

usage() {
  cat <<HELP
用法:
  repo-map.sh [ROOT] [关键词...]

说明:
  - 不传关键词时，输出最小扫描建议。
  - 传入关键词时，直接在 ROOT 下做代码搜索，便于填写《代码库地图.md》。
  - 第一个参数如果是目录，会把它当作 ROOT；否则默认在当前目录扫描。
HELP
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -eq 0 ]]; then
  echo "# 代码库地图最小扫描建议"
  echo
  echo "1. 查看文件列表:"
  echo "   rg --files \"$ROOT\" | head -n 200"
  echo "2. 搜索关键实现:"
  echo "   rg -n \"<关键词>\" \"$ROOT\""
  echo "3. 只看前几层目录:"
  echo "   tree -L 3 \"$ROOT\" 2>/dev/null"
  exit 0
fi

pattern="$*"
echo "# 搜索: $pattern"
echo
rg -n --hidden --glob '!.git' --glob '!node_modules' --glob '!dist' --glob '!build' "$pattern" "$ROOT"
