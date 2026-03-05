---
name: binance-funding-monitor
description: 币安资金费率套利监控工具 - 查看账户、持仓、盈亏统计，SkillPay收费版
version: 1.0.1
author: partner
---

# Binance Funding Monitor (SkillPay)

币安资金费率套利监控工具 - 按次付费版

## 价格

- 每次调用: **0.001 USDT**
- 支付方式: Crypto 钱包 (Web3)

## 功能

- `get_account_summary` - 账户总览（权益、保证金、余额）
- `get_positions` - 当前持仓列表
- `get_funding_income` - 近7天资金费收入
- `get_full_report` - 完整监控报告

## 配置

使用前需要设置币安 API:
```bash
export BINANCE_API_KEY="your_api_key"
export BINANCE_API_SECRET="your_api_secret"
```

## SkillPay 配置

已内置 API Key，用户无需额外配置。

## 免责声明

本工具仅供监控使用，不构成投资建议。