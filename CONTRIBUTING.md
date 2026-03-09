# Contributing

感谢你贡献 `codex-spec-zh`。

## 贡献范围

欢迎提交：
1. 工作流改进（spec/plan/progress/acceptance）。
2. 模板增强（尤其是多语言、跨框架扩展）。
3. 脚本可靠性修复（任务生命周期命令）。
4. 文档可读性改进和示例补充。

## 开发流程

1. Fork 并创建分支（推荐 `feat/*` 或 `fix/*`）。
2. 修改后本地自测脚本：
   - `bash codex-spec-zh/scripts/specflow.sh help`
   - 在临时目录执行 `init/new/list/switch/archive/delete/restore/purge`。
3. 更新对应文档：
   - 行为变化必须更新 `README.md`。
   - 用户可见变更更新 `CHANGELOG.md`。
4. 提交 PR，说明背景、方案、验证结果、兼容性影响。

## 提交规范

推荐 commit 前缀：
1. `feat:` 新功能
2. `fix:` 修复
3. `docs:` 文档
4. `refactor:` 重构
5. `chore:` 维护

## PR 验收要求

1. 命令行为可复现。
2. 不破坏既有任务目录结构。
3. 软删除与归档可恢复。
4. 文档与脚本一致。

## 本地测试建议

可用下述流程快速回归：
1. 新建临时项目目录。
2. 运行 `init`。
3. 连续创建 2 个任务并切换。
4. 归档 1 个，软删 1 个，再恢复。
5. 最后清理并验证 `index.md` 与 `ACTIVE_TASK`。
