# AssetClaw - 认证与工作流参考

## 1. Base URL

- 默认本地: `http://160ttth72797.vicp.fun/api`
- Skill 运行时优先读取 `ASSETHUB_API_URL` 环境变量

## 2. 登录

### Endpoint

```
POST /api/users/login
```

### Request

```json
{
  "username": "your-user",
  "password": "your-password"
}
```

### Response - 保存以下字段

| 字段 | 说明 |
|------|------|
| `data.token` | JWT Bearer Token |
| `data.user.tenant_id` | 当前租户 ID |
| `data.user.username` | 用户名 |
| `data.user.real_name` | 真实姓名 |
| `data.user.role` | 角色 |
| `data.enterprises` | 企业列表（超级管理员可用） |

## 3. 通用请求头

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
X-Tenant-ID: <tenant_id>   # 仅超级管理员跨租户操作时需要
```

## 4. 租户规则

| 用户类型 | 默认行为 |
|---------|---------|
| 普通用户 | 使用 `data.user.tenant_id`，不要切换 |
| `super_admin` | 只有明确跨租户时才传 `X-Tenant-ID` |

## 5. 标准响应解析

```json
// 成功
{ "success": true, "data": { ... }, "timestamp": "..." }

// 失败
{ "success": false, "message": "错误信息", "code": "BAD_REQUEST" }
```

列表数据可能出现在:
- `data`
- `data.list`
- `data.records`

分页信息可能出现在:
- `pagination`
- `data.pagination`

## 6. 错误处理

| 状态码 | 含义 | 处理 |
|--------|------|------|
| `400` | 参数错误 | 补全字段 |
| `401` | Token 无效 | 重新登录 |
| `403` | 无权限 | 停止写操作 |
| `404` | 资源不存在 | 重新查询 |
| `429` | 限流 | 退避重试 |
| `500` | 服务异常 | 稍后重试 |

## 7. 报修申请优先走 AI 安全入口

- 使用 `POST /api/maintenance/ai/submit-request`
- 适用于 skill / MCP / Web AI 的报修创建
- 该入口不需要二次风险确认
- 成功后仍然进入 `待审批`
- 审批 / 开始 / 完成 仍沿用 `/api/maintenance/requests/{id}/...`

## 8. 先查后写模式

除报修安全入口外，其他写操作（POST/PUT/DELETE）遵循：

1. 查询目标对象
2. 确认 ID 或编号
3. 若是报修创建，优先调用 `POST /api/maintenance/ai/submit-request`
4. 其他场景再执行对应写操作
5. 回查确认最终状态

## 9. 刷新 Token

```
POST /api/users/refresh-token
```

## 10. 获取当前用户

```
GET /api/users/me
```

## 11. 超级管理员跨租户示例

```bash
export ASSETHUB_TENANT_ID=2
bash scripts/assethub_api.sh request GET "/assets?page=1&pageSize=20"
```
