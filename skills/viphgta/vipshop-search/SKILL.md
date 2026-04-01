---
name: vipshop-product-search
description: This skill should be used when user requests to search for products on Vipshop. Execute Python script search.py with the search keyword, which will search products, fetch details, and display them in a structured format.
---

# Vipshop Product Search

## Overview
This skill enables users to search for products on Vipshop by executing a Python script that calls the search API with product keywords, retrieves product IDs, fetches detailed product information, and displays it in a structured format including product names, prices, and other key information.

## When to Use
- Trigger when user asks to search for products on Vipshop
- Trigger when user wants to find product details for specific keywords
- Use for any Vipshop product search related queries

## Workflow

### 1. Receive Input
- Accept user input: product search keyword (商品关键词)
- Ensure keyword is not empty

### 2. Check Login Status
- Check if user has valid login tokens by checking the file `~/.vipshop-user-login/tokens.json`
- If the file exists and contains valid data with `cookies` field, proceed to step 3
- If the file does not exist or is invalid:
  1. Check if the `vipshop-user-login` skill is installed in the skills directory
  2. If `vipshop-user-login` skill is installed:
     - Automatically invoke the `vipshop-user-login` skill to initiate the login process
     - The skill will automatically:
       - Generate a QR code for login
       - Display the QR code to the user (open image file)
       - Poll the login status until user scans and confirms
       - Save login tokens to `~/.vipshop-user-login/tokens.json`
     - Display message: "检测到您尚未登录唯品会，正在为您生成登录二维码，请扫码登录..."
     - Wait for login to complete (user scans and confirms)
     - After successful login, automatically proceed to step 3 (execute search)
  3. If `vipshop-user-login` skill is NOT installed:
     - Display message: "检测到您尚未登录唯品会，且未安装 vipshop-user-login skill。请先安装 vipshop-user-login skill 并完成登录，然后再进行商品搜索。"
     - Provide instructions on how to install the vipshop-user-login skill
     - Do NOT automatically install the skill for the user
     - Do not proceed with search until user has installed the skill and logged in

### 3. Execute Python Script
- Execute the Python script `scripts/search.py` with the keyword as argument
- Command: `python3 scripts/search.py <keyword>`
- Example: `python3 scripts/search.py 连衣裙`

### 4. Script Processing
The Python script automatically handles:
- URL encoding of the keyword
- Calling the search API to get product IDs
- Calling the product detail API with all product IDs
- Parsing the response and returning structured JSON data
- Error handling with fallback mechanisms

### 5. Display Results
- The script outputs JSON data containing:
  - Search keyword (搜索关键词)
  - Total count of products found (总数)
  - Number of products displayed (当前展示)
  - List of products with all details (商品列表)
- Parse the JSON data and detect the user's current environment
- Format output according to the detected environment:
  - 企业微信: Markdown table format
  - QQ: Ark card + Markdown format
  - 飞书: Markdown table format
  - 钉钉: Markdown card format
  - 微信(个人): Plain text format (default)
  - Web: Markdown table with embedded images
- Display the following fields for each product:
  - 商品ID (Product ID)
  - 商品名 (Product Name)
  - 价格 (Current Price)
  - 原价 (Original Price)
  - 折扣 (Discount)
  - 卖点 (Sales Tips)
  - 品牌 (Brand)
  - 商品链接 (Product Link)

**CRITICAL REQUIREMENT: Complete Output**
- **ALWAYS display ALL 20 products in the search results**
- **NEVER truncate or omit any product from the list**
- The script always returns 20 products (当前展示 = 20), so you must display all 20 products
- Do not use placeholders like "... (more products)" or省略号
- Each product must be displayed with all its details (商品ID, 商品名, 价格, 原价, 折扣, 卖点, 品牌, 商品链接)
- If the output is too long, ensure all 20 products are still displayed completely without truncation

### 6. Pagination Support
- The script now supports pagination functionality
- The JSON output now includes pagination information:
  - `当前页` (Current Page): The current page number
  - `总页数` (Total Pages): Total number of pages
  - `当前偏移` (Current Offset): The current page offset value
  - `每页数量` (Page Size): Number of products per page (fixed at 20)
- **IMPORTANT**: After displaying the search results, ALWAYS check if there are more pages
- If `当前页 < 总页数`, add a prompt at the end:
  - "💡 提示：您可以说"下一页"查看更多商品（当前第 X/共 Y 页）"
  - Or: "💡 还有更多商品，输入"下一页"继续查看"
