# -*- coding: utf-8 -*-
"""
Enhanced Web Search Tool
- Multi-engine fallback (DuckDuckGo → Bing)
- Intelligent content extraction with noise reduction
- Comprehensive error handling and logging
- Cross-platform encoding compatibility
"""
import sys
import io
import os
import json
import urllib.parse
import logging
import argparse
from typing import List, Dict, Optional

# 第三方库导入
from playwright.sync_api import sync_playwright, PlaywrightError, TimeoutError as PlaywrightTimeoutError
from readability import Document
from bs4 import BeautifulSoup

# ===================== 配置常量（抽离便于维护） =====================
CONFIG = {
    "USER_AGENT": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "TIMEOUT": 25000,  # 页面加载超时（毫秒）
    "MAX_SEARCH_RESULTS": 15,  # 单次搜索返回最大结果数
    "MAX_FETCH_PAGES": 5,  # 默认抓取页面数
    "MIN_CONTENT_LENGTH": 100,  # 最小有效内容长度
    "MAX_TEXT_LENGTH": 1000,  # 单页面最大返回文本长度
    "PARAGRAPH_MIN_LENGTH": 50,  # 有效段落最小长度
}

# ===================== 日志配置（新增：便于调试） =====================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)


# ===================== 跨平台编码处理（优化） =====================
def setup_encoding():
    """设置跨平台UTF-8编码，避免乱码"""
    if sys.stdout.encoding != 'utf-8':
        try:
            sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
            sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')
        except Exception as e:
            logger.warning(f"Failed to set UTF-8 encoding: {e}")


# ===================== 搜索引擎核心逻辑（重构） =====================
def search_engine(query: str, context, engine: str = "duckduckgo") -> List[Dict[str, str]]:
    """
    统一搜索引擎接口，支持DuckDuckGo/Bing
    :param query: 搜索关键词
    :param context: Playwright浏览器上下文
    :param engine: 搜索引擎类型（duckduckgo/bing）
    :return: 搜索结果列表（title/url）
    """
    results = []
    page = None
    try:
        page = context.new_page()
        page.set_extra_http_headers({"User-Agent": CONFIG["USER_AGENT"]})

        # 构造搜索URL
        if engine == "duckduckgo":
            search_url = f"https://duckduckgo.com/?q={urllib.parse.quote(query)}"
            selector = 'article[data-testid="result"]'
            title_selector = 'a[data-testid="result-title-a"]'
        elif engine == "bing":
            search_url = f"https://www.bing.com/search?q={urllib.parse.quote(query)}"
            selector = 'li.b_algo'
            title_selector = 'h2 a'
        else:
            logger.error(f"Unsupported engine: {engine}")
            return results

        # 访问搜索页面
        page.goto(search_url, wait_until='networkidle', timeout=CONFIG["TIMEOUT"])

        # 提取结果
        for item in page.query_selector_all(selector)[:CONFIG["MAX_SEARCH_RESULTS"]]:
            a_tag = item.query_selector(title_selector)
            if not a_tag:
                continue
            href = a_tag.get_attribute('href')
            title = a_tag.inner_text().strip()
            if href and href.startswith(('http://', 'https://')) and title:
                results.append({"title": title, "url": href})

        logger.info(f"[{engine}] Found {len(results)} valid results for query: {query}")
        return results

    except PlaywrightTimeoutError:
        logger.error(f"[{engine}] Timeout when searching for: {query}")
    except PlaywrightError as e:
        logger.error(f"[{engine}] Playwright error: {str(e)}")
    except Exception as e:
        logger.error(f"[{engine}] Unexpected error: {str(e)}")
    finally:
        if page:
            page.close()
    return results


