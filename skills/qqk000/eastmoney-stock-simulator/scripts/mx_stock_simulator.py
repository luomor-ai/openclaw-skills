#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
mx_stock_simulator - 妙想模拟组合管理 skill
基于东方财富妙想API，支持模拟交易操作和查询
"""

import os
import sys
import json
import re
import requests
from datetime import datetime

def parse_trade_query(query, op_type):
    """从自然语言查询中解析出股票代码、价格、数量"""
    # 提取股票代码 (6位数字)
    code_match = re.search(r'([\d]{6})', query)
    stock_code = code_match.group(1) if code_match else None
    
    # 提取数量 (数字)
    qty_match = re.search(r'(\d+)\s*(股|手)', query)
    if qty_match:
        quantity = int(qty_match.group(1))
        # 如果是"手"，转换为100股
        if qty_match.group(2) == '手':
            quantity *= 100
    else:
        quantity = None
    
    # 提取价格
    price_match = re.search(r'(价格|成交价|市价)?\s*(\d+[.]?\d*)', query)
    price = float(price_match.group(2)) if price_match else None
    
    # 检查是否市价委托
    use_market = any(word in query.lower() for word in ['市价', '最新价', '当前价'])
    
    return {
        "type": op_type,
        "stockCode": stock_code,
        "price": price,
        "quantity": quantity,
        "useMarketPrice": use_market
    }

def get_env():
    """获取环境变量"""
    apikey = os.environ.get('MX_APIKEY')
    api_url = os.environ.get('MX_API_URL', 'https://mkapi2.dfcfs.com/finskillshub')
    return apikey, api_url

def check_apikey():
    """检查API密钥是否配置"""
    apikey, api_url = get_env()
    if not apikey:
        print("❌ 错误：未检测到环境变量 MX_APIKEY")
        print("请先设置 export MX_APIKEY=your_api_key")
        sys.exit(1)
    return apikey, api_url

def save_output(query, content, is_json=False):
    """保存输出到文件"""
    output_dir = "/root/.openclaw/workspace/mx_data/output"
    os.makedirs(output_dir, exist_ok=True)
    prefix = "mx_stock_simulator_"
    safe_query = query.replace(' ', '_')[:50]
    if is_json:
        filename = f"{output_dir}/{prefix}{safe_query}_raw.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(content, f, ensure_ascii=False, indent=2)
    else:
        filename = f"{output_dir}/{prefix}{safe_query}.txt"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
    print(f"\n✅ 文件已保存: {filename}")

def format_positions(data):
    """格式化持仓输出"""
    output = "📊 当前持仓\n"
    output += "================================================================================\n"
    output += f"{'股票代码':<12} {'股票名称':<12} {'持仓':<8} {'成本价':<10} {'现价':<10} {'盈亏(元)':<12} {'盈亏%':<8} {'仓位%':<6}\n"
    output += "--------------------------------------------------------------------------------\n"
    total_profit = 0
    if 'posList' in data and data['posList']:
        for pos in data['posList']:
            # 价格还原: price / (10^priceDec)
            cost = pos['costPrice'] / (10 ** pos['costPriceDec'])
            current = pos['price'] / (10 ** pos['priceDec'])
            profit = pos['profit'] / data.get('currencyUnit', 1000)
            total_profit += profit
            output += f"{pos['secCode']:<12} {pos['secName']:<12} {pos['count']:<8} {cost:<10.2f} {current:<10.2f} {profit:<12.2f} {pos['profitPct']:<8.2f} {pos.get('posPct', 0):<6.2f}\n"
    output += "================================================================================\n"
    unit = data.get('currencyUnit', 1000)
    total_assets = data.get('totalAssets', 0) / unit
    avail_balance = data.get('availBalance', 0) / unit
    total_pos_value = data.get('totalPosValue', 0) / unit
    total_profit = data.get('totalProfit', 0) / unit
    output += f"\n💰 账户概况\n"
    output += f"总资产: {total_assets:.2f} 元\n"
    output += f"可用资金: {avail_balance:.2f} 元\n"
    output += f"总持仓市值: {total_pos_value:.2f} 元\n"
    output += f"总盈亏: {total_profit:.2f} 元\n"
    output += f"持仓股票数: {data.get('posCount', 0)} 只\n"
    return output

def format_orders(data):
    """格式化委托输出"""
    output = "📋 委托列表\n"
    output += "================================================================================\n"
    output += f"{'委托编号':<18} {'股票':<8} {'方向':<4} {'价格':<8} {'数量':<6} {'状态':<8} {'成交数量':<8}\n"
    output += "--------------------------------------------------------------------------------\n"
    drt_map = {1: "买入", 2: "卖出"}
    status_map = {
        1: "未报", 2: "已报", 3: "部成", 4: "已成", 5: "部成待撤",
        6: "已报待撤", 7: "部撤", 8: "已撤", 9: "废单", 10: "撤单失败"
    }
    if 'orders' in data and data['orders']:
        for order in data['orders']:
            drt = drt_map.get(order['drt'], f"{order['drt']}")
            status = status_map.get(order['status'], f"{order['status']}")
            price = order['price'] / (10 ** order['priceDec'])
            output += f"{order['id']:<18} {order.get('secName', order['secCode']):<8} {drt:<4} {price:<8.2f} {order['count']:<6} {status:<8} {order.get('tradeCount', 0):<8}\n"
    output += f"================================================================================\n"
    output += f"共计 {data.get('totalNum', 0)} 条委托\n"
    return output

def format_balance(data):
    """格式化资金查询输出"""
    unit = data.get('currencyUnit', 1000)
    output = "💰 账户资金\n"
    output += "================================================================================\n"
    output += f"初始资金: {data.get('initMoney', 0)/unit:.2f} 元\n" if 'initMoney' in data else ""
    output += f"总资产: {data.get('totalAssets', 0)/unit:.2f} 元\n"
    output += f"可用资金: {data.get('availBalance', 0)/unit:.2f} 元\n"
    output += f"冻结资金: {data.get('frozenMoney', 0)/unit:.2f} 元\n"
    output += f"总持仓市值: {data.get('totalPosValue', 0)/unit:.2f} 元\n"
    output += f"总仓位: {data.get('totalPosPct', 0):.2f}%\n"
    if 'nav' in data:
        output += f"单位净值: {data.get('nav', 0):.3f}\n"
    if 'oprDays' in data:
        output += f"运作天数: {data.get('oprDays', 0)} 天\n"
    if 'accName' in data:
        output += f"\n账户名称: {data.get('accName')}\n"
        output += f"账户ID: {data.get('accID')}\n"
    return output

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python mx_stock_simulator.py \"自然语言查询\"")
        print("\n示例:")
        print("  python mx_stock_simulator.py \"查询我的持仓\"")
        print("  python mx_stock_simulator.py \"买入 100 股 贵州茅台 600519 价格 1800\"")
        print("  python mx_stock_simulator.py \"查询资金\"")
        sys.exit(1)

    apikey, api_url = check_apikey()
    query = ' '.join(sys.argv[1:])

    # 根据自然语言判断接口和操作类型
    query_lower = query.lower()
    if any(word in query_lower for word in ['持仓', 'position']):
        url = f"{api_url}/api/claw/mockTrading/positions"
        payload = {}
    elif any(word in query_lower for word in ['买入', 'buy']):
        url = f"{api_url}/api/claw/mockTrading/buy"
        # 解析参数
        payload = parse_trade_query(query, "buy")
    elif any(word in query_lower for word in ['卖出', 'sell']):
        url = f"{api_url}/api/claw/mockTrading/buy"
        # 解析参数
        payload = parse_trade_query(query, "sell")
    elif any(word in query_lower for word in ['撤单', 'cancel']):
        url = f"{api_url}/api/claw/mockTrading/cancel"
        # 检查是否一键撤单
        if '所有' in query or 'all' in query_lower:
            payload = {"type": "all"}
        else:
            # 提取订单号
            order_match = re.search(r'([\w\d]+)', query)
            order_id = order_match.group(1) if order_match else None
            code_match = re.search(r'([\d]{6})', query)
            code = code_match.group(1) if code_match else None
            payload = {"type": "order", "orderId": order_id, "stockCode": code}
        payload["query"] = query
    elif any(word in query_lower for word in ['委托', 'order', '成交', 'history']):
        url = f"{api_url}/api/claw/mockTrading/orders"
        payload = {}
    elif any(word in query_lower for word in ['资金', 'balance']):
        url = f"{api_url}/api/claw/mockTrading/balance"
        payload = {}
    else:
        # 默认交给API识别
        url = f"{api_url}/api/claw/mockTrading/buy"
        payload = {"query": query}

    headers = {
        'apikey': apikey,
        'Content-Type': 'application/json'
    }

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        print(f"❌ 请求失败: {e}")
        sys.exit(1)

    # 保存原始JSON
    save_output(query, data, is_json=True)

    # 格式化输出
    # 检查错误码
    if ('status' in data and data['status'] == 404) or ('code' in data and data['code'] == 404):
        msg = data.get('message', '未绑定账户')
        result_str = f"❌ {msg}\n\n"
        result_str += "请前往 妙想Skills页面 (https://dl.dfcfs.com/m/itc4) 创建模拟账户并绑定你的API密钥后重试。"
    elif 'code' in data and data['code'] != 200 and data['code'] != '200' and data['code'] != 0:
        msg = data.get('message', '操作失败')
        result_str = f"❌ {msg}"
    elif url.endswith('/positions'):
        if 'data' in data:
            result_str = format_positions(data['data'])
        else:
            result_str = f"返回数据异常: {json.dumps(data, indent=2, ensure_ascii=False)}"
    elif url.endswith('/orders'):
        if 'data' in data:
            result_str = format_orders(data['data'])
        else:
            result_str = f"返回数据异常: {json.dumps(data, indent=2, ensure_ascii=False)}"
    elif url.endswith('/balance'):
        if 'data' in data:
            result_str = format_balance(data['data'])
        else:
            result_str = f"返回数据异常: {json.dumps(data, indent=2, ensure_ascii=False)}"
    else:
        # 买入/撤单等操作
        if data.get('code') == 200 or data.get('code') == '200' or data.get('status') == 0:
            msg = data.get('message', '成功')
            result_str = f"✅ {msg}\n\n"
            if 'data' in data and 'orderID' in data['data']:
                result_str += f"委托编号: {data['data']['orderID']}"
            elif 'data' in data and 'orderId' in data['data']:
                result_str += f"委托编号: {data['data']['orderId']}"
        else:
            msg = data.get('message', '操作失败')
            result_str = f"❌ {msg}"

    print(result_str)
    save_output(query, result_str, is_json=False)

if __name__ == '__main__':
    main()
