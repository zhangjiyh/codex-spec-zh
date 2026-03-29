# 案例目录（初学者）

这些案例已经按中文版流程编写，重点体现：
1. 任务目录默认是 `TYYYYMMDD-001-任务标题/` 这种中文命名。
2. 任务文档默认是 `任务说明.md / 代码库地图.md / 执行计划.md / 进度记录.md / 验证记录.md / 验收记录.md`。
3. 新任务推荐先补 `代码库地图.md`，再进入执行计划。
4. 每步执行后建议记录验证命令与验证结果，必要时再补 `验证记录.md`。
5. 如果你手里已有旧的 `spec.md` 风格任务，也可以先看案例，再执行 `specflow.sh localize <TASK_ID>` 迁移。

1. [Vue + Spring Boot：登录与鉴权改造案例](./vue-springboot-login-refactor.md)
2. [Python：订单折扣规则业务修改案例](./python-order-rule-change.md)
3. [代码库地图填写示例](./repo-map-example.md)

建议阅读顺序：
1. 先看 `docs/usage-cycle-zh.md` 理解周期。
2. 再跟着一个案例完整走一遍。
3. 再看 `repo-map-example.md`，确认“什么算一个合格的代码库地图”。
4. 最后把案例模板替换成你的真实任务。
