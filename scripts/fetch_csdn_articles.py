#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CSDN博客文章抓取脚本
使用 curl_cffi 模拟 Chrome 的 TLS/JA3 指纹绕过 CSDN WAF：
先访问主页建立 WAF 会话 cookie，再调用内部 API（主）或 HTML 解析（备），保存为 YAML。
"""

import json
import os
import re
import time
from datetime import datetime

import yaml
from bs4 import BeautifulSoup
from curl_cffi import requests

# CSDN博客配置
CSDN_USERNAME = "Lvyizhuo"
CSDN_BLOG_URL = f"https://blog.csdn.net/{CSDN_USERNAME}"
# CSDN 内部 API
CSDN_ARTICLE_LIST_API = "https://blog.csdn.net/community/home-api/v1/get-business-list"
OUTPUT_FILE = "_data/csdn_posts.yml"

# 模拟的浏览器指纹：锁定明确的 macOS 版 Chrome（裸 'chrome' 别名不稳定，最新指纹更易通过 WAF）
IMPERSONATE = "chrome152_macos"
# 温和重试参数：WAF 对密集重复请求会加强风控，重试间隔必须足够长，避免“请求风暴”自毁式触发拦截
WARMUP_RETRIES = 2       # 会话预热最多 2 次
WARMUP_BACKOFF = 10      # 预热重试基础退避（秒）
REQUEST_RETRIES = 3      # 每个页面请求最多 3 次
REQUEST_BACKOFF = 15     # 页面请求失败后的基础退避（秒，实际按次数递增 15/30）
PAGE_INTERVAL = 2        # 正常翻页间隔（秒）

# 请求头（HTML 页面用）
# 关键：不要显式设置 User-Agent / Accept-Encoding / Connection——curl_cffi 会按 impersonate
# 指纹自动注入与 TLS/JA3 完全一致的对应头。手动写一个与指纹不符的 UA（如 Win/Chrome120）
# 会被 WAF 的“UA 与 TLS 指纹一致性”检测识破并稳定返回 521。
HEADERS = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Upgrade-Insecure-Requests': '1',
    'Referer': f'https://blog.csdn.net/{CSDN_USERNAME}',
}

# API 专用请求头
# 同样不显式设置 User-Agent；且不要带 Origin——同源 XHR 本就不带 Origin，实测携带会被 WAF 拦截。
API_HEADERS = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Referer': f'https://blog.csdn.net/{CSDN_USERNAME}',
}


def warmup(session):
    """访问主页通过 WAF 并拿到 https_waf_cookie / bc_bot_session 等会话 cookie，带重试。

    返回是否拿到 200；即使预热失败也不阻断（实测预热 521 时正式请求仍可能成功）。
    """
    for i in range(WARMUP_RETRIES):
        try:
            resp = session.get(CSDN_BLOG_URL, timeout=20)
            if resp.status_code == 200:
                return True
            print(f"⚠️  WAF 预热返回 {resp.status_code}（第 {i + 1}/{WARMUP_RETRIES} 次）")
        except Exception as e:  # noqa: BLE001
            print(f"⚠️  WAF 预热异常（第 {i + 1}/{WARMUP_RETRIES} 次）: {str(e)}")
        if i < WARMUP_RETRIES - 1:
            time.sleep(WARMUP_BACKOFF * (i + 1))
    return False


def parse_post_time(post_time):
    """健壮解析发布时间，兼容 'YYYY-MM-DD HH:MM:SS' 字符串与毫秒/秒级时间戳。"""
    if not post_time:
        return ''
    raw = str(post_time).strip()
    if not raw.isdigit():
        # 字符串形式（如 '2026-11-09 22:32:00'），直接提取日期段
        # 该正则无捕获组，用 group(0) 取整个匹配（group(1) 会抛 no such group）
        match = re.search(r'\d{4}-\d{2}-\d{2}', raw)
        if match:
            return match.group(0)
    try:
        timestamp = int(raw)
        if len(raw) > 10:  # 毫秒级时间戳
            timestamp /= 1000
        return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d')
    except (ValueError, OSError):
        return raw[:10]


def new_session():
    """创建带浏览器指纹的会话，并完成 WAF 预热。"""
    session = requests.Session(impersonate=IMPERSONATE)
    warmup(session)
    return session


def fetch_article_list_from_html():
    """
    使用 HTML 解析方式抓取博客文章列表（备用方法）

    Returns:
        articles: 文章列表
    """
    articles = []

    print(f"🔍 使用 HTML 解析方式抓取CSDN博客: {CSDN_USERNAME}")

    session = new_session()
    session.headers.update(HEADERS)

    max_retries = 3
    page = 1

    while True:
        for retry in range(max_retries):
            try:
                print(f"📡 正在请求第 {page} 页 (尝试 {retry + 1}/{max_retries})...")

                url = f"{CSDN_BLOG_URL}/article/list/{page}"
                response = session.get(url, timeout=15)
                response.raise_for_status()

                # 使用 BeautifulSoup 解析 HTML
                soup = BeautifulSoup(response.text, 'lxml')

                # 查找文章列表
                article_items = soup.select('.article-item-box')

                if not article_items:
                    print(f"✅ 第 {page} 页无更多文章")
                    break

                print(f"✅ 第 {page} 页找到 {len(article_items)} 篇文章")

                for item in article_items:
                    try:
                        title_elem = item.select_one('h4 a')
                        if not title_elem:
                            continue

                        title = title_elem.get_text(strip=True)
                        link = title_elem.get('href', '')

                        if link and not link.startswith('http'):
                            link = 'https://blog.csdn.net' + link

                        date_elem = item.select_one('.date')
                        date_str = ''
                        if date_elem:
                            date_match = re.search(r'\d{4}-\d{2}-\d{2}', date_elem.get_text(strip=True))
                            if date_match:
                                date_str = date_match.group()

                        desc_elem = item.select_one('.content')
                        description = ''
                        if desc_elem:
                            description = desc_elem.get_text(strip=True)
                            if len(description) > 150:
                                description = description[:150] + '...'

                        views_elem = item.select_one('.read-num')
                        views = ''
                        if views_elem:
                            views_match = re.search(r'\d+', views_elem.get_text(strip=True))
                            if views_match:
                                views = views_match.group()

                        if title and link:
                            articles.append({
                                'title': title,
                                'link': link,
                                'date': date_str,
                                'excerpt': description,
                                'views': views,
                            })
                    except Exception as e:  # noqa: BLE001
                        print(f"⚠️  解析文章时出错: {str(e)}")
                        continue

                break

            except Exception as e:  # noqa: BLE001
                print(f"❌ 请求失败 (尝试 {retry + 1}/{max_retries}): {str(e)}")
                if retry < max_retries - 1:
                    time.sleep(REQUEST_BACKOFF * (retry + 1))  # 温和退避，复用会话不重新预热
                else:
                    print(f"⚠️  第 {page} 页获取失败，返回已获取的 {len(articles)} 篇文章")
                    return articles
        else:
            break

        if not article_items:
            break

        page += 1
        time.sleep(PAGE_INTERVAL)

    print(f"\n✨ 总共抓取到 {len(articles)} 篇文章")
    return articles


def fetch_article_list_from_api():
    """
    使用 CSDN API 抓取博客文章列表（主方法）

    Returns:
        articles: 文章列表
    """
    articles = []

    print(f"🔍 开始使用 API 抓取CSDN博客: {CSDN_USERNAME}")

    session = new_session()
    session.headers.update(API_HEADERS)

    max_retries = 3
    page = 1
    page_size = 40

    while True:
        for retry in range(max_retries):
            try:
                print(f"📡 正在请求第 {page} 页 (尝试 {retry + 1}/{max_retries})...")

                params = {
                    'page': page,
                    'size': page_size,
                    'businessType': 'blog',
                    'orderby': '',
                    'noMore': 'false',
                    'year': '',
                    'month': '',
                    'username': CSDN_USERNAME,
                }

                response = session.get(CSDN_ARTICLE_LIST_API, params=params, timeout=15)
                response.raise_for_status()

                data = response.json()

                if data.get('code') != 200:
                    print(f"⚠️  API 返回错误: {data.get('message', 'Unknown error')}")
                    if retry < max_retries - 1:
                        time.sleep(REQUEST_BACKOFF * (retry + 1))
                        continue
                    break

                article_list = data.get('data', {}).get('list', [])

                if not article_list:
                    print(f"✅ 第 {page} 页无更多文章，已获取全部")
                    break

                print(f"✅ 第 {page} 页找到 {len(article_list)} 篇文章")

                for item in article_list:
                    try:
                        title = item.get('title', '').strip()
                        article_id = item.get('articleId', '')
                        link = item.get('url') or (
                            f"https://blog.csdn.net/{CSDN_USERNAME}/article/details/{article_id}"
                        )
                        date_str = parse_post_time(item.get('postTime', ''))

                        description = item.get('description', '').strip()
                        if len(description) > 150:
                            description = description[:150] + '...'

                        view_count = item.get('viewCount', 0)
                        views = str(view_count) if view_count else ''

                        if title and link:
                            articles.append({
                                'title': title,
                                'link': link,
                                'date': date_str,
                                'excerpt': description,
                                'views': views,
                            })
                    except Exception as e:  # noqa: BLE001
                        print(f"⚠️  解析文章时出错: {str(e)}")
                        continue

                break

            except json.JSONDecodeError as e:
                print(f"❌ JSON 解析错误 (尝试 {retry + 1}/{max_retries}): {str(e)}")
                if retry < max_retries - 1:
                    time.sleep(REQUEST_BACKOFF * (retry + 1))
                else:
                    return articles
            except Exception as e:  # noqa: BLE001
                print(f"❌ 请求失败 (尝试 {retry + 1}/{max_retries}): {str(e)}")
                if retry < max_retries - 1:
                    time.sleep(REQUEST_BACKOFF * (retry + 1))  # 温和退避，复用会话不重新预热
                else:
                    print(f"⚠️  第 {page} 页获取失败，返回已获取的 {len(articles)} 篇文章")
                    return articles
        else:
            break

        if len(article_list) < page_size:
            print("✅ 已获取所有文章")
            break

        page += 1
        time.sleep(PAGE_INTERVAL)

    print(f"\n✨ 总共抓取到 {len(articles)} 篇文章")
    return articles


def save_to_yaml(articles):
    """将文章列表保存为 YAML 文件。"""
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

    data = {
        'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'total_count': len(articles),
        'articles': articles,
    }

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        yaml.dump(data, f, allow_unicode=True, sort_keys=False, default_flow_style=False)

    print(f"💾 文章列表已保存到: {OUTPUT_FILE}")


def load_existing_data():
    """加载现有的文章数据，文件不存在则返回 None。"""
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
                if data and isinstance(data, dict) and 'articles' in data:
                    print(f"📂 已加载现有数据: {data.get('total_count', 0)} 篇文章")
                    return data
        except Exception as e:  # noqa: BLE001
            print(f"⚠️  读取现有数据失败: {str(e)}")
    return None


def main():
    """主函数"""
    print("=" * 60)
    print("CSDN博客文章同步工具 (本地执行版，curl_cffi 指纹)")
    print("=" * 60)

    existing_data = load_existing_data()
    existing_count = existing_data.get('total_count', 0) if existing_data else 0

    try:
        print("\n方法1: 尝试使用 API...")
        articles = fetch_article_list_from_api()

        if not articles:
            print("\n⚠️  API 方法失败，切换到 HTML 解析方法...")
            print("方法2: 使用 HTML 解析...")
            articles = fetch_article_list_from_html()

        if articles:
            save_to_yaml(articles)
            print("\n🎉 同步完成！")
            print(f"📊 共获取 {len(articles)} 篇文章")
            return 0

        print("\n⚠️  未抓取到任何文章")
        if existing_data and existing_count > 0:
            print(f"🛡️  保留原有 {existing_count} 篇文章数据，不进行覆盖")
            print("\n💡 提示：请检查网络连接或 WAF 策略")
        else:
            print("⚠️  没有现有数据可保留")
        return 0

    except Exception as e:  # noqa: BLE001
        print(f"\n❌ 发生错误: {str(e)}")
        import traceback
        traceback.print_exc()

        if existing_data and existing_count > 0:
            print(f"\n🛡️  发生异常，保留原有 {existing_count} 篇文章数据")
        return 1


if __name__ == '__main__':
    exit(main())
