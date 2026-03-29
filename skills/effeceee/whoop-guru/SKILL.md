# WHOOP Guru - 完整WHOOP健康管理系统

## v8.0 简介

WHOOP Guru 是**完整的WHOOP健康管理系统**，整合数据获取、分析、图表可视化、AI教练和个性化训练计划。

**核心功能：**
- 📊 **数据获取** - WHOOP官方API，实时同步恢复/睡眠/训练/HRV
- 📈 **图表生成** - 交互式HTML图表，恢复/睡眠/strain/HRV趋势
- 🤖 **AI教练** - LLM驱动，个性化训练建议
- 🎯 **训练计划** - 跑步/增肌/减脂/伤痛恢复
- 🔔 **主动推送** - 每日定时提醒
- 📉 **ML预测** - 7天恢复预测，异常检测

---

## 功能列表

### 1. WHOOP数据获取

```bash
# 获取综合报告
python3 scripts/whoop_data.py summary --days 7

# 睡眠数据
python3 scripts/whoop_data.py sleep --days 7

# 恢复评分
python3 scripts/whoop_data.py recovery --days 30

# 训练/cycle数据
python3 scripts/whoop_data.py cycles --days 7

#  workouts
python3 scripts/whoop_data.py workouts --days 30

# 用户档案
python3 scripts/whoop_data.py profile

# 身体数据
python3 scripts/whoop_data.py body
```

### 2. OAuth认证

```bash
# 首次登录
python3 scripts/whoop_auth.py login --client-id YOUR_ID --client-secret YOUR_SECRET

# 检查状态
python3 scripts/whoop_auth.py status
```

### 3. 图表生成

```bash
# 睡眠分析图表
python3 scripts/whoop_chart.py sleep --days 30

# 恢复评分图表
python3 scripts/whoop_chart.py recovery --days 30

# Strain趋势
python3 scripts/whoop_chart.py strain --days 90

# HRV趋势
python3 scripts/whoop_chart.py hrv --days 90

# 综合仪表盘
python3 scripts/whoop_chart.py dashboard --days 30
```

### 4. 健康分析

使用 `references/health_analysis.md` 进行科学分析：
- HRV正常范围（按年龄/ fitness）
- 恢复评分解读（绿/黄/红）
- 睡眠阶段分析
- 训练过度信号检测
- 可操作的建议

### 5. AI教练（LLM驱动）

```bash
# 开启教练对话
python3 whoop-guru.py coach

# 生成今日计划
python3 whoop-guru.py plan

# 生成16周计划
python3 whoop-guru.py 16week --goal 增肌
```

### 6. 推送系统

| 时间 | 内容 | 命令 |
|------|------|------|
| 08:00 | 健康早报 | daily-report.sh |
| 09:00 | 教练早安 | push-morning.py |
| 18:00 | 晚间追踪 | push-evening.py |
| 20:00 | 打卡提醒 | push-checkin.py |
| 22:00 | 详细日报 | detailed-report.sh |

---

## 支持的运动目标

| 类别 | 目标 | 周期 |
|------|------|------|
| 🏃 跑步 | 3公里新手 | 8周 |
| 🏃 跑步 | 5公里 | 10周 |
| 🏃 跑步 | 10公里 | 12周 |
| 🏃 跑步 | 半程马拉松 | 24周 |
| 🏃 跑步 | 超级马拉松 | 52周 |
| 💪 力量 | 增肌 | 16周 |
| 💪 力量 | 减脂 | 12周 |
| 🏥 康复 | 伤痛恢复 | 按需 |

---

## 关键指标

- **恢复评分** (0-100%): 绿色≥67%, 黄色34-66%, 红色<34%
- **Strain** (0-21): 基于心率的每日运动强度
- **睡眠效率**: 实际睡眠 vs 需要睡眠
- **HRV** (ms): 越高恢复越好，追踪趋势
- **静息心率** (bpm): 越低心血管 fitness越好

---

## 配置说明

### WHOOP OAuth（必需）

WHOOP 使用 OAuth 2.0 授权，配置步骤：

