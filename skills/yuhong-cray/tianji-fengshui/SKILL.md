---
name: tianji-fengshui
slug: tianji-fengshui
description: >
  玄机子 - 风水大师智慧助手。专精风水命理、八字分析、掌纹解读、图像分析。
  智能模型切换：图像分析使用豆包视觉模型，聊天对话使用DeepSeek模型 这里的视觉模型和文本模型都需要进行全局配置。
version: 1.8.0
author: 玄机子
tags: [风水, 命理, 八字, 掌纹, 图像分析, 豆包, deepseek, 智能切换]
metadata: {
  "clawdbot": {
    "emoji": "🧭",
    "persona": "玄机子 - 风水灵兽，结合传统智慧与现代AI的守护灵",
    "capabilities": ["image_analysis", "chat", "fengshui", "bazi", "palm_reading", "subagent_integration"],
    "model_routing": {
      "image_analysis": "doubao-seed-2-0-pro-260215",
      "default_chat": "deepseek/deepseek-chat"
    },
    "execution_capabilities": {
      "file_operations": ["read_user_provided_paths", "write_temporary_scripts", "create_subagent_configs"],
      "process_creation": ["spawn_openclaw_sessions", "execute_generated_commands"],
      "required_tools": ["exec", "read", "write", "edit"],
      "risk_level": "moderate",
      "user_awareness_required": true
    },
    "credential_management": {
      "platform_config_read": "required",
      "credential_storage": "openclaw_managed",
      "api_key_handling": "indirect_via_platform",
      "config_access_scope": "read_only_openclaw_config",
      "sensitive_data_exposure": "potential_config_file_access"
    },
    "persistence_and_privilege": {
      "always_enabled": false,
      "invocation_mode": "user_invoked_only",
      "system_modification": "none",
      "skill_modification": "none",
      "file_creation_scope": "/tmp/tianji_* only",
      "process_creation_scope": "openclaw_sessions_only",
      "execution_boundary": "requires_user_confirmation",
      "recommended_environment": "controlled_or_sandboxed"
    }
  }
}
allowed-tools: [exec, read, write, edit]
---

# 天机·玄机子 🧭

风水大师智慧助手，专精传统风水命理与现代AI分析。

## 核心特性

### 🧠 智能模型路由
- **图像分析**：自动使用豆包视觉模型 (`doubao-seed-2-0-pro-260215`)
- **聊天对话**：自动使用DeepSeek模型 (`deepseek/deepseek-chat`)
- **专业分析**：风水布局、八字命理、掌纹解读、面相分析

### 📸 图像分析能力
- **掌纹分析**：传统掌相学结合AI视觉识别
- **面相分析**：五官特征与运势解读  
- **风水格局**：建筑布局与环境能量分析
- **通用图像**：智能识别与专业解读

### 🔄 Subagent集成
- 通过OpenClaw subagent调用专业视觉模型
- 自动生成分析任务描述和配置
- 支持批量处理和自动化工作流

## 快速开始

### 1. 环境要求
- OpenClaw平台（已配置volcengine和deepseek提供商）
- Python 3.6+ 环境
- Pillow库（用于图像处理）
- 技能安装在OpenClaw workspace目录中（自动检测路径）

### 2. 基本使用

#### 八字分析
```
用户：姓名：张三 性别：男 出生：1990年1月1日 子时
玄机子：自动排八字、分析五行、推算大运、提供建议
```

#### 掌纹分析
```
用户：分析我的掌纹图片 /tmp/palm.jpg
玄机子：调用豆包视觉模型分析，结合传统掌相学解读
```

#### 风水咨询
```
用户：这个办公室布局风水如何？
玄机子：分析方位、门窗、家具布局，提供优化建议
```

### 3. Subagent图像分析

```bash
# 掌纹分析
python3 tianji_subagent_integration.py /tmp/palm.jpg palm

# 面相分析
python3 tianji_subagent_integration.py /tmp/face.jpg face

# 风水分析
python3 tianji_subagent_integration.py /tmp/house.jpg fengshui
```

## 文件结构

