gem 'sass'
require 'haml'
require 'sass'
require 'kramdown'
require 'nokogiri'
require 'set'
require 'digest/sha1'

def convert
  haml = File.read('index.haml')
  ssha = Digest::SHA1.hexdigest(haml)[0, 6]
  haml.gsub!('[[SHASH]]', "[#{ssha}]")
  html = Haml::Engine.new(haml, :format => :xhtml).render

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

  port = 8888
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

desc "Create pack"
task :pack do
  rm_rf 'pack'
  mkdir 'pack'
  sh 'git archive -v HEAD *.{png,ico,html} reveal.js/{css/*.css,css/*/*.css,js/*.min.js,lib,plugin,LICENSE,*.html,README.md} | tar -xC pack'
end

task :default => :build
