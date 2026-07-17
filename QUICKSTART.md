# CSDN 博客自动同步 — 快速指南

本站博客数据通过 Python 爬虫自动从 [CSDN 博客](https://blog.csdn.net/Lvyizhuo666) 同步。

---

## 同步方式

### 方式一：GitHub Actions（推荐）
代码推送到 `main` 分支后，GitHub Actions 自动部署网站（`pages.yml`）。如需定时拉取最新 CSDN 文章：

1. 在 GitHub 仓库 **Settings → Secrets and variables → Actions** 中添加 `PAT`（Personal Access Token）
2. 在 `auto_update_blog.sh` 或单独配置的 cron workflow 中使用该 token 提交更新

### 方式二：ECS Cron（生产环境）
在服务器上配置 crontab 定时执行：
```bash
# 每天凌晨 2 点同步
0 2 * * * /path/to/scripts/auto_update_blog.sh >> /var/log/sync_blog.log 2>&1
```

### 手动触发
```bash
python3 scripts/fetch_csdn_articles.py
```

---

## 关键文件

| 文件 | 作用 |
|---|---|
| `scripts/fetch_csdn_articles.py` | CSDN 文章爬虫 |
| `scripts/auto_update_blog.sh` | ECS cron 定时抓取+推送脚本 |
| `_data/csdn_posts.yml` | 文章数据（自动生成） |
| `_pages/year-archive.html` | 博客列表页面 |

---

## 效果

访问 [https://Lvyizhuo.github.io/year-archive/](https://Lvyizhuo.github.io/year-archive/) 查看已同步的博客文章。