```
tianji-fengshui/
├── SKILL.md                  # 技能文档
├── tianji_core.py           # 核心处理器
├── tianji_subagent_integration.py  # Subagent集成
├── install.sh               # 安装脚本
├── knowledge/               # 知识库文件
│   ├── fengshui_bazi_palm_books.md
│   └── traditional_knowledge.md
├── examples.md              # 使用示例
├── test_subagent_integration.sh    # 集成测试
├── test_path_safety.py      # 路径安全测试
└── test_knowledge.py        # 知识库测试
```

## ⚠️ 指令范围与执行风险说明

### 🔍 明确的指令范围（基于审查反馈）

#### 1. 文件读取操作
- **OpenClaw全局配置**：读取平台配置获取volcengine和deepseek提供商设置
- **用户提供图片路径**：读取用户明确指定的图片文件（`.jpg/.png/.jpeg`）
- **技能自身文件**：读取技能脚本和配置文件

#### 2. 文件写入与生成
- **临时脚本生成**：创建 `/tmp/tianji_*.sh` 执行脚本
- **临时配置生成**：创建 `/tmp/tianji_subagent_*.json` subagent配置
- **文件位置**：所有生成文件仅在 `/tmp/` 目录
- **文件内容**：包含用户提供的路径和生成的命令

#### 3. 进程创建与执行
- **OpenClaw会话生成**：运行 `openclaw sessions spawn --config ...` 命令
- **子进程创建**：通过subagent调用AI模型进行分析
- **命令执行**：可能建议执行生成的临时脚本

### 🚨 执行能力与风险说明

#### 工具权限要求
本技能需要以下工具权限以实现功能：
- **exec**：执行shell命令和OpenClaw命令
- **read**：读取文件内容和配置
- **write**：生成临时脚本和配置文件
- **edit**：修改临时文件内容

#### 潜在风险点
1. **临时命令执行**：技能生成并可能建议执行临时脚本
2. **子进程创建**：创建OpenClaw会话和AI模型调用
3. **文件系统访问**：读取用户指定路径，写入临时文件
4. **平台会话触发**：调用OpenClaw平台功能

#### 风险缓解措施
1. ✅ **非自动执行**：技能仅生成建议命令，不自动执行
2. ✅ **用户审查要求**：必须审查所有生成的 `/tmp/tianji_*` 文件
3. ✅ **透明操作**：所有文件生成和命令建议对用户可见
4. ✅ **安全边界**：在用户权限下运行，不提升特权

### ⚠️ 持久性与权限风险说明

#### 审查反馈核心问题
**审查反馈原文**:
> "技能未设置 always:true（默认允许自主调用），没有请求修改其他技能或系统设置，但 SKILL.md 和代码允许生成并（通过建议/示例）执行临时脚本和 spawn OpenClaw sessions。生成/执行临时脚本是其功能的一部分，但把 exec/read/write/edit 列为 allowed-tools 意味着技能在有权限时可以创建/修改文件并运行命令——这在功能上是必要，但增加了风险边界，建议限制在受控环境或人工确认后执行。"

### 🔐 凭证管理与配置读取风险说明

#### 审查反馈核心问题
**审查反馈原文**:
> "注册表元数据列出无 required env vars，但代码/文档读取 OpenClaw 配置（/home/test/.openclaw/config.json）以获取模型配置。读取平台配置对实现模型路由是合理的，但这些配置通常会包含 API 密钥或凭证位置：虽然文档多次声明'凭证由平台管理，不直接处理 API 密钥'，代码和测试把 OpenClaw 配置文件路径标记为'可读/安全'，这可能导致技能在运行时读取包含敏感信息的文件。允许读取 /.openclaw/ 下的配置被视为超出普通'仅读用户图片'的最小权限，应在安装前确认平台配置如何存储/加密凭证。"

#### 持久性与权限架构分析

##### 1. 持久性设置分析
| 设置项 | 当前配置 | 安全含义 | 用户影响 |
|--------|----------|----------|----------|
| **always:true** | `false` | 技能不会自动运行 | 用户必须明确调用技能 |
| **invocation_mode** | `user_invoked_only` | 仅用户触发执行 | 防止未经授权的自动执行 |
| **系统修改权限** | `none` | 不修改系统设置 | 保护系统完整性 |
| **技能修改权限** | `none` | 不修改其他技能 | 保护技能生态系统 |

