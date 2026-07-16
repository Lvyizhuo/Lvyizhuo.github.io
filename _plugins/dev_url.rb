# 本地开发 URL 修正插件
# Jekyll serve 模式下会把生成的链接写成 http://0.0.0.0:4000，浏览器无法连接该地址，
# 导致 CSS/JS/图片资源加载失败、页面呈现裸 HTML。本插件在渲染阶段把 0.0.0.0 替换为 localhost。

if ENV['JEKYLL_ENV'] == 'development'
  OLD_URL = 'http://0.0.0.0:4000'.freeze
  NEW_URL = 'http://localhost:4000'.freeze

  # 在页面/文档渲染完成后、写入磁盘前就地替换（使用 gsub! 避免无替换时的字符串分配）
  Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
    next unless doc.output.respond_to?(:gsub!)

    doc.output.gsub!(OLD_URL, NEW_URL)
  end
end