1. 在 [developer.whoop.com](https://developer.whoop.com) 创建 App 获取 Client ID 和 Secret
2. 运行：`python3 scripts/whoop_auth.py login --client-id YOUR_ID --client-secret YOUR_SECRET`
3. 浏览器自动打开，完成授权
4. Token 自动存储在 `~/.clawdbot/whoop-tokens.json`

### LLM API（可选）

用于 AI 个性化分析。配置方式：
- 发送「设置模型」给机器人
- 按提示输入 API Key 和选择模型
- 配置存储在 `data/config/llm_config.json`

### 本地数据存储

所有数据存储在本地，不上传外部服务器：
- `data/profiles/` - 用户健身档案
- `data/plans/` - AI训练计划
- `data/logs/` - 打卡记录
- `data/config/llm_config.json` - LLM API密钥
- `~/.clawdbot/whoop-tokens.json` - WHOOP OAuth令牌

---

## 文件结构

```
whoop-guru/
├── SKILL.md
├── CLAWHUB.md
├── whoop-guru.py          # 主入口
├── scripts/
│   ├── whoop_auth.py      # OAuth认证
│   ├── whoop_data.py     # 数据获取
│   ├── whoop_chart.py    # 图表生成
│   ├── daily-report.sh   # 08:00早报
│   ├── detailed-report.sh # 22:00日报
│   ├── coach-push.sh     # 推送调度
│   ├── push-morning.py   # 09:00早安
│   ├── push-evening.py   # 18:00晚间
│   └── push-checkin.py   # 20:00打卡
├── lib/
│   ├── llm.py            # LLM集成
│   ├── data_cleaner.py   # 数据清洗
│   ├── sync.py           # 数据同步
│   ├── tracker.py        # 打卡追踪
│   ├── goals.py          # 目标管理
│   ├── dynamic_planner.py # 动态规划
│   ├── pusher.py        # 推送生成
│   ├── coach_interface.py # 教练接口
│   ├── needs_analyzer.py # 需求分析
│   ├── plan_generator.py # 计划生成
│   ├── ml/              # ML预测
│   ├── prompts/          # Prompt模板
│   └── reports/         # 报告生成
├── references/
│   ├── api.md           # API文档
│   └── health_analysis.md # 健康分析指南
└── data/
    ├── config/          # LLM配置
    ├── profiles/        # 用户档案
    ├── plans/          # 生成的计划
    └── logs/           # 打卡记录
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v8.0 | 2026-03-29 | 完整功能整合，LLM教练 |
| v7.2 | 2026-03-29 | 主动推送系统 |
| v7.1 | 2026-03-29 | WHOOP数据整合 |
| v7.0 | 2026-03-29 | 初始版本 |

---

**当前版本**: v8.0  
**最后更新**: 2026-03-29 14:27 UTC+8

---

## 版本历史

### v8.2.6 (2026-03-29)
- 修复：统一 SKILL.md 和 _meta.json 的配置说明
- 新增：homepage 字段
- 修复：移除 WHOOP_REFRESH_TOKEN（OAuth自动获取）
- 修复：统一三个文件的凭证说明

### v8.2.2 (2026-03-29)
- 修复：移除所有硬编码路径，统一使用环境变量
- 修复：统一 SKILL.md、CLAWHUB.md、_meta.json 凭证说明
- 新增：完整测试套件 (24 tests)

### v8.2.0 (2026-03-29)
- 新增：LLM 增强报告模块
- 推送系统集成所有模块

### v8.1.5-8.1.7 (2026-03-29)
- 新增：09:00 早安推送、18:00 晚间推送、20:00 打卡推送
- 集成：dynamic_planner、goals、tracker 模块

### v8.0 (2026-03-26)
- LLM 集成（支持 8 种提供商）
- 个性化训练计划生成
- 用户需求分析系统

### v7.2 (2026-03-26)
- 主动推送系统
- 打卡追踪系统
- ML 预测模块

### v7.0 (2026-03-26)
- 完整 WHOOP 数据获取
- 健康分析引擎
- 健康评分系统
