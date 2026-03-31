#!/usr/bin/env python3
"""Relationship Coach Handler - 人际关系教练核心模块"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from boundary_checker import check_boundary, get_out_of_scope_response, get_professional_refer_response

def detect_intent(text):
    """检测用户意图"""
    text = text.lower()
    if any(k in text for k in ["沟通", "表达", "说话", "说"]):
        return "communication"
    elif any(k in text for k in ["倾听", "听", "听不懂"]):
        return "listening"
    elif any(k in text for k in ["冲突", "吵架", "矛盾", "分歧", "争执"]):
        return "conflict"
    elif any(k in text for k in ["拒绝", "不敢", "不好意思", "开不了口"]):
        return "boundary"
    elif any(k in text for k in ["同事", "领导", "职场", "工作"]):
        return "workplace"
    elif any(k in text for k in ["朋友", "社交"]):
        return "social"
    elif any(k in text for k in ["家人", "父母", "孩子"]):
        return "family"
    elif any(k in text for k in ["亲密", "情侣"]):
        return "intimate"
    elif any(k in text for k in ["nvc", "非暴力"]):
        return "nvc"
    else:
        return "general"

# ===== 知识库 =====

NVC_GUIDE = {
    "name": "非暴力沟通（NVC）四步法",
    "description": "马歇尔·卢森堡提出的沟通方法，帮助在冲突中保持尊重和理解。",
    "steps": [
        "1. 观察（Observation）：不带评判地描述事实",
        "   ❌ 不要：'你总是迟到！'",
        "   ✅ 要说：'这周你有三天超过约定时间30分钟'",
        "",
        "2. 感受（Feeling）：说出你的感受（不是想法）",
        "   ❌ 不要：'我觉得你不重视我'（这是想法）",
        "   ✅ 要说：'等你的时候，我感到焦虑和担心'",
        "",
        "3. 需要（Need）：表达你的需求",
        "   说明：这个行为影响到你什么？",
        "   ✅ '我需要确定性，这样我才能规划时间'",
        "",
        "4. 请求（Request）：提出具体、可行的请求",
        "   ❌ 不要：'你能不能靠谱点？'（太模糊）",
        "   ✅ 要说：'下次如果会迟到，能不能提前15分钟发消息告诉我？'"
    ],
    "example": {
        "situation": "朋友答应还钱但一直拖着",
        "nvc": "'上次你借我的5,000块，说好上个月还。等待的这一个月，我有点担心你是否遇到困难。我很重视我们之间的信任，你能不能告诉我大概什么时候能还？'" 
    }
}

ACTIVE_LISTENING = {
    "name": "主动倾听技巧",
    "description": "帮助对方感到被理解和尊重的倾听方式。",
    "techniques": [
        "【回声回应】简单重复对方关键话语：'所以你觉得...'"
        "【情感标注】说出你听到的情绪：'听起来你很沮丧'、'这事让你很生气'"
        "【开放式提问】'能多说说吗？''后来怎么样了？''你当时怎么想的？'"
        "【肢体语言】眼神接触、点头、身体前倾（面对面时）"
        "【不打断】让对方说完再回应，即使你有话想说"
        "【复述确认】'我听到的是...，对吗？'"
    ],
    "tip": "倾听不是为了给建议，而是为了理解对方"
}

CONFLICT_FRAMEWORK = {
    "name": "冲突处理框架",
    "steps": [
        "1. **暂停**：感觉要吵起来时，先停下来，深呼吸",
        "2. **定位**：这是'内容冲突'还是'关系冲突'？",
        "   - 内容冲突：意见不同，可以协商",
        "   - 关系冲突：感觉被攻击或不尊重，需要先修复关系",
        "3. **表达**：用'我'开头，说事实和感受，不指责",
        "4. **倾听**：对方说完之前不反驳，真正听懂对方",
        "5. **寻找共同点**：'我们都希望...''我们都同意...'"
        "6. **协商**：找双方都能接受的方案"
    ],
    "tips": [
        "避免：'你总是''你从来''你就是这种人'",
        "多用：'当...时，我感到...''我需要...'"
    ]
}

BOUNDARY_GUIDE = {
    "name": "界限设定指南",
    "why": "健康的界限是关系的保护伞，不是拒绝，而是让关系更健康。",
    "steps": [
        "1. **识别自己的界限**：哪些事让你不舒服？",
        "2. **明确界限内容**：具体是什么？",
        "3. **清晰表达**：用温和但坚定的方式说出",
        "4. **一致执行**：第一次就要坚持，不要时松时紧"
    ],
    "templates": [
        "当...时，我会...（行为描述）",
        "我需要...（需求），所以请...",
        "我暂时不能...因为...",
        "谢谢你的理解，我想...（提议）"
    ],
    "examples": [
        {
            "场景": "同事频繁在下班后发消息",
            "模板": "我看到了你的消息。我通常下班后不看工作消息，明天上班我会处理。",
            "态度": "温和但坚定"
        },
        {
            "场景": "朋友借钱",
            "模板": "我现在经济也比较紧，恐怕不能借。你可以问问...或者其他办法。",
            "态度": "坦诚+提供其他建议"
        }
    ]
}

WORKPLACE_COMM = {
    "name": "职场沟通技巧",
    "scenarios": [
        {
            "场景": "不同意领导的决定",
            "建议": "可以私下沟通：'我想了解一下这个决定背后的考虑，我也有些想法想分享...'避免公开质疑。"
        },
        {
            "场景": "拒绝额外工作",
            "建议": "先确认优先级：'我现在手头有A和B任务，您看哪个更优先？'让对方了解你的工作量。"
        }
    ]
}

# ===== 主处理逻辑 =====

def build_response(user_text, intent):
    # 先检查边界
    boundary_status, keyword = check_boundary(user_text)
    if boundary_status == "out_of_scope":
        return get_out_of_scope_response(keyword)
    if boundary_status == "professional_refer":
        return get_professional_refer_response(keyword)
    
    # 根据意图提供内容
    if intent == "nvc" or intent == "communication":
        return {"type": "nvc", "content": NVC_GUIDE}
    elif intent == "listening":
        return {"type": "listening", "content": ACTIVE_LISTENING}
    elif intent == "conflict":
        return {"type": "conflict", "content": CONFLICT_FRAMEWORK}
    elif intent == "boundary":
        return {"type": "boundary", "content": BOUNDARY_GUIDE}
    elif intent == "workplace":
        return {"type": "workplace", "content": WORKPLACE_COMM}
    elif intent == "social":
        return {"type": "social", "content": "社交技巧待添加"}
    elif intent == "family":
        return {"type": "family", "content": "家庭沟通技巧待添加"}
    else:
        return {"type": "general", "content": "请告诉我你想聊什么？沟通、倾听、冲突处理、拒绝他人，还是职场人际？"}

def main():
    user_input = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else ""
    if not user_input:
        print("请输入你想咨询的人际关系话题...")
        return
    
    intent = detect_intent(user_input)
    result = build_response(user_input, intent)
    
    print(f"=== Relationship Coach ===\n")
    if "content" in result and isinstance(result["content"], dict):
        for k, v in result["content"].items():
            print(f"**{k}**: {v}")
    else:
        print(result.get("content", ""))

if __name__ == "__main__":
    main()
