# codex-spec-zh

面向 Codex 的中文长任务执行 Skill。目标是让中长周期开发任务按固定流程推进：
`spec -> plan -> step-by-step execution -> verification -> acceptance`。

这个项目提供两部分：
1. `codex-spec-zh/`：可安装到 `~/.codex/skills` 的 Skill 本体。
2. 任务仓库规范与脚本：在任意项目中落地 `.codex/specflow/` 工作流。

## 为什么做这个 Skill

在长任务里，失败通常不是因为不会写代码，而是因为：
1. 目标和边界不清晰。
2. 一次改动面太大。
3. 缺少每步验收和记录。
4. 任务切换后上下文漂移。

`codex-spec-zh` 通过统一文档和任务生命周期，解决以上问题。

## 核心能力

1. 明确文档落点：所有任务文档固定放在 `<project-root>/.codex/specflow/`。
2. 多任务管理：支持 `新建/切换/归档/软删除/恢复/永久删除`。
3. 单步执行约束：一次只做一个步骤，强制每步验证。
4. 中文输出友好：模板、状态、报告均默认中文。
5. 多项目复用：Skill 安装一次，任意项目目录可复用。

## 目录结构

```text
.
├── codex-spec-zh/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── spec.template.md
│   │   ├── plan.template.md
│   │   ├── progress.template.md
│   │   ├── acceptance.template.md
│   │   └── checklist-vue-spring.md
│   └── scripts/
│       ├── specflow.sh
│       └── init-workflow.sh
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   └── feature_request.yml
│   └── pull_request_template.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## 安装到 Codex

### 方法 1：本地复制（最直接）

```bash
mkdir -p ~/.codex/skills
cp -R codex-spec-zh ~/.codex/skills/codex-spec-zh
```

然后重启 Codex 会话。

### 方法 2：从 GitHub 仓库安装

你发布后可以通过 `skill-installer` 从仓库路径安装。

## 安装后先看这里（案例入口）

1. 周期化使用说明：`docs/usage-cycle-zh.md`
2. Vue + Spring Boot 案例：`docs/cases/vue-springboot-login-refactor.md`
3. Python 业务修改案例：`docs/cases/python-order-rule-change.md`

## 在项目中开始使用

进入你的项目根目录后：

```bash
# 初始化任务仓库
~/.codex/skills/codex-spec-zh/scripts/specflow.sh init

# 新建一个任务
~/.codex/skills/codex-spec-zh/scripts/specflow.sh new "登录与鉴权重构"

# 查看任务列表
~/.codex/skills/codex-spec-zh/scripts/specflow.sh list

# 查看当前任务状态
~/.codex/skills/codex-spec-zh/scripts/specflow.sh status
```

生成目录：

```text
<project-root>/.codex/specflow/
  ACTIVE_TASK
  index.md
  tasks/
    TYYYYMMDD-001-<slug>/
      meta.yaml
      spec.md
      plan.md
      progress.md
      acceptance.md
  archive/
  trash/
```

## 任务生命周期命令

```bash
# 切换任务
specflow.sh switch T20260309-001

# 归档任务（可选原因）
specflow.sh archive T20260309-001 "里程碑完成"

# 软删除任务（移动到 trash）
specflow.sh delete T20260309-001

# 恢复任务（从 archive 或 trash 恢复到 tasks）
specflow.sh restore T20260309-001

# 永久删除（仅 trash 内任务）
specflow.sh purge T20260309-001
```

## 推荐工作流（与 Codex 习惯贴合）

1. 先完善 `spec.md`，确认目标、范围、非目标、验收标准、禁改项。
2. 再完善 `plan.md`，拆成可执行步骤，每步带 DoD 与验证命令。
3. 每次只执行一个 Step，执行前后都写入 `progress.md`。
4. 阶段结束后更新 `acceptance.md` 做验收清单。
5. 完成后归档任务，保留可追溯记录。

## Vue + Spring Boot 建议

项目可直接使用 `references/checklist-vue-spring.md` 作为默认检查清单，覆盖：
1. Vue 页面与路由交互。
2. 接口契约与错误码。
3. Spring Boot 分层链路与事务。
4. 联调一致性（字段、分页、时区、异常处理）。

## 版本策略

1. `0.x`：快速迭代阶段，模板和脚本可能调整。
2. `1.0`：流程和命令稳定后发布。

## 开源资料清单

本仓库已包含：
1. MIT 许可证 (`LICENSE`)。
2. 贡献指南 (`CONTRIBUTING.md`)。
3. 行为准则 (`CODE_OF_CONDUCT.md`)。
4. 安全策略 (`SECURITY.md`)。
5. 变更日志 (`CHANGELOG.md`)。
6. Issue 模板和 PR 模板 (`.github/`)。
7. 按用户周期使用说明（`docs/usage-cycle-zh.md`）。
8. 初学者案例（`docs/cases/`）。

## 发布建议

1. 初始化并首发：`v0.1.0`。
2. 在 GitHub Release 附上使用示例和升级说明。
3. 后续将常见项目脚手架命令（Vue CLI/Vite, Maven/Gradle）做自动探测增强。

## 兼容性

1. 脚本基于 `bash`，macOS/Linux 可直接运行。
2. Windows 建议在 WSL 或 Git Bash 中使用。

## License

MIT. 详见 [LICENSE](LICENSE)。
