# Vue + Spring Boot 联调检查清单

## 1. Vue 页面检查
- [ ] 路由跳转正确，权限控制符合预期
- [ ] 页面首屏无报错（Console 无 Error）
- [ ] 表单校验规则完整（必填、格式、边界）
- [ ] Loading / Empty / Error 状态完整
- [ ] 关键交互在移动端和桌面端表现正常

## 2. API 契约检查
- [ ] 请求方法、路径、参数与文档一致
- [ ] 字段命名一致（camelCase/snake_case 有明确约定）
- [ ] 错误码、错误信息格式统一
- [ ] 分页、排序、过滤参数行为一致
- [ ] 日期/时区格式一致（建议 ISO-8601）

## 3. Spring Boot 后端检查
- [ ] Controller 入参校验完整（Bean Validation）
- [ ] Service 业务逻辑与事务边界正确
- [ ] Repository 查询性能可接受（避免 N+1）
- [ ] 异常处理统一（全局异常处理器）
- [ ] 日志包含可定位上下文（traceId / key params）

## 4. 回归与验收建议命令
按项目实际命令调整：

### 前端（Vue）
```bash
pnpm install
pnpm lint
pnpm test
pnpm build
```

若使用 npm：
```bash
npm install
npm run lint
npm test
npm run build
```

### 后端（Spring Boot）
若使用 Maven Wrapper：
```bash
./mvnw test
./mvnw verify
```

若使用 Gradle Wrapper：
```bash
./gradlew test
./gradlew build
```

## 5. 联调验收
- [ ] 核心业务链路端到端打通
- [ ] 失败场景可观测、可提示、可恢复
- [ ] 性能与超时阈值在可接受范围
- [ ] 关键路径可重复回归
