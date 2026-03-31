# Hopola（ClawHub 发布版）

## 简介
Hopola 是一个从检索到多媒体生成再到交付的流水线技能，覆盖：
- 网页检索
- 图片生成
- 视频生成
- 3D 模型生成
- Logo 设计
- 商品图生成
- 结果上传
- Markdown 报告输出

## 能力架构
- 主技能：`SKILL.md`
- 版本文件：`VERSION.txt`
- 子技能：`subskills/` 下 8 个能力单元
- 问询模板：`playbooks/design-intake.md`
- 脚本：`scripts/` 下发布校验与打包工具
- 资产：`assets/` 下 logo、cover、flow

## 安全配置
- 必须由用户主动配置环境变量 `OPENCLOW_KEY`。
- `config.template.json` 仅保存 `key_env_name` 和空 `key_value` 占位。
- 发布前执行校验脚本阻断明文 key。

## 快速开始
```bash
cd .trae/skills/Hopola
python3 scripts/check_tools_mapping.py
python3 scripts/validate_release.py
python3 scripts/build_release_zip.py
```

## 调度策略
- 生成类任务采用“固定工具优先，自动发现回退”。
- 当固定工具不可用时，调用 `/api/gateway/mcp/tools` 选择匹配工具。
- 当用户仅上传会话图片（未提供公网 URL）时，先自动读取会话图片并走上传子技能，回填为可访问 URL 后再进入抠图/商品图/3D 等依赖图片输入的阶段。
- 商品图阶段若 `product_image_url` 为非 URL 输入（本地路径、附件引用、markdown 图片源），必须先上传并回填 URL，未成功回填前禁止触发生图。
- 商品图阶段必须满足 `source_image_confirmed=true`，且该源图必须是用户提供或用户明确确认的真实商品图；否则返回 `PRODUCT_IMAGE_UNCONFIRMED_SOURCE` 并停止调用生图工具。
- 商品图调用前统一执行前置校验：工具可用性、参考图可访问性、参数完整性（`image_list`、`prompt`、`output_format`、`size`）。
- 商品图调用时 `image_list` 只能包含已确认的 `product_image_url`，禁止使用占位图、代理图或模型生成图替代源图。
- 当前置校验失败时，返回统一 `structured_error`（含 `code`、`stage`、`message`、`details`、`retry_suggestions`）供 OpenClaw 侧直接处理重试。

## 上传策略
- 上传阶段仅使用 MAAT 直传，统一通过 `scripts/maat_upload.py` 执行。
- 当前策略不使用 Gateway 上传端点，也不再将 MAAT 作为回退分支。
- 对上传返回的 URL 持续做可访问性校验，仅交付稳定可访问链接。

## 上架文件
- `Hopola-Skills/hopola-clawhub-v<version>-*.zip`
- `README.zh-CN.md`
- `README.en.md`
- `RELEASE.md`
