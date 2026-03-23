---
name: dex-quant-skill
description: >
  加密货币量化交易 AI Skill。用户用自然语言描述交易规则 → AI 生成策略脚本 → 回测验证 → 实时监控。
  Use when user asks to create a trading strategy, backtest, or monitor crypto markets.
---

# DEX Quant Skill — 加密货币量化交易

## ⚠️ 行为准则（必须遵守）

1. **你是执行者**。不要给用户贴命令让他们手动跑，你自己执行。
2. **不要问用户选择**。不要问"你选哪种？"、"要我装依赖吗？"、"本地还是服务器？"。直接做。
3. **回测只有一种方式**：调用服务器 API。没有"本地回测"选项。
4. **依赖直接装**。不要问，直接 `pip3 install numpy pandas httpx loguru yfinance`。
5. **生成策略后如果用户说回测，立刻执行**，不要再确认。

---

## 流程

```
用户说想法 → 你生成策略脚本 → 用户说回测 → 你运行脚本+调服务器API → 你展示结果
```

---

## 1. 策略制作

用户说交易想法时，你直接生成 Python 策略脚本，保存到 `{baseDir}/strategies/`。

脚本必须：
- `import sys; sys.path.insert(0, '{baseDir}/scripts')` 导入工具库
- 使用 `from data_client import DataClient` 获取数据
- 使用 `from indicators import Indicators as ind` 计算指标
- 实现 `generate_signals(mode, start_date, end_date)` 函数
- 返回 `{"strategy_name": "...", "signals": [...]}`

信号格式：每个信号必须包含 `timestamp, symbol, action(buy/sell), direction(long/short), confidence, reason, price_at_signal`。可选：`suggested_stop_loss, suggested_take_profit`。

---

## 2. 回测

**当用户要求回测时，你必须立刻执行以下操作（不要问用户任何问题）：**

第一步：安装依赖（直接执行，不要问）
```bash
pip3 install numpy pandas httpx loguru yfinance 2>/dev/null
```

第二步：运行以下 Python 代码（你自己执行）
```python
import sys
sys.path.insert(0, '{baseDir}/scripts')

# 导入并运行策略脚本
from strategies.xxx_strategy import generate_signals
result = generate_signals(mode='backtest', start_date='起始日期', end_date='结束日期')

# 连接回测服务器
from api_client import QuantAPIClient
client = QuantAPIClient(timeout=300.0)
bt = client.run_backtest(
    strategy_name="策略名",
    symbol="交易对",
    timeframe="周期",
    start_date="起始日期",
    end_date="结束日期",
    signals=result['signals'],
    leverage=3,
    initial_capital=100000,
    direction="long_short",
)

# 展示结果
client.print_metrics(bt)
client.print_trades(bt)
client.print_conclusion(bt)
```

服务器地址已内置在 api_client.py 中，无需配置。认证是自动的。

回测能力：多空双向、杠杆1-125x、资金费率、止损止盈、强平、手续费0.05%、滑点。
输出：收益率、Sharpe、Sortino、最大回撤、胜率、盈亏比、交易记录。

---

## 3. 实时监控

用户要求监控时，直接运行策略脚本的 live 模式：

```python
import sys
sys.path.insert(0, '{baseDir}/scripts')
from strategies.xxx_strategy import generate_signals
result = generate_signals(mode='live')
# 展示信号
```

---

## 项目结构

```
dex-quant-skill/
├── SKILL.md
├── scripts/
│   ├── api_client.py      ← 回测服务器客户端
│   ├── data_client.py     ← K线数据获取
│   ├── indicators.py      ← 技术指标（EMA/RSI/MACD/BB/ATR/KDJ等）
│   ├── machine_auth.py    ← 自动认证
│   └── strategy_runner.py
└── schemas/
    └── signal_format.json
```
