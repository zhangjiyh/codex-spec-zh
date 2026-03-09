# GitHub 开源发布清单（中文）

## 1. 仓库初始化
1. 创建 GitHub 仓库，例如 `codex-spec-zh`。
2. 推送代码到 `main` 分支。
3. 打开仓库设置：
   - About: 填写简介与 Topics（`codex`, `skill`, `spec`, `workflow`, `vue`, `spring-boot`）。
   - Features: 启用 Issues 与 Discussions（可选）。

## 2. 开源基础配置
1. 确认根目录包含：
   - `LICENSE`
   - `README.md`
   - `CONTRIBUTING.md`
   - `CODE_OF_CONDUCT.md`
   - `SECURITY.md`
   - `CHANGELOG.md`
2. 确认 `.github/ISSUE_TEMPLATE` 与 PR 模板可用。

## 3. 首个版本发布（建议 v0.1.0）
1. 更新 `CHANGELOG.md`。
2. 创建 tag：
   - `git tag -a v0.1.0 -m "v0.1.0"`
   - `git push origin v0.1.0`
3. 在 GitHub Release 中填写：
   - 新增功能
   - 破坏性变更（若有）
   - 升级指引
   - 示例命令

## 4. 质量门禁建议
每次发布前至少执行：
1. `bash codex-spec-zh/scripts/specflow.sh help`
2. 在临时目录完成：`init -> new -> switch -> archive -> delete -> restore -> purge`
3. 核对 `README.md` 命令与实际行为一致。

## 5. 维护策略
1. 对外承诺命令兼容性，避免随意改命令名。
2. 若修改目录结构，先出迁移说明。
3. 对安全相关问题走私下披露流程。
4. 每个版本在 `CHANGELOG.md` 记录用户可见变更。

## 6. 建议里程碑
1. `v0.2.x`：补充更多技术栈检查清单（React/Nest、Next/Spring 等）。
2. `v0.3.x`：增强脚本（自动探测构建命令，状态过滤查询）。
3. `v1.0.0`：流程、模板、命令稳定并冻结核心行为。
