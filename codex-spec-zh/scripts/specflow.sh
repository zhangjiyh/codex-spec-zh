#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="${SPECFLOW_ROOT:-$(pwd)}"
BASE_DIR="$PROJECT_ROOT/.codex/specflow"
TASKS_DIR="$BASE_DIR/tasks"
ARCHIVE_DIR="$BASE_DIR/archive"
TRASH_DIR="$BASE_DIR/trash"
ACTIVE_FILE="$BASE_DIR/ACTIVE_TASK"
INDEX_FILE="$BASE_DIR/index.md"

now() {
  date '+%Y-%m-%d %H:%M:%S'
}

error() {
  echo "[specflow] $*" >&2
  exit 1
}

sanitize_title() {
  local raw="$*"
  raw="$(printf '%s' "$raw" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//; s/:/ -/g')"
  printf '%s' "$raw"
}

path_labelify() {
  local input="$*"
  input="$(printf '%s' "$input" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s#[][(){}<>:"/\\|?*]#-#g; s/^-+//; s/-+$//; s/^ //; s/ $//')"
  if [[ -z "$input" ]]; then
    input="task"
  fi
  printf '%s' "$input"
}

doc_filename() {
  local kind="$1"
  case "$kind" in
    spec) echo "任务说明.md" ;;
    plan) echo "执行计划.md" ;;
    progress) echo "进度记录.md" ;;
    acceptance) echo "验收记录.md" ;;
    *) error "未知文档类型: $kind" ;;
  esac
}

legacy_doc_filename() {
  local kind="$1"
  case "$kind" in
    spec) echo "spec.md" ;;
    plan) echo "plan.md" ;;
    progress) echo "progress.md" ;;
    acceptance) echo "acceptance.md" ;;
    *) error "未知文档类型: $kind" ;;
  esac
}

doc_path() {
  local dir="$1"
  local kind="$2"
  local preferred legacy
  preferred="$dir/$(doc_filename "$kind")"
  legacy="$dir/$(legacy_doc_filename "$kind")"
  if [[ -f "$preferred" ]]; then
    echo "$preferred"
  else
    echo "$legacy"
  fi
}

rename_doc_to_cn_if_needed() {
  local dir="$1"
  local kind="$2"
  local preferred legacy
  preferred="$dir/$(doc_filename "$kind")"
  legacy="$dir/$(legacy_doc_filename "$kind")"

  if [[ -f "$preferred" && -f "$legacy" ]]; then
    error "任务目录中同时存在 $preferred 与 $legacy，请先手动处理冲突"
  fi

  if [[ ! -f "$preferred" && -f "$legacy" ]]; then
    mv "$legacy" "$preferred"
  fi
}

require_init() {
  [[ -d "$BASE_DIR" ]] || error "未初始化。先执行: specflow.sh init"
}

meta_get() {
  local file="$1"
  local key="$2"
  [[ -f "$file" ]] || return 0
  awk -v k="$key" -F': ' '$1==k {print substr($0, length(k)+3); exit}' "$file"
}