##### 2. 工具权限风险分析
| 工具 | 功能必要性 | 风险等级 | 控制措施 |
|------|------------|----------|----------|
| **exec** | 必需（执行命令） | 高 | 用户确认，受控环境 |
| **read** | 必需（读取文件） | 中 | 路径验证，最小访问 |
| **write** | 必需（生成脚本） | 中 | 仅 `/tmp/`，用户审查 |
| **edit** | 可选（修改文件） | 低 | 仅修改临时文件 |

##### 3. 执行边界控制
```yaml
# 技能执行边界配置
execution_boundaries:
  file_creation:
    location: "/tmp/tianji_* only"
    pattern: "tianji_[type]_[pid].[ext]"
    lifetime: "temporary (session)"
    
  process_creation:
    scope: "openclaw_sessions_only"
    command: "openclaw sessions spawn"
    isolation: "subagent_runtime"
    
  user_confirmation:
    required: true
    level: "explicit_for_execution"
    audit: "logged_and_tracked"
    
  environment_restriction:
    recommended: "controlled_or_sandboxed"
    alternatives: ["development", "testing", "production_with_controls"]
```

##### 4. 风险边界扩展分析
**审查反馈关键点**:
> "生成/执行临时脚本是其功能的一部分，但把 exec/read/write/edit 列为 allowed-tools 意味着技能在有权限时可以创建/修改文件并运行命令——这在功能上是必要，但增加了风险边界"

**风险扩展分析**:
1. **文件创建风险**：技能可以创建 `/tmp/tianji_*.sh` 脚本文件
2. **命令执行风险**：技能可以建议执行 `openclaw sessions spawn` 等命令
3. **进程创建风险**：技能可以创建子进程和OpenClaw会话
4. **权限提升风险**：在用户权限下运行，可能继承用户权限

**控制措施**:
1. ✅ **非自动执行**：技能仅生成建议命令，不自动执行
2. ✅ **用户审查要求**：必须审查所有生成的临时文件
3. ✅ **透明操作**：所有文件生成和命令建议对用户可见
4. ✅ **环境限制**：建议在受控环境或沙盒中运行

##### 5. 受控环境实施指南

###### 5.1 沙盒环境配置
```bash
# 创建专用沙盒用户
sudo useradd -r -s /bin/false tianji-sandbox
sudo mkdir -p /var/sandbox/tianji
sudo chown tianji-sandbox:tianji-sandbox /var/sandbox/tianji

# 设置资源限制
sudo systemd-run --user --scope \
  -p MemoryLimit=512M \
  -p CPUQuota=50% \
  -p IPAddressDeny=any \
  -p RestrictNamespaces=yes \
  -p PrivateTmp=yes \
  python3 tianji_core.py
```

###### 5.2 容器化部署
```dockerfile
# Dockerfile示例
FROM python:3.9-slim

# 创建非root用户
RUN useradd -r -s /bin/false tianji

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制技能文件
COPY . /app
WORKDIR /app

# 设置权限
RUN chown -R tianji:tianji /app
USER tianji

# 只读挂载配置
VOLUME ["/tmp"]
CMD ["python3", "tianji_core.py"]
```

###### 5.3 人工确认流程
```python
# 人工确认实现示例
def require_human_confirmation(command, context):
    """要求人工确认危险操作"""
    print(f"⚠️  需要人工确认的操作:")
    print(f"   命令: {command}")
    print(f"   上下文: {context}")
    print(f"   生成时间: {datetime.now()}")
    
    response = input("确认执行? (yes/no): ").strip().lower()
    if response == "yes":
        print("✅ 已确认，开始执行...")
        return True
    else:
        print("❌ 已取消操作")
        return False

# 在执行前调用
if require_human_confirmation("openclaw sessions spawn", "掌纹分析"):
    execute_command("openclaw sessions spawn --config ...")
```

##### 6. 权限最小化配置

