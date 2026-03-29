# codex-spec-zh

这是一个给 Codex 使用的中文长任务工作流。它把中长周期开发任务拆成几个固定阶段，方便按步骤推进、按结果验收：
`需求说明（spec） -> 代码库地图（repo-map） -> 执行计划（plan） -> 分步执行 -> 每步验证 -> 验收归档`。

## 怎么用

这套 Skill 主要是给 Codex 作为工作约定使用。接到任务后，Codex 一般按下面的顺序处理：

1. 先明确 `任务说明.md`。
2. 再做最小必要的 `代码库地图.md`，先找相关模块、入口文件和影响面。
3. 再写 `执行计划.md`，把任务拆成可执行的单步。
4. 每次只做一个 Step，执行后更新 `进度记录.md`。
5. 每个 Step 都要记录验证动作，必要时补 `验证记录.md`。
6. 最后写 `验收记录.md`，通过后归档。

## 中文版主要体现

1. 任务目录中文化：新任务默认生成 `TYYYYMMDD-001-任务标题/`，不再把中文标题压成英文 slug。
2. 任务文档中文化：默认使用 `任务说明.md`、`代码库地图.md`、`执行计划.md`、`进度记录.md`、`验证记录.md`、`验收记录.md`。
3. 过程输出中文化：`status`、`list`、索引文件、下一步提示都以中文为主。
4. 历史任务可平滑迁移：旧的 `spec.md / plan.md / progress.md / acceptance.md` 仍兼容，也可以用 `localize` 迁到中文命名。
5. 文件定位与验证加强：新任务推荐补齐 `代码库地图.md` 与 `验证记录.md`，但旧任务不会被强制迁移。

这个项目提供两部分：
1. `codex-spec-zh/`：可安装到 `~/.codex/skills` 的 Skill 本体。
2. 任务仓库规范与脚本：在任意项目中落地 `.codex/specflow/` 工作流。

## 适合什么场景

这个仓库适合这类任务：
1. 任务周期比较长，不适合一次性改完。
2. 任务会涉及多个文件、多个模块，先找准入口更稳。
3. 任务需要分步验证，最好每一步都留下记录。
4. 任务做完后还要能回头检查、复盘或归档。

## 核心特点

1. 任务文档统一放在 `<project-root>/.codex/specflow/`。
2. 支持任务新建、切换、归档、软删除、恢复和永久删除。
3. 先做代码库地图，再写执行计划，减少盲改。
4. 每一步都记录进度和验证结果，方便回看。
5. 保留中文命名习惯，也兼容旧任务文件名。

## 目录结构

```text
.
├── codex-spec-zh/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── spec.template.md
│   │   ├── repo-map.template.md
│   │   ├── plan.template.md
│   │   ├── progress.template.md
│   │   ├── verification.template.md
│   │   ├── acceptance.template.md
│   │   └── checklist-vue-spring.md
│   └── scripts/
│       ├── specflow.sh
│       ├── init-workflow.sh
│       └── repo-map.sh
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
4. 代码库地图填写示例：`docs/cases/repo-map-example.md`

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
    TYYYYMMDD-001-<任务标题>/
      meta.yaml
      任务说明.md
      代码库地图.md
      执行计划.md
      进度记录.md
      验证记录.md
      验收记录.md
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

# 将旧任务迁移为中文目录与中文文档名
specflow.sh localize T20260309-001

# 永久删除（仅 trash 内任务）
specflow.sh purge T20260309-001
```

说明：
1. 新建任务默认生成中文目录与中文文档名。
2. 历史任务仍兼容旧的 `spec.md / plan.md / progress.md / acceptance.md`。
3. 如需把历史任务一起改成中文命名，可执行 `localize`。
4. 新任务推荐额外生成 `代码库地图.md` 和 `验证记录.md`。

## 推荐工作流（与 Codex 习惯贴合）

1. 先完善 `任务说明.md`，确认目标、范围、非目标、验收标准、禁改项。
2. 再做最小必要的 `代码库地图.md`，先确认相关模块、关键入口、直接相关文件、潜在影响文件和搜索关键词。
3. 再完善 `执行计划.md`，拆成可执行步骤，每步带 DoD、验证方式和验证命令。
4. 每次只执行一个 Step，执行前后都写入 `进度记录.md`；如果验证证据较多，再补 `验证记录.md`。
5. 每个 Step 都要留下可检查的验证结果，不要只写“已完成”。
6. 阶段结束后更新 `验收记录.md` 做验收清单。
7. 完成后归档任务，保留可追溯记录。

### 什么时候先做代码库扫描

建议在以下情况先做代码库扫描，再进入执行计划：

1. 任务涉及多个模块、多个语言或多个仓库目录。
2. 你对代码库不熟，或者第一次接手这个项目。
3. 需求描述比较宽，影响面可能跨前后端、接口、配置或测试。
4. 任务明确要求“找文件”“找入口”“定位影响范围”“先分析再改动”。

### 如何生成代码库地图

推荐用“先文件列表、再关键词搜索、最后收敛影响面”的顺序：

```bash
# 轻量扫描入口
~/.codex/skills/codex-spec-zh/scripts/repo-map.sh .
~/.codex/skills/codex-spec-zh/scripts/repo-map.sh login

# 或者先看文件，再针对关键词搜索
rg --files . | head -n 200
rg -n "登录|鉴权|订单|路由|controller|service" .
```

生成 `代码库地图.md` 时，重点只保留“最小必要上下文”，不要把它写成全量索引。

### 如何记录验证

每个 Step 至少记录一条验证动作，例如：

1. 测试：`pnpm test`、`pytest -q`、`./mvnw test`
2. 校验：`pnpm lint`、`pnpm typecheck`、`./mvnw verify`
3. 构建：`pnpm build`、`./gradlew build`
4. 手工 smoke：页面打开、接口调用、核心流程走通

建议写法：

1. 在 `执行计划.md` 里先约定“验证方式”。
2. 在 `进度记录.md` 里写“本步执行内容、验证命令、验证结果、失败摘要、是否通过”。
3. 如果证据较多，把原始输出写到 `验证记录.md`，再在 `进度记录.md` 里引用。
4. 验证不过就不要进入下一步，先修复或回滚。

## Vue + Spring Boot 建议

项目可直接使用 `references/checklist-vue-spring.md` 作为默认检查清单，覆盖：
1. Vue 页面与路由交互。
2. 接口契约与错误码。
3. Spring Boot 分层链路与事务。
4. 联调一致性（字段、分页、时区、异常处理）。
5. 文件定位检查项与验证记录检查项。

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