# ===================== 内容提取逻辑（增强） =====================
def extract_page_content(page, url: str) -> str:
    """
    智能提取页面核心内容，过滤冗余/广告/脚本内容
    :param page: Playwright页面对象
    :param url: 目标URL
    :return: 提取的纯文本内容
    """
    try:
        # 等待页面加载完成
        page.wait_for_load_state("domcontentloaded", timeout=CONFIG["TIMEOUT"])
        page.wait_for_timeout(1500)  # 缩短不必要的等待（原2000ms→1500ms）

        html = page.content()

        # 检测反爬/错误页面
        if any(key in html.lower() for key in ["error", "forbidden", "404", "限制", "blocked"]):
            logger.warning(f"Anti-crawl/error detected for URL: {url}")
            return ""

        # 第一步：用readability提取核心内容
        doc = Document(html)
        soup = BeautifulSoup(doc.summary(), 'html.parser')

        # 过滤有效段落（去重+长度校验）
        paragraphs = []
        seen_text = set()
        for p in soup.find_all('p'):
            text = p.get_text(strip=True)
            if text and len(text) >= CONFIG["PARAGRAPH_MIN_LENGTH"] and text not in seen_text:
                seen_text.add(text)
                paragraphs.append(text)

        # 第二步：readability提取内容不足时，兜底解析整个页面
        if len(' '.join(paragraphs)) < CONFIG["MIN_CONTENT_LENGTH"]:
            logger.debug(f"Readability extract failed, fallback to full page parse for: {url}")
            soup_full = BeautifulSoup(html, 'html.parser')
            # 移除冗余标签
            for tag in soup_full(["script", "style", "nav", "header", "footer", "noscript", "ad", "advertisement"]):
                tag.decompose()
            # 重新提取段落
            for p in soup_full.find_all('p'):
                text = p.get_text(strip=True)
                if text and len(text) >= CONFIG["PARAGRAPH_MIN_LENGTH"] and text not in seen_text:
                    seen_text.add(text)
                    paragraphs.append(text)

        # 拼接并截断内容
        content = ' '.join(paragraphs[:10])  # 限制段落数
        return content[:CONFIG["MAX_TEXT_LENGTH"]]

    except PlaywrightTimeoutError:
        logger.error(f"Timeout when extracting content from: {url}")
    except Exception as e:
        logger.error(f"Failed to extract content from {url}: {str(e)}")
    return ""


# ===================== 相关性排序（优化） =====================
def calculate_relevance_score(item: Dict[str, str], query: str) -> int:
    """
    优化相关性评分逻辑，提升时效性/权威性权重
    :param item: 搜索结果项（title/url）
    :param query: 搜索关键词
    :return: 相关性得分
    """
    title = item["title"].lower()
    query_words = set(query.lower().split())
    score = 0

    # 核心关键词匹配（原逻辑优化：集合匹配更高效）
    title_words = set(title.split())
    matched_words = query_words & title_words
    score += len(matched_words) * 3

    # 时效性权重（增强：补充更多时间相关关键词）
    time_keywords = ["最新", "新闻", "报道", "今日", "局势", "2024", "实时", "近期"]
    if any(kw in title for kw in time_keywords):
        score += 5

    # 权威来源权重（扩展权威域名）
    authority_keywords = ["官方", "百科", "新华社", "央视", "人民网", "新华网", "人民日报"]
    if any(kw in title for kw in authority_keywords) or any(
            domain in item["url"] for domain in ["cctv.com", "xinhuanet.com", "people.com.cn"]):
        score += 4

    return score


