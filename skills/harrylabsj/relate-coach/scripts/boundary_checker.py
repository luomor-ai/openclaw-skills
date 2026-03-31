#!/usr/bin/env python3
"""Boundary Checker - 边界检查模块 for relationship-coach"""
# 超出范围的内容关键词
OUT_OF_SCOPE = [
    "挽回", "复合", "前任", "分手挽回", "怎么追", "表白",
    "相亲", "找对象", "约会", "撩", "出轨", "小三",
    "婚姻问题", "离婚", "夫妻", "性生活",
    "心理疾病", "抑郁", "焦虑症", "治疗",
    "代替我", "帮我聊", "代聊"
]

# 需要引导专业帮助的场景
PROFESSIONAL_REFER = [
    "家暴", "虐待", "精神控制", "pua", "跟踪骚扰",
    "严重心理问题", "心理创伤", "ptsd"
]

def check_boundary(text):
    """检查是否在服务范围内"""
    text = text.lower()
    
    # 检查是否需要专业转介
    for keyword in PROFESSIONAL_REFER:
        if keyword in text:
            return "professional_refer", keyword
    
    # 检查是否超出范围
    for keyword in OUT_OF_SCOPE:
        if keyword in text:
            return "out_of_scope", keyword
    
    return "in_scope", None

def get_out_of_scope_response(keyword):
    """获取超出范围的响应"""
    response = """抱歉，这类话题超出了我能够帮助的范围。
    
我能提供的是：
- 日常人际沟通技巧
- 非暴力沟通方法  
- 冲突处理建议
- 界限设定指导

但以下情况需要寻求专业机构帮助：
- 婚姻/情感咨询 → 婚姻家庭咨询师
- 心理问题 → 心理咨询师或心理医生
- 法律问题 → 律师

你有没有其他关于日常沟通的问题想聊聊？"""
    return {
        "type": "out_of_scope",
        "message": response,
        "keyword": keyword
    }

def get_professional_refer_response(keyword):
    """获取专业转介响应"""
    if keyword in ["家暴", "虐待"]:
        message = """你的情况听起来很严重，我很关心你。
        
如果是关于家庭暴力或虐待：
- **全国妇联妇女维权热线**：12338
- **反家庭暴力热线**：16803898
- **紧急情况请拨打**：110

这些机构可以提供专业帮助，保护你的安全。"""
    elif keyword in ["pua", "精神控制", "跟踪骚扰"]:
        message = """听起来你可能经历了不健康的关系模式。
        
建议你可以：
- 和信任的朋友或家人聊聊
- 寻求心理咨询师的帮助
- 必要时报警（如果是跟踪骚扰）

全国心理援助热线：400-161-9995"""
    else:
        message = """感谢你分享你的情况。
        
这个问题比较复杂，建议你寻求专业人士的帮助：
- 心理咨询师：处理心理创伤、情绪问题
- 律师：处理法律相关问题
- 相关支持机构：根据具体情况进行转介

你不需要独自面对。"""
    
    return {
        "type": "professional_refer",
        "message": message,
        "keyword": keyword
    }
