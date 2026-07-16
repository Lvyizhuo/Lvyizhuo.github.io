---
title: "【个人网站搭建】—— Academic Pages 个人学术网站完整配置指南"
date: 2026-01-26
permalink: /posts/2026/01/personal-website-building-guide/
excerpt: "本文详细介绍如何使用 Academic Pages 模板搭建个人学术网站，包括环境部署、基本信息配置、内容管理、GitHub Pages 发布以及自动化工作流等内容。"
tags:
  - Jekyll
  - GitHub Pages
  - 网站搭建
  - 个人网站
  - 学术网站
toc: true
toc_sticky: true
---

## 📖 项目简介

**Academic Pages** 是一个为学术研究人员设计的个人学术网站模板，基于 **Jekyll** 和 **GitHub Pages** 构建。本项目集成了现代 Web 技术，提供了一套完整的解决方案，用于展示个人简历、发表论文、研究项目、荣誉奖项、教育经历和实习经历。

### 核心特性
- ✨ **简洁优雅的设计** - 专为学术工作者设计
- 📱 **响应式布局** - 完美适配各种设备
- 🚀 **自动发布** - 基于 GitHub Pages 的免费托管
- 🤖 **自动化工作流** - GitHub Actions 自动同步 CSDN 博客
- 📊 **丰富的内容类型** - 论文、项目、荣誉奖项、教育经历、实习经历等
- 🎨 **高度可定制化** - 灵活的配置选项

---

## 🏗️ 部署方式

### 方法一：基于 GitHub Pages 自动部署（推荐）

这是最简单、最推荐的方式，完全免费托管，自动化程度最高。

#### 1. 创建仓库

```bash
# 方式1：使用 Template（推荐）
# 访问 https://github.com/academicpages/academicpages.github.io
# 点击 "Use this template" → "Create a new repository"
# 仓库名称必须为：[你的GitHub用户名].github.io
# 例如：Lvyizhuo.github.io

# 方式2：手动 Fork 并重命名
git clone https://github.com/[你的用户名]/[你的用户名].github.io.git
cd [你的用户名].github.io
```

#### 2. 配置 GitHub Pages 设置

1. 访问仓库的 **Settings** → **Pages**
2. **Source** 选择 **GitHub Actions**
3. 等待自动构建完成（首次可能需要几分钟）

#### 3. 验证部署

访问 `https://[你的GitHub用户名].github.io`，如果看到网站，说明部署成功！

### 方法二：本地 Jekyll 环境部署

适合需要在发布前本地预览的开发者。

#### 环境要求

| 环境 | 版本 | 备注 |
|-----|------|------|
| Ruby | 3.0+ | Jekyll 依赖 |
| Node.js | 14+ | 前端构建工具 |
| Bundler | 2.x | Ruby 包管理 |

#### 安装步骤

**在 Linux/WSL 上：**

```bash
# 1. 安装系统依赖
sudo apt update
sudo apt install ruby-dev ruby-bundler nodejs build-essential gcc make

# 2. 克隆仓库
git clone https://github.com/[你的用户名]/[你的用户名].github.io.git
cd [你的用户名].github.io

# 3. 安装 Ruby 依赖
bundle install

# 如果遇到权限问题，本地安装 gem：
bundle config set --local path 'vendor/bundle'
bundle install
```

**在 macOS 上：**

```bash
# 1. 使用 Homebrew 安装依赖
brew install ruby node
gem install bundler

# 2. 克隆仓库
git clone https://github.com/[你的用户名]/[你的用户名].github.io.git
cd [你的用户名].github.io

# 3. 安装依赖
bundle install
```

#### 启动本地服务器

```bash
# 启动 Jekyll 开发服务器（支持自动刷新）
jekyll serve -l -H localhost

# 或使用 Bundle 确保依赖版本一致
bundle exec jekyll serve -l -H localhost

# 访问本地网站
# http://localhost:4000
```

### 方法三：Docker 容器部署

最便捷的跨平台解决方案，无需安装任何本地依赖。

#### 安装 Docker

