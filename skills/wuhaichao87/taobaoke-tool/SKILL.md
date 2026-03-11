# 淘宝客工具箱 - Taobaoke Toolkit

淘宝客全能工具，支持链接转链、多平台比价、一键价保、佣金追踪。
**已接入折淘客API，支持京东链接高佣转链。**

## 功能特性

- 🔗 **智能转链**：淘宝/京东/拼多多链接自动转为你的佣金链接
- 💰 **全网比价**：对比三大平台价格，找出最低价
- 🛡️ **一键价保**：自动申请京东/淘宝价保，追回差价
- 📊 **佣金追踪**：记录转链和成交数据
- 🚀 **高佣转链**：通过折淘客API获取更高佣金比例

## 快速开始

### 1. 配置折淘客API（必需）

在 `~/.openclaw/.env` 中添加：

```bash
# 折淘客配置（必需）
ZHETAOKE_APP_KEY=你的折淘客AppKey
ZHETAOKE_SID=你的推广位ID

# 其他联盟配置（可选）
TAOBAO_PID=mm_你的PID
PDD_PID=你的多多进宝PID
```

**获取折淘客AppKey：**
1. 访问 https://www.zhetaoke.com/user/index.html
2. 注册账号并登录
3. 在"开放接口"页面获取 AppKey
4. 创建推广位获取 SID

### 2. 使用方法

#### 京东链接转链

```bash
# 转链京东商品
python3 ~/.openclaw/workspace/skills/taobaoke-tool/scripts/convert_link.py https://item.jd.com/100012043978.html

# 或短链接
python3 ~/.openclaw/workspace/skills/taobaoke-tool/scripts/convert_link.py https://u.jd.com/N10CESJ
```

**输出示例：**
```
✅ 识别平台: JD
✅ 商品ID: 100012043978
🔄 正在转链...
✅ 转链成功!
🔗 推广链接: https://3.cn/xxxxx-xxx

📦 正在获取商品信息...
📋 商品信息:
   名称: New Balance 2002RHO 运动鞋
   价格: ¥589
   佣金: ¥15.6
```

#### 比价功能

```bash
python3 ~/.openclaw/workspace/skills/taobaoke-tool/scripts/price_compare.py
```

## 使用场景

### 场景1：用户发京东链接

```
用户：https://u.jd.com/N10CESJ

系统处理：
1. 识别为京东链接
2. 调用折淘客API转链
3. 获取商品信息和佣金
4. 返回结果：

📦 New Balance 2002RHO
━━━━━━━━━━━━━━━━━━
💰 京东价：¥589
💎 你的佣金：¥15.6（约2.6%）

🔗 高佣转链：[点击购买-赚¥15.6]
```

### 场景2：比价+转链

```
用户：帮我找Nb2002rho最低价

系统处理：
1. 搜索各平台价格
2. 计算各平台佣金
3. 返回最优方案：

📦 Nb2002rho 全网比价
━━━━━━━━━━━━━━━━━━
🥇 京东：¥589 佣金¥15.6 ⭐推荐
🥈 淘宝：¥569 佣金¥14.2
🥉 拼多多：¥579 佣金¥11.5

💡 建议：京东虽然贵¥20，但佣金高¥1.4，且你说过"秒卖"
🔗 转链：[京东-¥589]
```

## 依赖技能

本技能会调用以下技能（已安装）：

- ✅ `taobao` - 淘宝/京东/拼多多比价
- ✅ `ecommerce-price-comparison` - 电商价格比较
- ✅ `ecommerce-scraper` - 电商数据爬取
- ✅ `url-reader` - 链接内容读取
- ✅ `jd-price-protect` - 京东自动价保

## 技术实现

### 转链流程

1. **识别平台**：解析链接识别京东/淘宝/拼多多
2. **提取ID**：从链接中提取商品ID
3. **调用折淘客API**：使用高佣转链接口
4. **获取商品信息**：查询商品名称、价格、佣金
5. **返回结果**：推广链接+商品信息

### 折淘客API

- **转链接口**：`https://api.zhetaoke.com/open_api/jd_link_convert.aspx`
- **商品信息**：`https://api.zhetaoke.com/open_api/jd_goods_info.aspx`
- **商品搜索**：`https://api.zhetaoke.com/open_api/jd_goods_search.aspx`

## 注意事项

- ⚠️ **必需配置**：必须先设置 ZHETAOKE_APP_KEY 和 ZHETAOKE_SID
- 💰 **佣金比例**：京东佣金约2-5%，具体看商品类目
- ⏰ **链接有效期**：推广链接通常有效期30天
- 🔄 **实时查询**：商品价格和佣金会实时变动

## 故障排除

### 转链失败

1. 检查环境变量是否配置
2. 确认折淘客账号状态正常
3. 检查链接格式是否正确

### 佣金显示为0

1. 该商品可能不参与推广
2. 或需要更高权限的联盟账号

## 版本记录

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v1.0.0 | 2026-03-11 | 初始版本，支持转链+比价+价保 |
| v1.1.0 | 2026-03-11 | 接入折淘客API，支持京东高佣转链 |
