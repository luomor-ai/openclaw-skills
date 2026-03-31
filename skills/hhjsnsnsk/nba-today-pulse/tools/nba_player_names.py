#!/usr/bin/env python3
"""Localized display helpers for NBA player names."""

from __future__ import annotations

PLAYER_DISPLAY_ZH = {
    "Anthony Davis": "安东尼·戴维斯",
    "Anthony Edwards": "安东尼·爱德华兹",
    "Ausar Thompson": "奥萨尔·汤普森",
    "Brandon Miller": "布兰登·米勒",
    "Cade Cunningham": "凯德·坎宁安",
    "De'Aaron Fox": "达龙·福克斯",
    "DeMar DeRozan": "德玛尔·德罗赞",
    "Devin Vassell": "德文·瓦塞尔",
    "Domantas Sabonis": "多曼塔斯·萨博尼斯",
    "Donte DiVincenzo": "唐特·迪文琴佐",
    "Duncan Robinson": "邓肯·罗宾逊",
    "Jalen Brunson": "杰伦·布伦森",
    "Jalen Duren": "杰伦·杜伦",
    "Jaylen Brown": "杰伦·布朗",
    "Jayson Tatum": "杰森·塔图姆",
    "Joel Embiid": "乔尔·恩比德",
    "Julius Randle": "朱利叶斯·兰德尔",
    "Karl-Anthony Towns": "卡尔-安东尼·唐斯",
    "LaMelo Ball": "拉梅洛·鲍尔",
    "LeBron James": "勒布朗·詹姆斯",
    "Malik Monk": "马利克·蒙克",
    "Mark Williams": "马克·威廉姆斯",
    "Miles Bridges": "迈尔斯·布里奇斯",
    "Mike Conley": "迈克·康利",
    "OG Anunoby": "OG·阿奴诺比",
    "Paul George": "保罗·乔治",
    "Rudy Gobert": "鲁迪·戈贝尔",
    "Stephen Curry": "斯蒂芬·库里",
    "Stephon Castle": "斯蒂芬·卡斯尔",
    "Tobias Harris": "托拜厄斯·哈里斯",
    "Tyrese Maxey": "泰瑞斯·马克西",
    "Victor Wembanyama": "维克托·文班亚马",
}


def display_player_name(name: str | None, lang: str = "en") -> str:
    if not name:
        return ""
    text = str(name).strip()
    if lang != "zh":
        return text
    return PLAYER_DISPLAY_ZH.get(text, text)


def localize_player_list(names: list[str] | None, lang: str = "en") -> list[str]:
    return [display_player_name(name, lang) for name in (names or [])]


def localize_player_line(text: str | None, lang: str = "en") -> str:
    if not text:
        return ""
    raw = str(text)
    if lang != "zh":
        return raw
    delimiter_positions = [raw.find(token) for token in (" - ", " | ", " (", ": ")]
    candidates = [position for position in delimiter_positions if position > 0]
    split_at = min(candidates) if candidates else len(raw)
    name = raw[:split_at].strip()
    localized = display_player_name(name, lang)
    if localized == name:
        return raw
    return f"{localized}{raw[split_at:]}"
