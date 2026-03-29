# 代码库地图填写示例

这个示例展示的是“最小必要上下文”的写法，适合在进入执行计划前先把范围收敛到可执行状态。

## 场景

你正在做一个 Vue + Spring Boot 登录与鉴权改造任务，目标是补 JWT 登录流程，并确认受保护接口和页面跳转正常。

## 代码库地图示例

### 1. 任务信息
- 任务ID：T20260329-001
- 任务标题：登录与鉴权改造
- 扫描日期：2026-03-29
- 扫描人：Codex

### 2. 扫描范围
- 任务相关目录：`frontend/src`、`backend/src`
- 明确排除目录：`node_modules`、`dist`、`build`
- 扫描理由：登录页、路由守卫、请求拦截器、鉴权过滤器和异常处理分布在前后端多个位置，需要先收敛入口和影响面

### 3. 关键入口文件
- `frontend/src/main.ts`
- `frontend/src/router/index.ts`
- `backend/src/controller/AuthController.java`

### 4. 直接相关文件
- `frontend/src/api/auth.ts`
- `frontend/src/views/Login.vue`
- `backend/src/service/AuthService.java`
- `backend/src/config/SecurityConfig.java`

### 5. 潜在影响文件
- `frontend/src/utils/request.ts`
- `backend/src/filter/JwtFilter.java`
- `backend/src/exception/GlobalExceptionHandler.java`

### 6. 搜索关键词
- `login`
- `token`
- `jwt`
- `auth`
- `security`

### 7. 代码搜索结果摘要
- 命中的路径：`frontend/src/router/index.ts`、`backend/src/controller/AuthController.java`
- 命中的关键函数 / 类 / 配置：路由守卫、登录接口、鉴权过滤器
- 重要反例或未命中项：未在 `dist` 中继续搜索，避免噪音；未把数据库模型纳入本次范围

### 8. 风险备注
- 风险点：前端请求拦截器和后端过滤器同时改动，容易出现联调阶段的 401 问题
- 需要复查的文件：`request.ts`、`JwtFilter.java`、`SecurityConfig.java`
- 是否可以进入执行计划：可以

### 9. 扫描结论
- 结论：当前任务的最小必要上下文已经足够，先做后端登录接口，再做前端 token 接入，最后联调回归
- 下一步：进入 `执行计划.md`，按 step 拆解并为每步定义验证方式
