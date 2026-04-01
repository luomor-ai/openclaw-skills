# A股每日收盘点评智能系统

> 每天晚上9点，自动推送到微信的A股私人投顾

## 效果示例

每天推送内容：
```
📊 A股收盘点评 · 2026-03-27

【大盘概况】
上证：3913.72（+0.63%）深证：13760.37（+1.13%）
市场情绪：分歧→修复

【持仓盈亏跟踪】
德明利 | 成本357元 | 600股 | 现价381元 | 盈亏+14,400元(+6.7%)

【4只持仓股技术分析】
⭐⭐⭐⭐ 德明利(001309) | 收盘：381.89元
...

【明日可执行操作计划】
股票 | 代码 | 方向 | 挂单价 | 数量
德明利 | 001309 | 买单 | 357元 | 6手
```

## 安装步骤

### 1. 安装依赖skill
```bash
npx clawhub install a-stock-trading-assistant --dir skills
npx clawhub install a-stock-market --dir skills
npx clawhub install china-stock-analysis --dir skills
npx clawhub install a-stock-market-sentiment --dir skills
```

### 2. 配置持仓
```bash
# 编辑持仓文件
vim ~/.clawdbot/skills/a-stock-analysis/portfolio.json
```

### 3. 定时任务（自动创建）
定时任务每天晚上9点(UTC)自动运行，推送到微信。

## 持仓格式
```json
{
  "positions": [
    {"code": "001309", "name": "德明利", "cost": 357.0, "qty": 600}
  ]
}
```

## 免责声明
本工具仅供参考，不构成投资建议。投资有风险，入市需谨慎。
