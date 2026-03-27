# 使用说明（按用户使用周期）

这份说明面向初学者，目标是让你按固定节奏使用 `codex-spec-zh`，而不是一次性把任务全丢给 AI。

## 0. 准备阶段（首次）

1. 安装 skill 到 `~/.codex/skills/codex-spec-zh`。
2. 进入你的项目根目录。
3. 初始化任务仓库：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh init
```

你会得到：

```text
.codex/specflow/
  ACTIVE_TASK
  index.md
  tasks/
    TYYYYMMDD-001-任务标题/
      meta.yaml
      任务说明.md
      执行计划.md
      进度记录.md
      验收记录.md
  archive/
  trash/
```

## 1. 需求进入阶段（每次接到新任务）

1. 新建任务：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh new "任务标题"
```

2. 在对应任务目录先完善 `任务说明.md`：
- 目标是什么
- 范围是什么
- 哪些不做
- 验收标准是什么

3. 再写 `执行计划.md`：
- 把任务拆成 Step 1/2/3
- 每步定义 DoD
- 每步写验证命令

## 2. 开发执行阶段（每日循环）

每天建议只做一个或少量 step，重复以下循环：

1. 执行前：写清“预计改哪些文件、不改哪些边界”。
2. 执行中：只做当前 step，不跨步。
3. 执行后：记录验证结果到 `进度记录.md`。

推荐命令：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh status
```

## 3. 多任务并行阶段（任务切换）

当你同时有多个需求时：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh list
~/.codex/skills/codex-spec-zh/scripts/specflow.sh switch <TASK_ID>
```

原则：
1. 只允许一个 `ACTIVE_TASK`。
2. 切换前先把当前任务写到 `进度记录.md`，避免上下文丢失。

## 4. 验收与交付阶段

1. 填写 `验收记录.md`（功能、测试、回归、遗留风险）。
2. 确认通过后归档：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh archive <TASK_ID> "验收通过"
```

## 5. 维护阶段（归档/删除/恢复）

1. 软删除（可恢复）：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh delete <TASK_ID>
```

2. 恢复：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh restore <TASK_ID>
```

3. 将旧任务迁移为中文目录与中文文档名：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh localize <TASK_ID>
```

4. 永久删除（仅 trash 中）：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh purge <TASK_ID>
```

## 新手常见问题

1. 问：可以不写 `任务说明.md` 吗？
答：短任务可以简写，但中长任务建议必须写，否则容易跑偏。

2. 问：能一次做多个 step 吗？
答：不建议。初学者最稳的方式是“一次一步+一步一验收”。

3. 问：为什么要归档而不是删除？
答：归档保留历史决策和回归记录，后续排查问题很有价值。

4. 问：旧任务还是 `spec.md` / `plan.md` 怎么办？
答：可以继续用，脚本保持兼容；如果想统一成中文命名，再执行 `specflow.sh localize <TASK_ID>`。
