# 案例 1：Vue + Spring Boot 登录与鉴权改造（初学者）

## 场景

你有一个旧系统：
1. Vue 前端登录后只存 `userId`。
2. Spring Boot 后端接口未统一校验 token。

目标：改造成标准 JWT 登录流程，并保证页面和接口联调通过。

## 第一步：新建任务

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh new "登录鉴权改造"
~/.codex/skills/codex-spec-zh/scripts/specflow.sh status
```

默认会生成类似这样的目录：

```text
.codex/specflow/tasks/T20260327-001-登录鉴权改造/
  meta.yaml
  任务说明.md
  执行计划.md
  进度记录.md
  验收记录.md
```

如果你原来已经有旧任务目录，例如 `T20260325-001-task/`，可以先迁移：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh localize T20260325-001
```

## 第二步：写 任务说明.md（示例）

可以填写成：
1. 目标：登录成功返回 JWT；前端保存 token；接口统一鉴权。
2. 范围：登录页、请求拦截器、后端登录接口、鉴权过滤器。
3. 非目标：不改权限模型；不改数据库结构。
4. 验收标准：
- 登录成功后访问受保护页面正常。
- token 失效时自动跳回登录页。
- 受保护接口未带 token 返回 401。

## 第三步：写 执行计划.md（示例 Step）

1. Step 1：后端登录接口返回 JWT。
2. Step 2：后端鉴权过滤器拦截受保护接口。
3. Step 3：前端登录页接入新接口并存 token。
4. Step 4：前端请求拦截器自动附带 token。
5. Step 5：联调与回归测试。

## 第四步：按 step 执行并记录

每做一步都在 `进度记录.md` 记录：
1. 改动前目标与边界。
2. 实际修改文件。
3. 验证命令与结果。
4. 与计划差异和下一步动作。

### 示例验证命令

前端：
```bash
pnpm lint
pnpm build
```

后端：
```bash
./mvnw test
./mvnw verify
```

联调检查：
1. 登录成功后访问 `/dashboard`。
2. 手动删除 token，再调用受保护接口，确认 401。
3. 浏览器 Console 无 Error。

## 第五步：验收与归档

1. 填写 `验收记录.md`。
2. 确认 `status` 里显示的当前任务目录和中文文档路径无误。
3. 通过后执行：

```bash
~/.codex/skills/codex-spec-zh/scripts/specflow.sh archive <TASK_ID> "JWT 登录改造完成"
```

## 你会学到什么

1. 如何拆解前后端联动任务。
2. 如何避免“一次改太多文件”。
3. 如何把联调结果沉淀到中文任务文档，方便回归。
