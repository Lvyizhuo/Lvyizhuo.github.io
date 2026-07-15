# 本地开发 URL 修正插件
# Jekyll serve 模式下会覆盖 site.url 为 "http://0.0.0.0:4000"，
# 导致浏览器无法加载 CSS/JS/图片资源。本插件将生成的静态文件中
# 的 0.0.0.0 替换为 localhost。
Jekyll::Hooks.register :site, :post_write do |site|
  next unless ENV['JEKYLL_ENV'] == 'development'

  Dir.glob(File.join(site.dest, '**/*.html')).each do |file|
    content = File.read(file)
    next unless content.include?('http://0.0.0.0:4000')

    File.write(file, content.gsub('http://0.0.0.0:4000', 'http://localhost:4000'))
    Jekyll.logger.info "DevUrl:", "已修正 #{file.sub(site.dest, '')}"
  end
end
