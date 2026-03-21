---
name: endless-downstairs
description: 文字冒险游戏Endless Downstairs的交互接口，提供游戏状态管理和事件选择处理；当用户想玩无尽楼梯游戏、开始恐怖冒险或需要文字冒险游戏体验时使用
user-invokable: true
---

# Endless Downstairs

这是一款文字冒险游戏
你作为AI助手，需要翻译玩家输入的文字，调用Python处理逻辑，原封不动向玩家返回结果。

## 命令速查

| 玩家意图   | Python命令                           |
| ---------- | ------------------------------------ |
| 开始新游戏 | `python game.py new`                 |
| 做选择     | `python game.py choose <choice_num>` |
| 查看状态   | `python game.py status`              |
| 查看背包   | `python game.py inventory`           |
| 输入文字   | `python game.py input <文字>`        |

## 翻译玩家输入 → Python命令

根据玩家自然语言，执行对应命令：

- "我选第一个/1" → `python game.py choose 1`
- "状态" → `python game.py status`
- "物品/背包" → `python game.py inventory`
- "输入xxx" → `python game.py input xxx`

## 规则

- **直接输出游戏的内容，不要思考，不要修改，不要添加，不要总结**
- **决策权完全在玩家，玩家下达明确指令前，不要执行任何命令，包括继续选项**