- When user says "下一页" (next page):
  - Remember the last search keyword and current page
  - Calculate the new page offset: `current_page * 20`
  - Execute: `python3 scripts/search.py <keyword> --page-offset <new_offset>`
  - Display the next page of results with the same formatting
- When user says "上一页" (previous page):
  - Remember the last search keyword and current page
  - Calculate the new page offset: `(current_page - 2) * 20`
  - Only proceed if current_page > 1
  - Execute: `python3 scripts/search.py <keyword> --page-offset <new_offset>`
  - Display the previous page of results with the same formatting
- Command line usage for pagination:
  - `python3 scripts/search.py <keyword> --page-offset 20` (page 2)
  - `python3 scripts/search.py <keyword> -p 40` (page 3)
  - Offset values: 0, 20, 40, 60, ... (page_number - 1) * 20

### 6.5. Price Range Filtering Support
- The script supports filtering products by price range using `priceMin` and `priceMax` parameters
- When user specifies a price range, use the API's price filtering functionality
- **IMPORTANT**: When user changes the price range (specifies new price_min/price_max), ALWAYS reset pageOffset to 0
- The JSON output will include a `价格区间` (Price Range) field when price filtering is active
- Command line usage for price range filtering:
  - `python3 scripts/search.py <keyword> --price-min 100 --price-max 300` (filter by price range 100-300)
  - `python3 scripts/search.py <keyword> -p 20 --price-min 50 --price-max 200` (page 2 with price range 50-200)
  - `python3 scripts/search.py <keyword> --price-min 200` (filter by minimum price only)
  - `python3 scripts/search.py <keyword> --price-max 500` (filter by maximum price only)
- **Price range parameter usage:**
  - `--price-min <value>`: Set minimum price (priceMin parameter)
  - `--price-max <value>`: Set maximum price (priceMax parameter)
  - Both parameters are optional and can be used independently or together
- **When user asks to filter by price:**
  - Prompt user to specify the price range if not provided
  - Example: "请输入您想要的价格区间，例如：100-300（表示100元到300元之间的商品）"
  - After user provides the price range, execute search with the price parameters and reset pageOffset to 0
- **Combining price filter with pagination:**
  - When user specifies price range, the search is performed with those filters from page 1
  - If user then says "下一页" or "上一页", maintain the same price range parameters
  - Only reset pageOffset to 0 when user changes the price range (specifies new price_min/price_max)

### 7. Handle Errors
- If the script returns an error, display the error message to the user
- The script has built-in error handling and fallback mechanisms

## Important Notes

### Script Location
- The script is located at: `skills/vipshop-product-search/scripts/search.py`
- The script uses Python standard library (urllib, json) - no external dependencies

### Output Format
The script outputs JSON data structured as:
```json
{
  "搜索关键词": "连衣裙",
  "总数": 2983,
  "当前页": 1,
  "总页数": 150,
  "当前展示": 20,
  "每页数量": 20,
  "当前偏移": 0,
  "商品列表": [
    {
      "序号": 1,
      "商品ID": "6920685689731485274",
      "商品链接": "https://detail.vip.com/detail-1710613281-6920685689731485274.html",
      "商品名": "商品名称",
      "价格": "164",
      "原价": "798",
      "折扣": "2.1折",
      "卖点": "30天低价",
      "品牌": "品牌名称"
    }
  ]
}
```

**Display Format to User:**
After parsing the JSON data, detect the user's current environment and format the output accordingly:

### Environment Detection and Output Formats

**1. 企业微信 - Markdown Table:**
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|--------|------|------|------|------|------|----------|
| 1 | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

**2. QQ - Ark Card + Markdown:**
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