###### 6.1 文件系统权限
```bash
# 设置最小文件权限
# 技能目录（只读）
chmod -R 555 /home/test/.openclaw/workspace/skills/tianji-fengshui

# 临时目录（读写）
chmod 1777 /tmp  # sticky bit防止删除他人文件

# 配置文件（只读）
chmod 400 ~/.openclaw/config.json

# 日志目录（只写）
mkdir -p /var/log/tianji
chmod 733 /var/log/tianji  # 所有者读写执行，组和其他写执行
```

###### 6.2 进程权限限制
```bash
# 使用Linux能力限制
setcap -r /usr/bin/python3  # 移除所有特权
setcap cap_net_bind_service=ep /usr/bin/python3  # 仅允许绑定端口

# 使用seccomp过滤器
seccomp-tools dump /usr/bin/python3 > python3.seccomp
# 编辑过滤器，移除危险系统调用

# 使用AppArmor配置文件
aa-genprof python3
# 生成并应用限制性配置文件
```

###### 6.3 网络权限控制
```bash
# 使用iptables限制网络访问
# 只允许访问必要的AI服务API
iptables -A OUTPUT -p tcp -d api.deepseek.com --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d ark.cn-beijing.volces.com --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -j DROP  # 拒绝其他所有出站连接

# 使用网络命名空间隔离
ip netns add tianji-ns
ip netns exec tianji-ns python3 tianji_core.py
```

##### 7. 监控与审计配置

###### 7.1 文件操作监控
```bash
# 监控临时文件创建
inotifywait -m /tmp -e create |
while read path action file; do
    if [[ "$file" == tianji_* ]]; then
        echo "临时文件创建: $(date) - $file" >> /var/log/tianji_file_ops.log
        # 可选：自动审查文件内容
        review_file_content "/tmp/$file"
    fi
done
```

###### 7.2 命令执行审计
```bash
# 使用auditd审计命令执行
auditctl -a exit,always -F arch=b64 -S execve -k tianji_command_exec
auditctl -a exit,always -F arch=b32 -S execve -k tianji_command_exec

# 定期分析审计日志
ausearch -k tianji_command_exec -ts today | \
  grep -E "execve|openclaw" | \
  awk '{print $1, $2, $3, $12, $13}' > /var/log/tianji_command_audit.log
```

###### 7.3 资源使用监控
```bash
# 监控技能资源使用
while true; do
    TIMESTAMP=$(date +%s)
    # CPU使用
    CPU_USAGE=$(ps -C python3 -o %cpu --no-headers | awk '{sum+=$1} END {print sum}')
    # 内存使用
    MEM_USAGE=$(ps -C python3 -o rss --no-headers | awk '{sum+=$1} END {print sum/1024 "MB"}')
    # 文件描述符
    FD_COUNT=$(lsof -p $(pgrep -f "tianji.*\.py") 2>/dev/null | wc -l)
    
    echo "$TIMESTAMP,CPU:$CPU_USAGE,MEM:$MEM_USAGE,FD:$FD_COUNT" >> /var/log/tianji_resource.log
    
    # 检查异常
    if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
        echo "警告: CPU使用率过高" | mail -s "Tianji资源告警" admin@example.com
    fi
    
    sleep 60
done
```

##### 8. 部署环境分类指南

###### 8.1 环境分类标准
```yaml
environments:
  development:
    security_level: "low"
    controls: "basic_monitoring"
    recommendation: "仅用于开发和测试"
    
  testing:
    security_level: "medium"
    controls: ["sandbox", "resource_limits", "audit_logging"]
    recommendation: "功能测试和安全验证"
    
  staging:
    security_level: "high"
    controls: ["containerization", "network_restrictions", "human_confirmation"]
    recommendation: "预生产环境，模拟生产"
    
  production:
    security_level: "maximum"
    controls: ["full_isolation", "real_time_monitoring", "automated_audit", "incident_response"]
    recommendation: "生产使用，需完整安全控制"
```

