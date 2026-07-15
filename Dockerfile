# ============================================================
# Dockerfile — Jekyll 本地开发环境 (GitHub Pages 兼容)
# ============================================================
FROM ruby:3.2-slim

# 安装构建依赖 (Jekyll 的 sass、kramdown 等需要编译 native extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Bundler 配置：将 gem 安装到独立路径，避免 volume 挂载覆盖
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_CLEAN=true

# 设置工作目录
WORKDIR /usr/src/app

# 先复制依赖文件，利用 Docker 缓存层
COPY Gemfile Gemfile.lock ./

# 安装 Ruby 依赖
RUN bundle install

# Jekyll 默认端口
EXPOSE 4000

# Jekyll 开发服务器（--force_polling 解决 Docker + macOS 文件监听问题）
CMD ["jekyll", "serve", "-H", "0.0.0.0", "-w", "--force_polling", "--incremental"]
