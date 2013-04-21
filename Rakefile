gem 'sass'
require 'haml'
require 'nokogiri'
require 'set'

def convert
  html = Haml::Engine.new(File.read('index.haml'), :format => :xhtml).render

  doc = Nokogiri::HTML(html)
  ids = Set.new
  doc.search('section').each do |section|
    next if section.at :section
    section['id'] ||= begin
      section.search('h1, h2, h3').map do |h|
        h.text.downcase.gsub(/[^a-z1-9]+/, ' ').strip.gsub(' ', '-')
      end.join('_')
    end
    puts "Duplicate id #{section['id']}" unless ids.add?(section['id'])
  end

  doc.search('section pre code').each do |code|
    code.inner_html = code.inner_html.gsub(/^\&gt\;\&gt\;/, '')
  end

  html = doc.to_xml

  File.open('index.html', 'w'){ |f| f.write(html) }
  $stderr.puts "Written"

  html
end

desc "Build index.html"
task :build do
  convert
end

desc "Building server"
task :server do
  require 'webrick'

  port = 8080
  puts "Starting server: http://localhost:#{port}"
  server = WEBrick::HTTPServer.new(
    :Port => port,
    :BindAddress => 'localhost',
    :Logger => WEBrick::Log.new('/dev/null'),
    :AccessLog => []
  )
  converter = Class.new(WEBrick::HTTPServlet::FileHandler) do
    def do_GET request, response
      if %w[/ index.html].include?(request.path)
        response.status = 200
        response['Content-Type'] = 'text/html'
        response.body = convert
      else
        super
      end
    end
  end
  server.mount '/', converter, Dir.pwd

  trap('INT'){ server.shutdown }
  server.start
end

task :default => :build