###### 8.2 环境选择决策树
```
开始
  ↓
是否需要AI分析功能？
  ├─ 否 → 不使用本技能
  └─ 是 → 选择环境类型？
        ├─ 开发测试 → 使用development环境
        ├─ 功能验证 → 使用testing环境
        ├─ 集成测试 → 使用staging环境
        └─ 生产使用 → 使用production环境
              ↓
        实施完整安全控制
              ↓
        定期安全审查
```

##### 9. 用户责任矩阵

###### 9.1 必须执行的责任
| 责任项 | 具体操作 | 频率 | 验证方法 |
|--------|----------|------|----------|
| **环境选择** | 根据用途选择合适环境 | 每次部署 | 环境检查清单 |
| **权限配置** | 实施最小权限原则 | 安装时 | 权限审计脚本 |
| **文件审查** | 审查所有生成文件 | 每次生成 | 内容检查命令 |
| **命令确认** | 确认理解执行命令 | 每次执行 | 人工确认流程 |

###### 9.2 建议执行的责任
| 责任项 | 具体操作 | 频率 | 安全收益 |
|--------|----------|------|----------|
| **安全审计** | 定期审查技能行为 | 每月 | 异常检测 |
| **日志分析** | 分析操作日志 | 每周 | 行为理解 |
| **环境加固** | 持续改进安全配置 | 每季度 | 风险降低 |
| **应急演练** | 测试应急响应流程 | 每半年 | 准备度提升 |

##### 10. 合规性声明

###### 10.1 安全标准符合性
- ✅ **最小权限原则**：仅请求必要权限
- ✅ **职责分离**：用户调用，技能执行，平台管理
- ✅ **审计跟踪**：提供完整的操作日志
- ✅ **透明操作**：所有操作对用户可见
- ✅ **应急响应**：制定应急响应计划

###### 10.2 风险接受声明
**接受的风险（功能必要）**:
1. 临时文件创建权限（生成脚本需要）
2. 命令执行建议权限（调用OpenClaw需要）
3. 进程创建权限（subagent集成需要）
4. 文件读取权限（图片分析和配置读取需要）

**控制的风险**:
1. 通过用户确认控制自动执行风险
2. 通过环境隔离控制权限扩散风险
3. 通过监控审计控制滥用风险
4. 通过应急响应控制事件影响

**剩余风险**:
1. 用户配置错误导致的安全问题
2. 平台漏洞被利用的风险
3. 环境安全假设不成立的风险

**重要提醒**：使用本技能即表示您理解并接受上述持久性与权限风险说明，并承诺在适当的受控环境中使用，实施必要的安全控制措施。

#### 凭证管理架构说明

##### 1. 凭证流转流程
```
用户API密钥 → OpenClaw平台加密存储 → 技能读取配置 → 平台API调用
    ↓                ↓                    ↓              ↓
[用户提供]   [平台安全存储]      [只读配置访问]    [安全API网关]
```

##### 2. 技能权限分析
| 权限类型 | 具体行为 | 必要性 | 风险等级 | 缓解措施 |
|----------|----------|--------|----------|----------|
| **读取OpenClaw配置** | 读取 `~/.openclaw/config.json` | 必需 | 中 | 平台信任，只读访问 |
| **访问平台凭证** | 间接通过平台API调用 | 必需 | 低 | 不直接处理密钥 |
| **文件系统访问** | 读取用户图片文件 | 必需 | 低 | 路径验证，类型限制 |

##### 3. 配置读取的具体实现
```python
# 技能不直接读取config.json文件
# 而是通过OpenClaw命令获取配置
openclaw config get models.providers.volcengine
openclaw config get models.providers.deepseek

# 或通过环境变量（如果平台支持）
OPENCLAW_CONFIG_PATH = os.getenv("OPENCLAW_CONFIG_PATH", "~/.openclaw/config.json")
```

#### 平台配置安全要求

##### 1. OpenClaw平台安全假设
- ✅ **配置加密**：假设OpenClaw平台对敏感配置进行加密存储
- ✅ **访问控制**：假设平台实施适当的配置访问控制
- ✅ **安全传输**：假设配置读取通过安全通道进行
- ✅ **凭证保护**：假设API密钥在平台层面得到保护

