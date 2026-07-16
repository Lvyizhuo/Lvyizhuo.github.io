# 🎉 CSDN博客自动同步 - 快速使用指南

## ✅ 已完成的配置

1. ✅ GitHub Actions自动化工作流
2. ✅ Python爬虫脚本
3. ✅ Blog Posts页面美化
4. ✅ 数据存储结构
5. ✅ 本地测试（已成功抓取27篇文章）

---

## 🚀 立即开始使用

### 步骤1：提交代码到GitHub

```bash
cd /home/lyz-ubuntu/Project/Lvyizhuo.github.io

# 添加所有新文件
git add .github/workflows/sync-csdn-blog.yml
git add scripts/fetch_csdn_articles.py
git add scripts/test_sync.sh
git add _data/csdn_posts.yml
git add _pages/year-archive.html
git add CSDN_SYNC_README.md
git add QUICKSTART.md

# 提交
git commit -m "✨ 添加CSDN博客自动同步功能

- 新增GitHub Actions定时任务（每天自动同步）
- 新增Python爬虫脚本抓取博客文章
- 美化Blog Posts页面展示
- 已测试：成功抓取27篇文章"

# 推送
git push origin main
```

### 步骤2：首次手动触发同步

1. 访问：https://github.com/Lvyizhuo/Lvyizhuo.github.io/actions
2. 点击左侧 **"Sync CSDN Blog Articles"**
3. 点击右侧 **"Run workflow"** 下拉按钮
4. 点击绿色的 **"Run workflow"** 按钮
5. 等待30秒-1分钟，查看运行状态

### 步骤3：查看效果

访问：**https://Lvyizhuo.github.io/year-archive/**

---

## 🎨 效果预览

Blog Posts页面将显示：

```
┌─────────────────────────────────────────────┐
│  🌟 我的CSDN博客文章                         │
│  自动同步于 CSDN-花间相见                    │
└─────────────────────────────────────────────┘

📊 共 27 篇文章 | ⏰ 最后更新: 2026-01-26 10:06:05

┌─────────────────────────────────────────────┐
│ 【JAVA开发】—— HTTP请求参数及类型            │
│ 📅 2026-01-25  👁️ 650                       │
│ 本文系统梳理了HTTP请求参数的类型...         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ 【JAVA开发】—— Apifox测试教程                │
│ 📅 2026-01-25  👁️ 732                       │
│ 本文介绍了使用Apifox进行接口测试...         │
└─────────────────────────────────────────────┘

... （更多文章）
```

---

## ⚙️ 自动化说明

### 定时同步
- **频率**：每天凌晨2点（UTC时间）自动运行
- **操作**：自动抓取最新文章 → 更新数据 → 提交到仓库
- **结果**：网站自动重新构建并发布

### 手动同步
随时可在GitHub Actions页面手动触发同步

---

## 📝 日常维护

### 正常情况
- ✅ 无需任何操作
- ✅ 每天自动同步
- ✅ 新文章自动出现

### 如需修改

**修改同步频率：**
编辑 `.github/workflows/sync-csdn-blog.yml` 第6行

**本地测试：**
```bash
/home/lyz-ubuntu/Project/Lvyizhuo.github.io/.venv/bin/python scripts/fetch_csdn_articles.py
```

---

## 🎯 关键文件说明

| 文件 | 作用 |
|------|------|
| `.github/workflows/sync-csdn-blog.yml` | 自动化任务配置 |
| `scripts/fetch_csdn_articles.py` | 爬虫脚本 |
| `_data/csdn_posts.yml` | 文章数据（自动生成） |
| `_pages/year-archive.html` | Blog Posts显示页面 |

---

## 💡 温馨提示

1. **首次使用**必须手动触发一次GitHub Actions
2. 提交代码后，GitHub Pages重新构建需要1-3分钟
3. 所有CSDN文章点击后在新标签页打开

---

## 🎊 完成！

现在您的个人网站已经实现了**CSDN博客自动同步**功能！

**下一步：**
1. ✅ 提交代码到GitHub
2. ✅ 手动触发首次同步
3. ✅ 访问网站查看效果
4. ✅ 享受自动化带来的便利！

---

**详细文档**：查看 [CSDN_SYNC_README.md](./CSDN_SYNC_README.md)
