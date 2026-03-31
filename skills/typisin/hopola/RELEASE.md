# Hopola 发布清单

## 发布前检查
- 目录完整：主技能、6 个子技能、脚本、资产、双语文档。
- 安全通过：无明文 key，`gateway.key_value` 为空。
- 映射通过：图片/视频/3D 的固定工具与回退策略有效。
- 版本通过：`VERSION.txt` 为 `x.y.z` 语义化版本格式。

## 执行命令
```bash
cd .trae/skills/Hopola
python3 scripts/check_tools_mapping.py
python3 scripts/validate_release.py
python3 scripts/build_release_zip.py
```

## 产物
- `Hopola-Skills/hopola-clawhub-v<version>-<timestamp>.zip`

## 当前版本
- 版本号：`1.0.7`
- 变更摘要：在既有商品图流程约束基础上，执行版本号升级并重新打包发布产物。
- 新增能力：当 `task_type=product-image` 或 `stage=generate-product-image` 时，主技能显式要求调用 `subskills/product-image/SKILL.md`。
- 兼容性说明：不改变其他任务类型流程，仅增强商品图路由可预测性。
- 风险与回滚：如需回滚，可撤销本次商品图调用约束描述并恢复上一版文案。

## 回归验证记录（1.0.7）
- 发布校验：`check_tools_mapping` 与 `validate_release` 均通过。
- 打包产物：见项目根目录最新 `hopola-clawhub-v1.0.7-<timestamp>.zip`。

## 回归验证记录（1.0.6）
- 公网 URL 回归：输入可访问的 `https` 商品图 URL，流程可直接通过前置校验并完成生成。
- 会话图回归：输入会话上传图片引用后，会先上传归一化为可访问 URL，再进入生成阶段并返回结果。
- 不可访问 URL 回归：输入不可访问 URL 会在前置校验阶段阻断，返回结构化错误与可执行重试建议。
- 发布校验：`check_tools_mapping` 与 `validate_release` 均通过。
- 打包产物：`/Users/youpengtu/Hopola-Skills/hopola-clawhub-v1.0.6-20260330-160116.zip`。

## 回归验证记录（1.0.3）
- 单图回归：本地单图路径输入可解析为上传候选，验证通过。
- 会话图回归：`openclaw://session_uploads//demo.png` 可归一化为 `/mnt/data/session_uploads/demo.png`，验证通过。
- 异常 URL 回归：`https://example.com//a///b.png?x=1` 可标准化为 `https://example.com/a/b.png?x=1`，验证通过。
- 发布校验：`check_tools_mapping` 与 `validate_release` 均通过。
- 打包产物：见项目根目录最新 `hopola-clawhub-v1.0.3-<timestamp>.zip`。

## 版本说明模板
- 版本号：`x.y.z`
- 变更摘要：
- 新增能力：
- 兼容性说明：
- 风险与回滚：