##### 2. 用户必须验证的事项
**安装前必须确认**：
1. **OpenClaw版本**：使用支持配置加密的OpenClaw版本
2. **配置存储方式**：确认 `~/.openclaw/config.json` 的存储安全性
3. **平台安全设置**：确认OpenClaw平台的安全配置
4. **网络环境安全**：确认运行环境的安全性

##### 3. 风险接受声明
**接受的风险**：
1. **配置读取权限**：读取OpenClaw配置是实现模型路由所必需
2. **平台信任依赖**：需要信任OpenClaw平台的凭证管理安全
3. **文件系统访问**：需要访问用户指定的图片文件

**不接受的风险**：
1. **明文凭证处理**：技能不直接处理明文API密钥
2. **凭证持久化**：技能不存储任何凭证信息
3. **配置修改**：技能不修改OpenClaw配置

#### 安全使用指南

##### 1. 平台配置最佳实践
```bash
# 1. 验证OpenClaw配置安全性
openclaw config security status

# 2. 检查配置加密状态
openclaw config get security.encryption

# 3. 审查配置访问权限
ls -la ~/.openclaw/config.json

# 4. 定期轮换API密钥
# （在OpenClaw平台或提供商控制台操作）
```

##### 2. 最小权限配置建议
```bash
# 设置严格的配置文件权限
chmod 600 ~/.openclaw/config.json
chown $(whoami):$(whoami) ~/.openclaw/config.json

# 使用专用用户运行OpenClaw
sudo useradd -r -s /bin/false openclaw-user

# 配置访问控制列表（如支持）
setfacl -m u:openclaw-user:r-- ~/.openclaw/config.json
```

##### 3. 监控与审计
```bash
# 监控配置读取访问
auditctl -w ~/.openclaw/config.json -p r -k openclaw_config_read

# 检查技能日志中的配置访问
grep -i "config\|credential\|key" /var/log/openclaw/*.log

# 定期审计API使用情况
openclaw usage report --provider=volcengine
openclaw usage report --provider=deepseek
```

#### 替代方案说明

##### 如果担心配置读取风险
1. **使用环境变量**（如果平台支持）：
   ```bash
   export VOLCENGINE_API_KEY="your_key"
   export DEEPSEEK_API_KEY="your_key"
   ```

2. **使用平台API**（如果平台提供）：
   ```python
   # 通过平台API获取配置，而非直接读取文件
   config = openclaw.api.get_config("models.providers")
   ```

3. **使用专用配置服务**：
   ```bash
   # 使用外部配置管理服务
   vault read -field=api_key openclaw/volcengine
   ```

#### 应急响应计划

##### 发现凭证泄露迹象时
1. **立即停止技能使用**
2. **审查OpenClaw配置访问日志**
3. **检查技能生成的临时文件**
4. **轮换相关API密钥**
5. **报告安全事件给平台管理员**

##### 安全事件记录模板
```yaml
事件时间: 
涉及技能: tianji-fengshui v1.6.0
异常行为: 
配置访问详情: 
采取的响应措施: 
密钥轮换状态: 
后续改进措施:
```

**重要提醒**：使用本技能即表示您理解并接受上述凭证管理和配置读取风险说明，并确认您的OpenClaw平台配置具有适当的安全保护措施。

### 📋 用户责任与最佳实践

#### 必须执行的步骤
1. **审查生成文件**：执行前检查所有 `/tmp/tianji_*.sh` 和 `/tmp/tianji_*.json` 文件
2. **理解执行命令**：确认理解的 `openclaw sessions spawn` 等命令
3. **控制路径输入**：仅提供明确、受信任的图片路径
4. **沙盒环境测试**：首次在隔离环境中验证行为

#### 安全使用建议
- **最小权限原则**：仅在需要时启用技能
- **定期审查**：检查技能生成的文件和命令
- **环境隔离**：在生产环境使用前进行充分测试
- **及时清理**：使用后清理 `/tmp/tianji_*` 临时文件

### 📖 详细安全文档
完整的安全架构、ClawHub审查响应、代码审查指南和风险分析请查看：[SECURITY.md](SECURITY.md)