访问 [Docker 官网](https://www.docker.com/products/docker-desktop) 下载并安装 Docker Desktop。

#### 启动容器

```bash
# 进入项目目录
cd [你的用户名].github.io

# 设置文件夹权限
chmod -R 777 .

# 启动 Docker 容器
docker compose up

# 访问本地网站
# http://localhost:4000

# 停止容器
# 按 Ctrl+C 或运行
docker compose down
```

**Docker 文件结构说明：**

```dockerfile
# Dockerfile 配置
FROM ruby:3.2                          # 基础镜像：Ruby 3.2
RUN apt-get install nodejs ...         # 安装 Node.js
RUN bundle install                     # 安装 Ruby 依赖
CMD ["jekyll", "serve", ...]           # 启动 Jekyll 服务
```

### 方法四：VS Code DevContainer 部署

在 VS Code 中一键启动完整的开发环境（自动配置，零手动操作）。

#### 配置步骤

1. **安装扩展**：在 VS Code 中搜索并安装 "Dev Containers" 扩展
2. **打开项目**：用 VS Code 打开本仓库文件夹
3. **启动容器**：
   - 按 `F1` 打开命令面板
   - 输入 `Dev Container: Reopen in Container`
   - 选择配置并等待容器启动
4. **访问网站**：http://localhost:4000

---

## ⚙️ 基本信息配置

所有站点级别的配置都在 `_config.yml` 文件中进行，这是项目的核心配置文件。

### 1. 修改网站基本信息

打开 `_config.yml`，编辑以下字段：

```yaml
# 基本网站设置
locale: "en-US"                         # 语言设置
title: "你的名字"                        # 网站标题
title_separator: "-"                    # 标题分隔符
name: &name "你的完整名字"               # 作者名字
description: &description "你的网站描述"  # 网站描述
url: https://[你的GitHub用户名].github.io # 你的网站 URL
repository: "[用户名]/[用户名].github.io" # GitHub 仓库
```

### 2. 修改个人档案信息

在 `_config.yml` 中找到 `author` 部分：

```yaml
author:
  # 个人信息
  avatar: "profile.png"                 # 头像文件名（存放在 images/ 目录）
  name: "吕一卓 Yizhuo Lv"               # 显示名称
  pronouns: "he/him"                    # 代词（可选）
  bio: "硕士学生，研究兴趣：图神经网络、动态影响力最大化"  # 简介
  location: "Jinan, China"              # 所在地
  employer: "Qilu University of Technology"  # 就职机构
  email: "your.email@example.com"       # 邮箱
  
  # 学术网站链接
  googlescholar: "https://scholar.google.com/citations?user=YOUR_ID"
  orcid: "http://orcid.org/0000-0000-0000-0000"
  researchgate: "https://www.researchgate.net/profile/your-profile"
  
  # 代码托管平台
  github: "你的GitHub用户名"              # GitHub
  kaggle: "kaggle用户名"                 # Kaggle
  
  # 社交媒体
  twitter: "你的Twitter ID"
  linkedin: "你的LinkedIn ID"
  instagram: "你的Instagram用户名"
  youtube: "你的YouTube频道ID"
  weibo: "微博用户名"
  zhihu: "知乎用户名"
```

### 3. 添加头像

1. 在 `images/` 目录下放置你的头像图片（建议使用 `profile.png`）
2. 确保文件名与 `_config.yml` 中的 `avatar` 字段相匹配
3. 推荐尺寸：300x300 像素，格式：PNG 或 JPG

### 4. 修改网站主题

```yaml
site_theme: "default"  # 可选：default, dark, light 等
```

### 5. 配置导航菜单

打开 `_data/navigation.yml`：

```yaml
main:
  - title: "News"                       # 新闻
    url: /#news

  - title: "Publications"               # 论文
    url: /#publications

  - title: "Projects"                   # 项目
    url: /#projects

  - title: "Honors and Awards"          # 荣誉奖项
    url: /#honors

  - title: "Educations"                 # 教育经历
    url: /#educations

  - title: "Internships"                # 实习经历
    url: /#internships

  - title: "Blog Posts"                 # 博客
    url: /year-archive/
```

> 导航菜单中的锚点链接（如 `/#news`）指向 `about.md` 首页中对应章节的 ID。这些 ID 通过在章节标题后添加 `{: #section-id }` 来定义。

> 首页链接 "Yizhuo Lv" 由模板自动通过 `site.title` 渲染，无需在 `navigation.yml` 中添加。

---

## 📝 内容管理详解

本项目采用**单页+博客**的简洁结构：所有核心内容（个人介绍、论文、项目、荣誉奖项、教育经历、实习经历）均集中在首页 `_pages/about.md` 中管理，不再使用独立的页面和集合目录。博客文章仍通过 `_posts/` 目录管理。

### 1. 主页内容管理

#### 位置：`_pages/about.md`

这是网站唯一的首页文件，所有个人信息都按章节组织在该文件中。每个章节对应一个二级标题，标题后通过 `{: #section-id }` 标记锚点 ID，供导航栏跳转。

#### 章节与导航锚点对应表

| 章节 | 导航锚点 | Markdown 标题 |
|------|---------|--------------|
| About Me | （首页默认） | `# About Me` |
| News | `/#news` | `# 🔥 News` |
| Publications | `/#publications` | `# 📝 Publications` |
| Projects | `/#projects` | `# 🤝 Projects` |
| Honors and Awards | `/#honors` | `# 🏆 Awards & Honors` |
| Educations | `/#educations` | `# 📖 Educations` |
| Internships | `/#internships` | `# 💻 Internships` |

#### 编辑示例

```markdown
# 🔥 News
{: #news }

* _2026.07_: 🧬 最新消息 1
* _2026.03_: 💼 最新消息 2

# 📝 Publications
{: #publications }

* _Patent_: 发明名称, 作者, (专利号, 授权日期) [[Link]](url)
```

> 标题后的 `{: #section-id }` 是锚点标识符，必须与 `_data/navigation.yml` 中的 `/#section-id` 保持一致，导航栏才能正确跳转。

### 2. 博客文章

#### 位置：`_posts/` 目录

#### 创建新博客文章

文件名格式：`YYYY-MM-DD-文章标题.md`

```markdown
---
title: "文章标题"
date: 2026-01-26
permalink: /posts/2026/01/文章短链接/
excerpt: "文章摘要，会显示在文章列表中"
tags:
  - 标签1
  - 标签2
  - 标签3
toc: true              # 显示目录
toc_sticky: true       # 目录粘性（滚动时保持可见）
---

## 第一部分

文章内容...

## 第二部分

更多内容...
```

#### 博客文章高级选项

```yaml
---
title: "文章标题"
date: 2026-01-26
excerpt: "摘要"
tags: [标签]
categories: [分类]         # 可选：分类
toc: true                 # 显示目录
toc_sticky: true          # 粘性目录
author_profile: true      # 显示作者信息
read_time: true           # 显示阅读时间
comments: true            # 启用评论
share: true               # 显示分享按钮
related: true             # 显示相关文章
---
```
---

## 🔧 高级配置

### 1. 评论系统配置

在 `_config.yml` 中启用评论（支持多种提供商）：

```yaml
comments:
  provider: "disqus"        # false, disqus, discourse, staticman 等
  disqus:
    shortname: "你的disqus用户名"
```

### 2. 分析与统计

```yaml
analytics:
  provider: "google-analytics-4"
  google:
    tracking_id: "G-XXXXXXXXXX"
```

### 3. SEO 优化

```yaml
# 搜索引擎验证
google_site_verification: "谷歌验证码"
bing_site_verification: "必应验证码"

# 开放图谱配置（社交媒体分享优化）
og_image: "images/og-image.png"

# 社交媒体配置
twitter:
  username: "&twitter"
  
social:
  type: "Person"
  name: "你的名字"
  links:
    - https://twitter.com/你的账号
    - https://github.com/你的账号
    - https://linkedin.com/in/你的账号
```

### 4. 文件分享配置

在 `files/` 目录下放置 PDF、ZIP 等文件，它们将在网站上可访问：

```
https://你的网站.github.io/files/论文.pdf
https://你的网站.github.io/files/项目.zip
```

---

## 🤖 自动化工作流

本项目集成了 GitHub Actions 自动化工作流，实现博客文章的自动同步。

### CSDN 博客自动同步

#### 工作原理

```
┌─────────────────┐
│  CSDN 博客平台  │
└────────┬────────┘
         │ (自动爬取)
         ↓
┌─────────────────────┐
│  GitHub Actions 工作流 │
└────────┬────────────┘
         │ (每天凌晨2点触发)
         ↓
┌──────────────────────┐
│  更新 _data/csdn_posts.yml │
└────────┬─────────────┘
         │
         ↓
┌──────────────────┐
│  GitHub Pages 自动部署 │
└──────────────────┘
```

#### 配置步骤

1. **编辑工作流文件**：`.github/workflows/sync-csdn-blog.yml`

```yaml
name: Sync CSDN Blog Articles

on:
  # 每天凌晨2点自动运行（UTC 时间，北京时间上午10点）
  schedule:
    - cron: '0 2 * * *'
  
  # 允许手动触发
  workflow_dispatch:
  
  # 推送时触发（用于测试）
  push:
    branches:
      - main

jobs:
  sync-blog:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install requests beautifulsoup4 pyyaml lxml
    
    - name: Fetch CSDN articles
      run: python scripts/fetch_csdn_articles.py
    
    - name: Commit and push changes
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add _data/csdn_posts.yml
        git commit -m "chore: sync CSDN blog articles"
        git push
```

2. **配置爬虫脚本**：`scripts/fetch_csdn_articles.py`

在脚本中修改以下字段：

```python
# CSDN 博客配置
CSDN_USERNAME = "你的CSDN用户名"  # 改为你的 CSDN 用户名
CSDN_BLOG_URL = f"https://blog.csdn.net/{CSDN_USERNAME}"
OUTPUT_FILE = "_data/csdn_posts.yml"
```

3. **首次手动触发**

   - 访问：`https://github.com/[用户名]/[用户名].github.io/actions`
   - 点击左侧的 **"Sync CSDN Blog Articles"**
   - 点击右侧 **"Run workflow"**
   - 点击绿色的 **"Run workflow"** 按钮
   - 等待 1-2 分钟查看运行状态

#### 查看同步效果

访问：`https://你的网站.github.io/year-archive/`

---

## 📋 常见配置问题

### Q1：如何修改网站颜色主题？

在 `_sass/_themes.scss` 中修改颜色变量：

```scss
// 主色调
$primary-color: #3b82f6;         // 蓝色
$secondary-color: #8b5cf6;       // 紫色
$accent-color: #ec4899;          // 粉色
```

### Q2：如何添加自定义 CSS？

在 `assets/css/` 目录下创建新的 CSS 文件，或在 `_sass/` 中添加 SCSS 文件。

### Q3：如何修改网站字体？

在 `_sass/_themes.scss` 中修改：

```scss
$font-family-base: 'Segoe UI', 'Microsoft YaHei', sans-serif;
$font-family-serif: 'Georgia', serif;
```

### Q4：本地开发时如何清除缓存？

```bash
# 删除生成的网站文件
rm -rf _site/

# 重新生成
jekyll build

# 或直接服务
jekyll serve -l
```

### Q5：GitHub Pages 显示 404 错误？

1. 检查仓库名是否为 `[用户名].github.io`
2. 确认仓库为 **Public**
3. 到仓库 Settings → Pages，检查 Source 是否设置为 **GitHub Actions**
4. 检查是否有推送到 **main** 分支

---

## 🎓 工作流最佳实践

### 本地开发工作流

```bash
# 1. 克隆仓库
git clone https://github.com/[你的用户名]/[你的用户名].github.io.git
cd [你的用户名].github.io

# 2. 启动本地服务器
docker compose up
# 或
bundle exec jekyll serve -l -H localhost

# 3. 在浏览器中访问
# http://localhost:4000

# 4. 编辑文件并实时预览（自动刷新）

# 5. 完成后提交更改
git add .
git commit -m "✨ 新增文章或内容"
git push origin main

# 6. GitHub Pages 自动部署
# 访问 https://[你的用户名].github.io 查看更新
```

### Git 提交最佳实践

使用清晰的提交信息，便于维护项目历史：

```bash
# 新增内容
git commit -m "✨ 新增博客文章：XXX"
git commit -m "📝 新增论文发表：XXX"
git commit -m "🎨 更新简历信息"

# 修复问题
git commit -m "🐛 修复首页样式问题"
git commit -m "🔧 更新配置文件"

# 改进代码
git commit -m "♻️ 重构导航菜单结构"
git commit -m "📈 优化网站性能"
```

---

## 📚 相关资源

### 官方文档
- [Academic Pages 官网](https://academicpages.github.io/)
- [Jekyll 官方文档](https://jekyllrb.com/)
- [GitHub Pages 帮助中心](https://docs.github.com/en/pages)

### 学习资源
- [Markdown 语法指南](https://www.markdownguide.org/)
- [YAML 语法教程](https://yaml.org/spec/1.2/spec.html)
- [Liquid 模板语言](https://shopify.github.io/liquid/)

### 常用工具
- [Markdown 编辑器](https://markdown-it.github.io/)
- [在线 YAML 验证器](http://www.yamllint.com/)
- [Git 学习指南](https://git-scm.com/book/zh/v2)

---

## 🎉 总结

通过以上详细的配置和步骤，你可以快速搭建一个专业的个人学术网站。关键要点：

| 步骤 | 操作 | 时间 |
|------|------|------|
| 1. 创建仓库 | GitHub 模板创建 | 5 分钟 |
| 2. 基本配置 | 修改 `_config.yml` | 10 分钟 |
| 3. 添加内容 | 上传文章、论文 | 20 分钟 |
| 4. 部署发布 | Git Push 到 main | 2 分钟 |
| 5. 自动化 | 配置 GitHub Actions | 15 分钟 |

**总耗时：约 50 分钟即可拥有一个专业的个人网站！** 🚀

---

## 📞 获取帮助

- 遇到问题？查看官方 [GitHub Issues](https://github.com/academicpages/academicpages.github.io/issues)
- 贡献改进？欢迎提交 [Pull Request](https://github.com/academicpages/academicpages.github.io/pulls)
- 学术交流？访问项目首页联系作者

---

*最后更新于 2026年1月26日*
