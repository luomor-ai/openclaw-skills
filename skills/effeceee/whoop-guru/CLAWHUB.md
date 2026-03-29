# ClawHub Metadata

version: 8.2.0
slug: whoop-guru
name: WHOOP Guru
description: |
  完整的WHOOP健康管理系统。整合WHOOP官方API数据获取、交互式图表可视化、
  LLM AI私人教练、个性化训练计划（跑步/力量/减脂/康复）、ML恢复预测
  和每日主动推送，为用户提供一站式健康管理和健身指导。
  
summary: Complete WHOOP health system with AI coach, charts, training plans, and ML predictions
owner: effeceee

tags:
- whoop
- fitness
- coach
- ai-coach
- llm
- health
- workout
- recovery
- sleep
- hrv
- running
- marathon
- strength
- fatloss
- training
- injury-recovery
- charts
- visualization

requirements:
  python: ">=3.8"
  packages:
    pandas: ">=1.3"
    matplotlib: ">=3.5"
    requests: ">=2.25"
    chart.js: "*"

features:
  - id: whoop_api
    title: WHOOP官方API数据
    description: 实时获取恢复、睡眠、训练负荷、HRV等数据，支持OAuth认证
  - id: data_charts
    title: 交互式图表
    description: 生成恢复/睡眠/strain/HRV趋势图表，HTML格式，支持暗色主题
  - id: llm_coach
    title: LLM AI教练
    description: 支持8种模型（MiniMax/OpenAI/GLM/Kimi等），基于LLM生成个性化训练建议
  - id: running_plans
    title: 跑步训练计划
    description: 支持3公里/5公里/10公里/半马/全马/超级马拉松，从新手到完赛
  - id: strength_plans
    title: 力量训练计划
    description: 增肌计划（16周）、减脂计划（12周），配合营养建议
  - id: injury_recovery
    title: 伤痛恢复
    description: 膝盖/肩关节/腰痛等伤痛恢复训练方案
  - id: ml_predictions
    title: ML恢复预测
    description: 7天恢复预测、HRV异常检测、训练强度建议
  - id: progress_tracking
    title: 进度追踪
    description: 打卡系统、连续记录、周报、目标仪表盘
  - id: proactive_notifications
    title: 主动推送
    description: 08:00早报、09:00早安、18:00晚间追踪、20:00打卡提醒、22:00日报

commands:
  - /coach
    description: 开启AI教练对话
  - /plan
    description: 生成今日训练计划
  - /checkin
    description: 训练打卡
  - /progress
    description: 查看训练进度
  - /16week
    description: 生成16周训练计划
  - /marathon
    description: 生成马拉松训练计划
  - /race
    description: 生成比赛训练计划
  - /strength
    description: 生成力量训练计划
  - /fatloss
    description: 生成减脂计划
  - /recovery
    description: 生成伤痛恢复计划
  - /profile
    description: 查看/设置健身档案
  - /llm
    description: 配置LLM模型
  - /chart
    description: 生成健康图表

configuration:
  whoop_oauth:
    description: WHOOP OAuth credentials
    used_during: python3 scripts/whoop_auth.py login
    stored_at: ~/.clawdbot/whoop-tokens.json
  llm_api:
    description: LLM API key (optional)
    used_during: Setup command via chat
    stored_at: data/config/llm_config.json

data_storage:
  profiles:
    path: data/profiles/
    description: 用户健身档案和目标（相对路径，相对于skill目录）
  plans:
    path: data/plans/
    description: AI生成的训练计划
  logs:
    path: data/logs/
    description: 打卡记录和追踪数据
  config:
    path: data/config/llm_config.json
    description: LLM API密钥配置（用户自行配置，不上传）
  tokens:
    description: WHOOP OAuth token存储
    storage_path: ~/.clawdbot/whoop-tokens.json
    handling: |
      WHOOP OAuth token存储在 ~/.clawdbot/whoop-tokens.json
      LLM API密钥存储在 data/config/llm_config.json
      所有凭证文件由OpenClaw管理，不上传外部服务
  privacy: |
    所有数据存储在本地设备，不上传外部服务器（除WHOOP/LLM官方API）。
    WHOOP OAuth token仅用于获取用户WHOOP数据。
    LLM API密钥仅用于生成个性化建议，不作其他用途。
    用户可随时删除data/目录或重装skill清除所有本地数据。

installation_notes: |
    首次使用需要配置WHOOP API凭证：
    1. 在 developer-dashboard.whoop.com 创建App
    2. 获取 Client ID 和 Client Secret
    3. 运行 python3 scripts/whoop_auth.py login 进行OAuth授权
