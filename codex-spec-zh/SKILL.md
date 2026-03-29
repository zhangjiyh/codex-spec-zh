---
name: codex-spec-zh
description: 使用 spec-repo-map-plan-progress-verification-acceptance 工作流管理 Codex 中长研发任务，支持任务新建、切换、归档、软删除与恢复；当用户提到长任务规划、跨前后端联调、里程碑验收、多项目复用、中文任务管理、文件定位与验证记录时使用。
---

# Codex SpecFlow ZH

在项目根目录使用 `.codex/specflow/` 作为唯一任务仓库。

这个中文版主要体现在：
1. 新任务默认使用中文目录名，而不是英文 slug。
2. 任务文档默认使用中文文件名。
3. 状态、索引、下一步提示优先中文表达。
4. 旧英文文件名任务继续兼容，可按需执行 `localize` 迁移。

执行长任务时遵循以下固定流程：
1. 先写 `任务说明.md`。
2. 在进入计划前，先做最小必要的 `代码库地图.md` 文件定位。
3. 再写 `执行计划.md`。
4. 一次只执行一个 step。
5. 每步执行后必须更新 `进度记录.md`，必要时补充 `验证记录.md`。
6. 阶段完成后更新 `验收记录.md`。
7. 任务完结后归档，不直接删除历史。

## 初始化与任务管理

优先使用脚本管理任务生命周期：

```bash
# 初始化仓库
bash scripts/specflow.sh init

# 新建任务
bash scripts/specflow.sh new "任务标题"

# 查看任务
bash scripts/specflow.sh list
bash scripts/specflow.sh status

# 切换任务
bash scripts/specflow.sh switch <TASK_ID>

# 归档 / 删除 / 恢复 / 永久删除
bash scripts/specflow.sh archive <TASK_ID> [原因]
bash scripts/specflow.sh delete <TASK_ID>
bash scripts/specflow.sh restore <TASK_ID>
bash scripts/specflow.sh localize <TASK_ID>
bash scripts/specflow.sh purge <TASK_ID>
```

如果用户只说“执行下一步”，先读取 `ACTIVE_TASK` 与当前任务目录，再基于 `执行计划.md`（兼容旧 `plan.md`）选择下一个未完成步骤。若当前任务尚未补齐 `代码库地图.md`，优先先完成最小必要的文件扫描与定位，再进入计划和执行。

## 执行约束

每个步骤都先输出“改动前说明”，再执行改动，最后输出“改动后结果”。

改动前说明必须包含：
1. 本步目标。
2. 预计修改文件。
3. 明确不修改的边界。
4. 风险点与回滚点。

改动后结果必须包含：
1. 实际修改文件与内容摘要。
2. 验证命令与结果摘要。
3. 与计划差异。
4. 遗留风险与下一步。

## 强制规则

1. 不跨 step 执行。
2. 不做无关重构。
3. 不升级依赖或改目录结构，除非用户明确授权。
4. 未验证通过不得标记完成。
5. 遇到冲突先写入 `进度记录.md` 的 BLOCKED，再请求决策。
6. 代码库扫描只做最小必要上下文，不做全量索引系统。

## 文件模板

按需读取以下模板并填充：
1. `references/spec.template.md`
2. `references/repo-map.template.md`
3. `references/plan.template.md`
4. `references/progress.template.md`
5. `references/verification.template.md`
6. `references/acceptance.template.md`
7. `references/checklist-vue-spring.md`

优先使用中文输出；新任务默认使用中文目录与中文文档名，旧任务兼容 `spec.md / plan.md / progress.md / acceptance.md`。如果旧任务没有 `代码库地图.md` 或 `验证记录.md`，仍可继续执行，但新任务推荐先补齐这两份文档。