# ===================== 主搜索逻辑（重构） =====================
def web_search(query: str, max_pages: int = CONFIG["MAX_FETCH_PAGES"], use_json: bool = False) -> str:
    """
    主搜索函数：多引擎搜索→排序→内容提取→结构化输出
    :param query: 搜索关键词
    :param max_pages: 最大抓取页面数
    :param use_json: 是否输出JSON格式
    :return: 格式化搜索结果
    """
    # 校验参数
    max_pages = max(1, min(max_pages, 10))  # 限制页面数范围（1-10）
    if not query.strip():
        error_msg = "Search query cannot be empty"
        return json.dumps({"error": error_msg}, ensure_ascii=False) if use_json else error_msg

    # 初始化Playwright
    try:
        with sync_playwright() as playwright:
            # 启动浏览器（优化：禁用图片/视频加载提升速度）
            browser = playwright.chromium.launch(
                headless=True,
                channel='chrome',
                args=["--disable-images", "--disable-video-playback"]
            )
            context = browser.new_context(user_agent=CONFIG["USER_AGENT"])

            # 第一步：优先DuckDuckGo搜索
            search_results = search_engine(query, context, "duckduckgo")
            engine = "duckduckgo"

            # 第二步：结果不足时降级到Bing
            if len(search_results) < 3:
                logger.info("DuckDuckGo results insufficient, fallback to Bing")
                search_results = search_engine(query, context, "bing")
                engine = "bing"

            # 无结果处理
            if not search_results:
                error_msg = f"No results found for query: {query}"
                return json.dumps({"error": error_msg}, ensure_ascii=False) if use_json else error_msg

            # 第三步：按相关性排序
            search_results.sort(key=lambda x: calculate_relevance_score(x, query), reverse=True)
            top_results = search_results[:max_pages]

            # 第四步：抓取页面内容
            fetched_contents = []
            for idx, item in enumerate(top_results, 1):
                logger.info(f"Fetching content for [{idx}] {item['title']}")
                page = context.new_page()
                try:
                    page.goto(item["url"], wait_until="domcontentloaded", timeout=CONFIG["TIMEOUT"])
                    content = extract_page_content(page, item["url"])
                    if content and len(content) >= CONFIG["MIN_CONTENT_LENGTH"]:
                        fetched_contents.append({
                            "title": item["title"],
                            "url": item["url"],
                            "text": content
                        })
                except Exception as e:
                    logger.warning(f"Skip {item['url']} due to error: {str(e)}")
                finally:
                    page.close()

            # 关闭浏览器
            browser.close()

            # 第五步：结构化输出
            if use_json:
                return json.dumps({
                    "query": query,
                    "engine": engine,
                    "total_results": len(search_results),
                    "fetched_pages": len(fetched_contents),
                    "results": fetched_contents
                }, ensure_ascii=False, indent=2)

            # 文本输出
            if not fetched_contents:
                output = [f"Search: {query} [{engine}]",
                          f"Found {len(top_results)} results but content extraction failed:",
                          "\n".join([f"- {r['title']}\n  {r['url']}" for r in top_results[:5]])]
                return "\n".join(output)

            output = [f"Search: {query} [{engine}]",
                      f"Fetched {len(fetched_contents)} valid pages:\n"]
            for idx, item in enumerate(fetched_contents, 1):
                output.append(f"━━━ [{idx}] {item['title']} ━━━")
                output.append(item["text"])
                output.append(f"Source: {item['url']}\n")

            return "\n".join(output)

    except PlaywrightError as e:
        error_msg = f"Playwright initialization failed: {str(e)}"
        logger.error(error_msg)
        return json.dumps({"error": error_msg}, ensure_ascii=False) if use_json else error_msg
    except Exception as e:
        error_msg = f"Unexpected search error: {str(e)}"
        logger.error(error_msg)
        return json.dumps({"error": error_msg}, ensure_ascii=False) if use_json else error_msg


# ===================== 命令行入口（优化） =====================
def main():
    # 初始化编码
    setup_encoding()

    # 解析命令行参数
    parser = argparse.ArgumentParser(description="Enhanced Web Search Tool (DuckDuckGo/Bing fallback)")
    parser.add_argument("query", nargs="+", help="Search query (multiple words allowed)")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--pages", type=int, default=CONFIG["MAX_FETCH_PAGES"],
                        help=f"Number of pages to fetch (1-10, default: {CONFIG['MAX_FETCH_PAGES']})")
    args = parser.parse_args()

    # 执行搜索并输出结果
    query = " ".join(args.query)
    result = web_search(query, max_pages=args.pages, use_json=args.json)
    print(result)


if __name__ == "__main__":
    main()