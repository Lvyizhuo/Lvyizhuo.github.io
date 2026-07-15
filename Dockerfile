# ============================================================
# Dockerfile — Jekyll 本地开发环境 (GitHub Pages 兼容)
# ============================================================
FROM ruby:3.2

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Bundler 配置
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_CLEAN=true \
    BUNDLE_RETRY=5 \
    PATH=/usr/local/bundle/ruby/3.2.0/bin:/usr/local/bundle/bin:$PATH

# 设置工作目录
WORKDIR /usr/src/app

# 复制依赖文件，利用 Docker 缓存
COPY Gemfile Gemfile.lock ./

# 使用国内 Ruby 镜像源安装依赖（gem install 和 bundle install 都走镜像）
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ && \
    bundle config set --global mirror.https://rubygems.org https://gems.ruby-china.com && \
    bundle install && \
    gem sources --remove https://gems.ruby-china.com && \
    bundle config delete mirror.https://rubygems.org

# Jekyll 默认端口
EXPOSE 4000

# Jekyll 开发服务器
CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-w", "--force_polling", "--incremental"]