**重要提醒**：使用本技能即表示您理解并接受上述执行能力和风险说明。

## 配置要求

### OpenClaw全局配置示例
```json
{
  "models": {
    "providers": {
      "volcengine": {
        "baseUrl": "https://ark.cn-beijing.volces.com/api/v3",
        "apiKey": "您的豆包API密钥",
        "models": [{
          "id": "doubao-seed-2-0-pro-260215",
          "name": "豆包视觉模型"
        }]
      },
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "您的DeepSeek API密钥"
      }
    }
  }
}
```

### 安装验证
```bash
# 运行安装脚本
bash install.sh

# 或手动验证
python3 -c "import PIL; print('Pillow available')"
openclaw config get models.providers.volcengine
openclaw config get models.providers.deepseek
```

## 测试验证

### 运行测试套件
```bash
# 路径安全测试
python3 test_path_safety.py

# Subagent集成测试
bash test_subagent_integration.sh

# 知识库测试
python3 test_knowledge.py
```

### 生成文件审查
```bash
# 生成测试配置
python3 tianji_subagent_integration.py /tmp/test.jpg palm

# 审查生成的文件
cat /tmp/tianji_subagent_*.json
cat /tmp/tianji_analyze_*.sh
```

## 故障排除

### 常见问题

1. **模型调用失败**
   - 检查OpenClaw中volcengine/deepseek配置
   - 验证API密钥有效性
   - 确认网络连接正常

2. **图片读取失败**
   - 确认文件路径正确且可读
   - 检查文件格式（支持jpg/png/jpeg）
   - 验证文件大小（建议<10MB）

3. **Subagent创建失败**
   - 检查OpenClaw服务状态
   - 验证subagent配置权限
   - 查看OpenClaw日志获取详细信息

### 获取帮助
- 查看详细文档：`SUBAGENT_INTEGRATION_GUIDE.md`
- 运行诊断测试：`test_subagent_integration.sh`
- 审查错误日志：OpenClaw系统日志

## 更新日志

### v1.8.0 (2026-03-25)
- 响应持久性与权限审查反馈，明确执行边界风险
- 更新metadata添加 `persistence_and_privilege` 字段
- 详细分析工具权限风险和风险边界扩展
- 添加受控环境实施指南和权限最小化配置
- 提供环境分类标准、监控审计配置和用户责任矩阵

### v1.7.0 (2026-03-25)
- 响应凭证管理审查反馈，明确配置读取风险
- 更新metadata添加 `credential_management` 字段
- 详细说明凭证流转架构和平台安全要求
- 添加平台配置安全验证指南和最小权限配置
- 提供替代方案、监控审计框架和应急响应计划

### v1.6.0 (2026-03-25)
- 响应指令范围审查反馈，明确执行能力和风险
- 更新metadata添加 `execution_capabilities` 字段
- 详细说明文件操作、进程创建和工具权限要求
- 添加执行流程分析和风险控制说明
- 强化用户责任和审查要求说明

### v1.5.0 (2026-03-25)
- 修复版本号不一致问题（统一为1.5.0）
- 移除所有硬编码 `/home/test/.openclaw` 路径
- 使用动态路径检测，提高可移植性
- 精简SKILL.md文档，提升可读性
- 创建独立安全文档 (SECURITY.md)
- 分离详细安全信息与核心功能说明
- 优化文档结构，便于用户快速上手

### v1.3.0 (2026-03-25)
- 重写路径提取和安全验证逻辑
- 添加路径安全测试脚本
- 完善Subagent集成功能
- 增强安全文档和警告

### v1.2.0 (2026-03-25)
- 新增Subagent集成功能
- 支持掌纹、面相、风水图片分析
- 自动生成专业任务描述和配置
- 创建临时脚本和集成示例

### v1.1.0 (2026-03-25)
- 基础Subagent集成
- 掌纹、面相、风水分析模板
- 临时文件生成功能

### v1.0.0 (2026-03-17)
- 初始版本发布
- 玄机子人格设定
- 智能模型路由系统
- 基础风水命理分析

---

*天机不可泄露，玄机自在心中。传统智慧与现代AI的完美结合。*