meta_set() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$value" '
    BEGIN { done=0 }
    {
      if ($1 == k ":") {
        print k ": " v
        done=1
      } else {
        print $0
      }
    }
    END {
      if (done==0) {
        print k ": " v
      }
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

refresh_index() {
  mkdir -p "$BASE_DIR"
  {
    echo "# SpecFlow 任务索引"
    echo
    echo "- 更新时间: $(now)"
    if [[ -s "$ACTIVE_FILE" ]]; then
      echo "- ACTIVE_TASK: $(cat "$ACTIVE_FILE")"
    else
      echo "- ACTIVE_TASK: (none)"
    fi
    echo

    render_bucket "进行中任务（tasks）" "$TASKS_DIR"
    render_bucket "已归档任务（archive）" "$ARCHIVE_DIR"
    render_bucket "回收站（trash）" "$TRASH_DIR"
  } > "$INDEX_FILE"
}

render_bucket() {
  local title="$1"
  local bucket="$2"
  echo "## $title"
  echo
  echo "| ID | 标题 | 状态 | 更新时间 |"
  echo "| --- | --- | --- | --- |"

  local found=0
  if [[ -d "$bucket" ]]; then
    local d
    for d in "$bucket"/*; do
      [[ -d "$d" ]] || continue
      local meta="$d/meta.yaml"
      local id title_v status updated
      id="$(meta_get "$meta" "id")"
      title_v="$(meta_get "$meta" "title")"
      status="$(meta_get "$meta" "status")"
      updated="$(meta_get "$meta" "updated_at")"
      echo "| ${id:--} | ${title_v:--} | ${status:--} | ${updated:--} |"
      found=1
    done
  fi

  if [[ "$found" -eq 0 ]]; then
    echo "| - | - | - | - |"
  fi
  echo
}

find_task_dir() {
  local id="$1"
  local d
  for d in "$TASKS_DIR"/"$id"-* "$ARCHIVE_DIR"/"$id"-* "$TRASH_DIR"/"$id"-*; do
    if [[ -d "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  return 1
}

find_task_dir_in_bucket() {
  local bucket="$1"
  local id="$2"
  local d
  for d in "$bucket"/"$id"-*; do
    if [[ -d "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  return 1
}

next_id() {
  local day max seq base
  day="$(date '+%Y%m%d')"
  max=0
  local d
  for d in "$TASKS_DIR"/T"$day"-* "$ARCHIVE_DIR"/T"$day"-* "$TRASH_DIR"/T"$day"-*; do
    [[ -d "$d" ]] || continue
    base="$(basename "$d")"
    seq="$(printf '%s' "$base" | sed -E 's/^T[0-9]{8}-([0-9]{3}).*$/\1/')"
    if [[ "$seq" =~ ^[0-9]{3}$ ]]; then
      if (( 10#$seq > max )); then
        max=$((10#$seq))
      fi
    fi
  done
  printf 'T%s-%03d' "$day" "$((max+1))"
}

copy_templates() {
  local target_dir="$1"
  cp "$SKILL_DIR/references/spec.template.md" "$target_dir/$(doc_filename spec)"
  cp "$SKILL_DIR/references/plan.template.md" "$target_dir/$(doc_filename plan)"
  cp "$SKILL_DIR/references/progress.template.md" "$target_dir/$(doc_filename progress)"
  cp "$SKILL_DIR/references/acceptance.template.md" "$target_dir/$(doc_filename acceptance)"
}

cmd_init() {
  mkdir -p "$TASKS_DIR" "$ARCHIVE_DIR" "$TRASH_DIR"
  [[ -f "$ACTIVE_FILE" ]] || : > "$ACTIVE_FILE"
  refresh_index
  echo "[specflow] 初始化完成: $BASE_DIR"
}

cmd_new() {
  require_init
  [[ $# -ge 1 ]] || error "用法: specflow.sh new <任务标题>"

  local title_raw title id path_label task_dir ts
  title_raw="$*"
  title="$(sanitize_title "$title_raw")"
  id="$(next_id)"
  path_label="$(path_labelify "$title")"
  task_dir="$TASKS_DIR/${id}-${path_label}"
  ts="$(now)"

  mkdir -p "$task_dir"
  copy_templates "$task_dir"

  cat > "$task_dir/meta.yaml" <<META
id: $id
title: $title
slug: $path_label
path_label: $path_label
status: todo
project_root: $PROJECT_ROOT
created_at: $ts
updated_at: $ts
current_step: 0
next_action: 完成 任务说明.md 与 执行计划.md
archive_reason:
META

  if [[ ! -s "$ACTIVE_FILE" ]]; then
    echo "$id" > "$ACTIVE_FILE"
    meta_set "$task_dir/meta.yaml" "status" "in_progress"
    meta_set "$task_dir/meta.yaml" "updated_at" "$(now)"
  fi

  refresh_index
  echo "[specflow] 已创建任务: $id"
  echo "[specflow] 目录: $task_dir"
}

cmd_list() {
  require_init
  refresh_index
  cat "$INDEX_FILE"
}

cmd_status() {
  require_init
  if [[ ! -s "$ACTIVE_FILE" ]]; then
    echo "[specflow] 当前无 ACTIVE_TASK"
    echo "[specflow] 先执行: specflow.sh new \"任务标题\" 或 specflow.sh switch <TASK_ID>"
    return 0
  fi

  local id dir meta
  id="$(cat "$ACTIVE_FILE")"
  dir="$(find_task_dir "$id" || true)"
  [[ -n "$dir" ]] || error "ACTIVE_TASK=$id 但找不到任务目录"
  meta="$dir/meta.yaml"

  echo "[specflow] ACTIVE_TASK: $id"
  echo "[specflow] 目录: $dir"
  echo "[specflow] 标题: $(meta_get "$meta" "title")"
  echo "[specflow] 状态: $(meta_get "$meta" "status")"
  echo "[specflow] 当前步骤: $(meta_get "$meta" "current_step")"
  echo "[specflow] 下一动作: $(meta_get "$meta" "next_action")"
  echo "[specflow] 文档:"
  echo "  - $(doc_path "$dir" spec)"
  echo "  - $(doc_path "$dir" plan)"
  echo "  - $(doc_path "$dir" progress)"
  echo "  - $(doc_path "$dir" acceptance)"
}

cmd_switch() {
  require_init
  [[ $# -eq 1 ]] || error "用法: specflow.sh switch <TASK_ID>"
  local target_id target_dir current_id current_dir
  target_id="$1"
  target_dir="$(find_task_dir_in_bucket "$TASKS_DIR" "$target_id" || true)"
  [[ -n "$target_dir" ]] || error "在 tasks 中未找到任务: $target_id"

  current_id="$(cat "$ACTIVE_FILE" 2>/dev/null || true)"
  if [[ -n "$current_id" && "$current_id" != "$target_id" ]]; then
    current_dir="$(find_task_dir_in_bucket "$TASKS_DIR" "$current_id" || true)"
    if [[ -n "$current_dir" ]]; then
      meta_set "$current_dir/meta.yaml" "status" "todo"
      meta_set "$current_dir/meta.yaml" "updated_at" "$(now)"
    fi
  fi

  echo "$target_id" > "$ACTIVE_FILE"
  meta_set "$target_dir/meta.yaml" "status" "in_progress"
  meta_set "$target_dir/meta.yaml" "updated_at" "$(now)"

  refresh_index
  echo "[specflow] 已切换 ACTIVE_TASK -> $target_id"
}

cmd_archive() {
  require_init
  local id reason dir base
  if [[ $# -ge 1 ]]; then
    id="$1"
    shift
  else
    id="$(cat "$ACTIVE_FILE" 2>/dev/null || true)"
  fi
  [[ -n "$id" ]] || error "用法: specflow.sh archive <TASK_ID> [原因]"
  reason="${*:-用户归档}"

  dir="$(find_task_dir_in_bucket "$TASKS_DIR" "$id" || true)"
  [[ -n "$dir" ]] || error "在 tasks 中未找到任务: $id"

  meta_set "$dir/meta.yaml" "status" "archived"
  meta_set "$dir/meta.yaml" "archive_reason" "$reason"
  meta_set "$dir/meta.yaml" "updated_at" "$(now)"

  base="$(basename "$dir")"
  mv "$dir" "$ARCHIVE_DIR/$base"

  if [[ -s "$ACTIVE_FILE" && "$(cat "$ACTIVE_FILE")" == "$id" ]]; then
    : > "$ACTIVE_FILE"
  fi

  refresh_index
  echo "[specflow] 已归档任务: $id"
}

cmd_delete() {
  require_init
  local id dir base
  if [[ $# -eq 1 ]]; then
    id="$1"
  else
    id="$(cat "$ACTIVE_FILE" 2>/dev/null || true)"
  fi
  [[ -n "$id" ]] || error "用法: specflow.sh delete <TASK_ID>"

  dir="$(find_task_dir "$id" || true)"
  [[ -n "$dir" ]] || error "未找到任务: $id"

  base="$(basename "$dir")"
  meta_set "$dir/meta.yaml" "status" "deleted_soft"
  meta_set "$dir/meta.yaml" "updated_at" "$(now)"

  if [[ "$dir" == "$TRASH_DIR"/* ]]; then
    echo "[specflow] 任务已在 trash: $id"
  else
    mv "$dir" "$TRASH_DIR/$base"
    echo "[specflow] 已软删除任务: $id"
  fi

  if [[ -s "$ACTIVE_FILE" && "$(cat "$ACTIVE_FILE")" == "$id" ]]; then
    : > "$ACTIVE_FILE"
  fi

  refresh_index
}

cmd_restore() {
  require_init
  [[ $# -eq 1 ]] || error "用法: specflow.sh restore <TASK_ID>"
  local id dir base
  id="$1"

  dir="$(find_task_dir_in_bucket "$ARCHIVE_DIR" "$id" || true)"
  if [[ -z "$dir" ]]; then
    dir="$(find_task_dir_in_bucket "$TRASH_DIR" "$id" || true)"
  fi
  [[ -n "$dir" ]] || error "在 archive/trash 中未找到任务: $id"

  base="$(basename "$dir")"
  mv "$dir" "$TASKS_DIR/$base"
  meta_set "$TASKS_DIR/$base/meta.yaml" "status" "todo"
  meta_set "$TASKS_DIR/$base/meta.yaml" "updated_at" "$(now)"

  refresh_index
  echo "[specflow] 已恢复任务到 tasks: $id"
}

cmd_localize() {
  require_init
  local id dir base bucket meta title path_label target_dir
  if [[ $# -eq 1 ]]; then
    id="$1"
  else
    id="$(cat "$ACTIVE_FILE" 2>/dev/null || true)"
  fi
  [[ -n "$id" ]] || error "用法: specflow.sh localize [TASK_ID]"

  dir="$(find_task_dir "$id" || true)"
  [[ -n "$dir" ]] || error "未找到任务: $id"

  rename_doc_to_cn_if_needed "$dir" spec
  rename_doc_to_cn_if_needed "$dir" plan
  rename_doc_to_cn_if_needed "$dir" progress
  rename_doc_to_cn_if_needed "$dir" acceptance

  meta="$dir/meta.yaml"
  title="$(sanitize_title "$(meta_get "$meta" "title")")"
  path_label="$(path_labelify "$title")"
  bucket="$(dirname "$dir")"
  base="$(basename "$dir")"
  target_dir="$bucket/${id}-${path_label}"

  meta_set "$meta" "slug" "$path_label"
  meta_set "$meta" "path_label" "$path_label"
  meta_set "$meta" "next_action" "完成 任务说明.md 与 执行计划.md"
  meta_set "$meta" "updated_at" "$(now)"

  if [[ "$dir" != "$target_dir" ]]; then
    [[ ! -e "$target_dir" ]] || error "目标目录已存在: $target_dir"
    mv "$dir" "$target_dir"
    dir="$target_dir"
  fi

  refresh_index
  echo "[specflow] 已中文化任务: $id"
  echo "[specflow] 目录: $dir"
  echo "[specflow] 文档:"
  echo "  - $(doc_path "$dir" spec)"
  echo "  - $(doc_path "$dir" plan)"
  echo "  - $(doc_path "$dir" progress)"
  echo "  - $(doc_path "$dir" acceptance)"
}

cmd_purge() {
  require_init
  [[ $# -eq 1 ]] || error "用法: specflow.sh purge <TASK_ID>"
  local id dir
  id="$1"
  dir="$(find_task_dir_in_bucket "$TRASH_DIR" "$id" || true)"
  [[ -n "$dir" ]] || error "在 trash 中未找到任务: $id"

  rm -rf "$dir"
  refresh_index
  echo "[specflow] 已永久删除任务: $id"
}

cmd_help() {
  cat <<HELP
SpecFlow 用法:
  specflow.sh init
  specflow.sh new <任务标题>
  specflow.sh list
  specflow.sh status
  specflow.sh switch <TASK_ID>
  specflow.sh archive [TASK_ID] [原因]
  specflow.sh delete [TASK_ID]
  specflow.sh restore <TASK_ID>
  specflow.sh localize [TASK_ID]
  specflow.sh purge <TASK_ID>
  specflow.sh help

说明:
  - 任务仓库固定在 <project-root>/.codex/specflow/
  - 未提供 TASK_ID 时，archive/delete 默认使用 ACTIVE_TASK
  - 新建任务默认使用中文目录名与中文文档名
  - localize 可将旧任务的英文目录/文档名迁移为中文命名
HELP
}

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init) cmd_init "$@" ;;
    new) cmd_new "$@" ;;
    list) cmd_list "$@" ;;
    status) cmd_status "$@" ;;
    switch) cmd_switch "$@" ;;
    archive) cmd_archive "$@" ;;
    delete) cmd_delete "$@" ;;
    restore) cmd_restore "$@" ;;
    localize) cmd_localize "$@" ;;
    purge) cmd_purge "$@" ;;
    help|-h|--help) cmd_help ;;
    *) error "未知命令: $cmd（执行 specflow.sh help 查看用法）" ;;
  esac
}

main "$@"