### 商品1
**商品名称**: 商品名称
**品牌**: 品牌名称
**价格**: ¥199 (原价 ¥949)
**折扣**: 2.1折
**卖点**: 30天低价
[🔗 查看详情](https://detail.vip.com/detail-xxx-xxx.html)

---
```

**3. 飞书 - Markdown Table:**
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|--------|------|------|------|------|------|----------|
| 1 | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

**4. 钉钉 - Markdown Card:**
```markdown
## 🔍 为您找到 X 件商品，当前展示前 Y 个

### 1. 商品名称
- **品牌**: 品牌名称
- **价格**: ¥199 (原价 ¥949)
- **折扣**: 2.1折
- **卖点**: 30天低价
- **商品链接**: [点击查看](https://detail.vip.com/detail-xxx-xxx.html)

---
```

**5. 微信(个人) - Plain Text:**
```
🔍 为您找到 X 件商品，当前展示前 Y 个：

━━━ 第 1 个商品 ━━━
📦 商品ID：6920224576369549569
🏷️ 商品名：商品名称
💰 价格：¥199 (原价 ¥949)
🏷️ 折扣：2.1折
📌 30天低价
🏷️ 品牌：品牌名称
🔗 商品链接：https://detail.vip.com/detail-xxx-xxx.html

━━━ 第 2 个商品 ━━━
...
```

**6. Web - Markdown Table with Embedded Images:**
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品图片 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|----------|--------|------|------|------|------|------|----------|
| 1 | ![商品图](图片URL) | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

### Default Format
If environment cannot be detected, use WeChat (personal) plain text format as default.

### Error Handling
The script handles:
- Network exceptions (timeout, connection refused, etc.)
- API errors (code != 1)
- Empty results (products array is empty)
- Missing fields in product data
- Automatic fallback to showing only product IDs if detail fetch fails

### Display Rules
- Always display: Product ID, product name, current price, price label
- Display if available: Original price, discount, sales tips (e.g., "30天低价"), brand
- If marketPrice is missing, show only current price
- If saleDiscount is missing or empty, omit discount info
- If sellTips is missing or empty, omit sales tips
- If brandShowName is missing or empty, omit brand info

## Examples

### Example 0: User Not Logged In (vipshop-user-login skill installed)
**User input:** "搜索连衣裙"

**AI actions:**
1. Check if login tokens file exists at `~/.vipshop-user-login/tokens.json`
2. File does not exist or is invalid
3. Check if `vipshop-user-login` skill is installed in skills directory
4. Skill is installed
5. Automatically invoke vipshop-user-login skill
6. Display QR code to user
7. Poll login status until user scans and confirms
8. After successful login, automatically execute search

**Formatted Output to User:**
```
检测到您尚未登录唯品会，正在为您生成登录二维码，请扫码登录...

[QR code image is displayed automatically]

正在等待您扫码...
已检测到扫码，请在手机上确认登录...
登录成功！正在为您搜索商品...

🔍 为您找到 X 件商品，当前展示前 Y 个：
[Search results displayed]
```

### Example 0b: User Not Logged In (vipshop-user-login skill NOT installed)
**User input:** "搜索连衣裙"

**AI actions:**
1. Check if login tokens file exists at `~/.vipshop-user-login/tokens.json`
2. File does not exist or is invalid
3. Check if `vipshop-user-login` skill is installed in skills directory
4. Skill is NOT installed
5. Display message to user

**Formatted Output to User:**
```
检测到您尚未登录唯品会，且未安装 vipshop-user-login skill。

请先安装 vipshop-user-login skill 并完成登录，然后再进行商品搜索。

安装完成后，您可以使用 vipshop-user-login skill 进行唯品会登录。
```

### Example 1: Successful Search
**User input:** "连衣裙"

**AI actions:**
1. Execute: `python3 scripts/search.py 连衣裙`
2. Parse the JSON output from the script
3. Format and display the results to the user

**Script Output (JSON):**
```json
{
  "搜索关键词": "连衣裙",
  "总数": 2983,
  "当前展示": 20,
  "商品列表": [
    {
      "序号": 1,
      "商品ID": "6920685689731485274",
      "商品链接": "https://detail.vip.com/detail-1710613281-6920685689731485274.html",
      "商品名": "商品名称",
      "价格": "164",
      "原价": "798",
      "折扣": "2.1折",
      "卖点": "30天低价",
      "品牌": "品牌名称"
    }
  ]
}
```

**Formatted Output to User:**
*Example for WeChat (personal) environment:*
```
🔍 为您找到 2,983 件商品，当前展示前 20 个：

━━━ 第 1 个商品 ━━━
📦 商品ID：6920685689731485274
🔗 商品链接：https://detail.vip.com/detail-1710613281-6920685689731485274.html
🏷️ 商品名：商品名称
💰 价格：¥164 (原价 ¥798)
🏷️ 折扣：2.1折
📌 30天低价
🏷️ 品牌：品牌名称

━━━ 第 2 个商品 ━━━
... (continue displaying all 20 products in the same format)

NOTE: In actual implementation, ALL 20 products must be displayed completely without truncation.
The above example only shows the first product for brevity, but the actual output must include all 20 products.
```

*Example for 企业微信 / 飞书 / Web environment:*
```markdown
🔍 为您找到 2,983 件商品，当前展示前 20 个：

| 序号 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|--------|------|------|------|------|------|----------|
| 1 | 商品名称 | 品牌名称 | ¥164 | ¥798 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-1710613281-6920685689731485274.html) |
```

### Example 2: No Results
**User input:** "xyz123"

**AI actions:**
1. Execute: `python3 scripts/search.py xyz123`
2. Parse JSON output
3. Display error message to user

**Script Output (JSON):**
```json
{
  "error": "未找到相关商品"
}
```

**Formatted Output to User:**
```
未找到相关商品
```

### Example 3: Auto-Triggered Login Flow
**User input:** "搜索连衣裙" (user not logged in, vipshop-user-login skill installed)

**AI actions:**
1. Check if login tokens file exists at `~/.vipshop-user-login/tokens.json`
2. File does not exist or is invalid
3. Check if `vipshop-user-login` skill is installed in skills directory
4. Skill is installed
5. Execute: `python3 skills/vipshop-user-login/scripts/vip_login.py` to generate QR code
6. Display QR code to user
7. Poll login status until user scans and confirms
8. After successful login, execute: `python3 scripts/search.py 连衣裙`
9. Display search results

**Formatted Output to User:**
```
检测到您尚未登录唯品会，正在为您生成登录二维码，请扫码登录...

[QR code image opens in default image viewer]

正在等待您扫码...
已检测到扫码，请在手机上确认登录...
✓ 登录成功！

🔍 为您找到 2,983 件商品，当前展示前 20 个：

━━━ 第 1 个商品 ━━━
📦 商品ID：6920685689731485274
🔗 商品链接：https://detail.vip.com/detail-1710613281-6920685689731485274.html
🏷️ 商品名：商品名称
💰 价格：¥164 (原价 ¥798)
🏷️ 折扣：2.1折
📌 30天低价
🏷️ 品牌：品牌名称

━━━ 第 2 个商品 ━━━
... (continue displaying all 20 products in the same format)

NOTE: In actual implementation, ALL 20 products must be displayed completely without truncation.
The above example only shows the first product for brevity, but the actual output must include all 20 products.
```

### Example 4: API Error
**User input:** "连衣裙" (but API is down)

**AI actions:**
1. Execute: `python3 scripts/search.py 连衣裙`
2. Parse JSON output
3. Display error message to user

**Script Output (JSON):**
```json
{
  "error": "接口调用失败：搜索请求失败: timeout"
}
```

**Formatted Output to User:**
```
接口调用失败：搜索请求失败: timeout
```

### Example 5: Price Range Filtering
**User input:** "搜索100-300元之间的连衣裙"

**AI actions:**
1. Parse the price range: price_min = 100, price_max = 300
2. Execute: `python3 scripts/search.py 连衣裙 --price-min 100 --price-max 300 --page-offset 0`
3. Parse JSON output
4. Format and display results

**Script Output (JSON):**
```json
{
  "搜索关键词": "连衣裙",
  "总数": 245,
  "价格区间": "¥100-¥300",
  "当前页": 1,
  "总页数": 13,
  "当前展示": 20,
  "每页数量": 20,
  "当前偏移": 0,
  "商品列表": [
    {
      "序号": 1,
      "商品ID": "6920685689731485274",
      "商品链接": "https://detail.vip.com/detail-1710613281-6920685689731485274.html",
      "商品名": "商品名称",
      "价格": "164",
      "原价": "798",
      "折扣": "2.1折",
      "卖点": "30天低价",
      "品牌": "品牌名称"
    }
  ]
}
```

**Formatted Output to User:**
```
🔍 在价格区间 ¥100-¥300 内找到 245 件商品，当前展示前 20 个：

━━━ 第 1 个商品 ━━━
📦 商品ID：6920685689731485274
🔗 商品链接：https://detail.vip.com/detail-1710613281-6920685689731485274.html
🏷️ 商品名：商品名称
💰 价格：¥164 (原价 ¥798)
🏷️ 折扣：2.1折
📌 30天低价
🏷️ 品牌：品牌名称

━━━ 第 2 个商品 ━━━
... (continue displaying all 20 products in the same format)
```

### Example 6: Changing Price Range Resets Pagination
**User input:** "重新搜索，价格区间改为200-500元" (user was previously on page 3)

**AI actions:**
1. Parse the new price range: price_min = 200, price_max = 500
2. Reset pageOffset to 0 (new search with new filters)
3. Execute: `python3 scripts/search.py 连衣裙 --price-min 200 --price-max 500 --page-offset 0`
4. Display results from page 1

**Formatted Output to User:**
```
🔍 在价格区间 ¥200-¥500 内找到 189 件商品，当前展示前 20 个：

[Display 20 products in the filtered price range]

📊 搜索结果：第 1/10 页，共 189 件商品
💡 输入"下一页"查看更多商品
```

## Important Reminder: Complete Output Required

**CRITICAL: All search results must display ALL 20 products completely**

When displaying search results to users, you MUST:

1. **Display ALL 20 products** that are returned by the search script
2. **NEVER truncate or omit** any product from the results
3. **NEVER use placeholders** like "... (more products)" or省略号
4. **Each product must include** all fields:
   - 商品ID (Product ID)
   - 商品名 (Product Name)
   - 价格 (Current Price)
   - 原价 (Original Price)
   - 折扣 (Discount)
   - 卖点 (Sales Tips) - if available
   - 品牌 (Brand)
   - 商品链接 (Product Link)

**Why this is important:**
- The search script always returns exactly 20 products (当前展示 = 20)
- Users expect to see all available search results
- Truncating results reduces user experience and trust
- Examples in this documentation may show abbreviated formats for brevity, but actual implementation must display all products

**Formatting requirements:**
- Use consistent formatting for all 20 products
- Maintain the same structure and field order for each product
- Ensure all product details are complete and accurate
- If using table format, the table must have 20 rows (plus header row)

**Remember:** Always display the complete list of 20 products, regardless of output length.

## Environment-Specific Output Formats

### 企业微信
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|--------|------|------|------|------|------|----------|
| 1 | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
| 2 | 商品名称2 | 品牌名称2 | ¥182 | ¥608 | 3折 | 限量抢，抢完恢复¥195 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

### QQ (Ark Card + Markdown)
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

### 商品1
**商品名称**: 商品名称
**品牌**: 品牌名称
**价格**: ¥199 (原价 ¥949)
**折扣**: 2.1折
**卖点**: 30天低价
[🔗 查看详情](https://detail.vip.com/detail-xxx-xxx.html)

---

### 商品2
**商品名称**: 商品名称2
**品牌**: 品牌名称2
**价格**: ¥182 (原价 ¥608)
**折扣**: 3折
**卖点**: 限量抢，抢完恢复¥195
[🔗 查看详情](https://detail.vip.com/detail-xxx-xxx.html)

---
```

### 飞书
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|--------|------|------|------|------|------|----------|
| 1 | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
| 2 | 商品名称2 | 品牌名称2 | ¥182 | ¥608 | 3折 | 限量抢，抢完恢复¥195 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

### 钉钉
```markdown
## 🔍 为您找到 X 件商品，当前展示前 Y 个

### 1. 商品名称
- **品牌**: 品牌名称
- **价格**: ¥199 (原价 ¥949)
- **折扣**: 2.1折
- **卖点**: 30天低价
- **商品链接**: [点击查看](https://detail.vip.com/detail-xxx-xxx.html)

### 2. 商品名称2
- **品牌**: 品牌名称2
- **价格**: ¥182 (原价 ¥608)
- **折扣**: 3折
- **卖点**: 限量抢，抢完恢复¥195
- **商品链接**: [点击查看](https://detail.vip.com/detail-xxx-xxx.html)

---
```

### 微信(个人)
```
🔍 为您找到 X 件商品，当前展示前 Y 个：

━━━ 第 1 个商品 ━━━
📦 商品ID：6920224576369549569
🏷️ 商品名：商品名称
💰 价格：¥199 (原价 ¥949)
🏷️ 折扣：2.1折
📌 30天低价
🏷️ 品牌：品牌名称
🔗 商品链接：https://detail.vip.com/detail-xxx-xxx.html

━━━ 第 2 个商品 ━━━
📦 商品ID：6921329412347887709
🏷️ 商品名：商品名称2
💰 价格：¥182 (原价 ¥608)
🏷️ 折扣：3折
📌 限量抢，抢完恢复¥195
🏷️ 品牌：品牌名称2
🔗 商品链接：https://detail.vip.com/detail-xxx-xxx.html

---
```

### Web
```markdown
🔍 为您找到 X 件商品，当前展示前 Y 个：

| 序号 | 商品图片 | 商品名 | 品牌 | 价格 | 原价 | 折扣 | 卖点 | 商品链接 |
|------|----------|--------|------|------|------|------|------|----------|
| 1 | ![商品图](图片URL) | 商品名称 | 品牌名称 | ¥199 | ¥949 | 2.1折 | 30天低价 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
| 2 | ![商品图2](图片URL2) | 商品名称2 | 品牌名称2 | ¥182 | ¥608 | 3折 | 限量抢，抢完恢复¥195 | [查看详情](https://detail.vip.com/detail-xxx-xxx.html) |
```

**Note**: For Web environment, attempt to fetch and embed product images when available.

## Implementation Requirements
- Check if user has valid login tokens by verifying the file `~/.vipshop-user-login/tokens.json` exists and contains valid data with `cookies` field
- Check if `vipshop-user-login` skill is installed in the skills directory
- If user is not logged in:
  - If `vipshop-user-login` skill is installed: automatically invoke the skill to trigger login flow
    - Execute: `python3 skills/vipshop-user-login/scripts/vip_login.py`
    - Display message: "检测到您尚未登录唯品会，正在为您生成登录二维码，请扫码登录..."
    - Wait for the login to complete (user scans QR code and confirms)
    - After successful login, automatically proceed with search
  - If `vipshop-user-login` skill is NOT installed: prompt user to install it, do NOT install automatically
- Only proceed with search after confirming user has valid login tokens
- Execute the Python script `scripts/search.py` with the search keyword as argument
- Parse JSON output from the script
- Detect the user's current environment (企业微信, QQ, 飞书, 钉钉, 微信(个人), Web)
- Format and display the results to the user according to the detected environment
- **CRITICAL: Display ALL 20 products completely without truncation or omission**
- The script handles all URL encoding, API calls, data parsing
- No need to manually construct URLs or parse JSON responses
- The script includes comprehensive error handling and fallback mechanisms

### Environment Detection Priority
1. Check platform-specific indicators from the conversation context or user agent
2. Default to WeChat (personal) plain text format if environment cannot be determined
3. For Web environment, also attempt to embed product images when available

## Script Execution

**IMPORTANT: Before executing the script, always verify user login status.**

1. Check if `~/.vipshop-user-login/tokens.json` exists and contains valid data
2. If user is not logged in:
   - If `vipshop-user-login` skill is installed: automatically invoke it to trigger login flow
     - Execute: `python3 skills/vipshop-user-login/scripts/vip_login.py`
     - Display QR code to user
     - Wait for user to scan and confirm login
     - After successful login, automatically proceed to step 3
   - If `vipshop-user-login` skill is NOT installed: prompt user to install it
3. Only proceed with script execution after confirming user has valid login tokens

To search for products, execute the Python script:

```bash
python3 scripts/search.py <keyword> [--page-offset <offset>] [-p <offset>] [--price-min <min>] [--price-max <max>]
```

**Examples:**
```bash
# First page (default)
python3 scripts/search.py 连衣裙

# Second page (offset = 20)
python3 scripts/search.py 连衣裙 --page-offset 20

# Third page (offset = 40)
python3 scripts/search.py 连衣裙 -p 40

# Filter by price range (100-300)
python3 scripts/search.py 连衣裙 --price-min 100 --price-max 300

# Filter by minimum price only
python3 scripts/search.py 连衣裙 --price-min 200

# Filter by maximum price only
python3 scripts/search.py 连衣裙 --price-max 500

# Combine pagination with price filter (page 2, price range 50-200)
python3 scripts/search.py 连衣裙 -p 20 --price-min 50 --price-max 200

# Short form
python3 scripts/search.py Nike鞋
```

**Pagination offset calculation:**
- Page 1: offset = 0 (default)
- Page 2: offset = 20
- Page 3: offset = 40
- Page N: offset = (N - 1) * 20

**Price range filtering:**
- `--price-min <value>`: Filter products with price >= value
- `--price-max <value>`: Filter products with price <= value
- Both parameters are optional and can be used independently or together
- When user changes the price range, pageOffset automatically resets to 0

The script will automatically:
1. URL encode the keyword
2. Call the search API to get product IDs with the specified page offset
3. Call the product detail API with all product IDs
4. Parse the response and return structured JSON data
5. Handle errors gracefully with fallback mechanisms
6. Include pagination information (current page, total pages, etc.)

After executing the script:
1. Parse the JSON output
2. Format the data according to the specified display format
3. Display the formatted results to the user
4. Include all fields: 商品ID, 商品名, 价格, 原价, 折扣, 卖点, 品牌, 商品链接
5. Check if there are more pages and add pagination prompt if needed
