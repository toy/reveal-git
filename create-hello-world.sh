#!/usr/bin/env sh

function hcat(){
  ruby -e '
  require "cgi"
    command = ARGV[0]
    output = "<span style=\"color:#0A0\">$</span> #{CGI.escapeHTML(command)}\n#{`(#{command}) 2>&1 | a2h`}".chomp
    puts "  <pre><code>#{output.gsub("\n", "<br />")}</code></pre>" unless output.empty?
  ' "$*"
}

function hfile(){
  ruby -e '
    require "cgi"
    data = ARGV[0]
    puts data
    $stderr.puts "  <pre><code>#{CGI.escapeHTML(data).gsub("\n", "<br />")}</code></pre>"
  ' "$*"
}

function hsection(){
  echo '%section'
  echo '  %h2 Hands-on'
  echo '  %h3 '$*
}

hsection 'Identify yourself'
echo '  :markdown'
echo "      $ git config --global user.name 'Ivan Kuchin'"
echo "      $ git config --global user.email ivan.kuchin@cern.ch"

hsection 'Create new repository'
echo '  :markdown'
echo '      $ mkdir hello-world'
echo '      $ cd hello-world'
echo '      $ git init'
echo '      Initialized empty Git repository in /Users/ikuchin/hello-world/.git/'
mkdir -p example-repos
cd example-repos
mkdir hello-world || exit 1
cd hello-world
git init > /dev/null

# identify only for this repo
git config user.name 'Ivan Kuchin'
git config user.email ivan.kuchin@cern.ch
# force it to use ansi colors
git config color.ui always
git config color.branch always
git config color.diff always
git config color.interactive always
git config color.pager true
git config color.showbranch always
git config color.status always
git config color.ui always

hsection 'Commit first file'
echo '  %p Create file README with content:'
hfile 'Prints "Hello, World".' > README
echo '  %p Stage'
hcat git add README
echo '  %p Commit'
hcat "git commit --message 'README'"

hsection 'Checkout new branch'
hcat git checkout -b implementation
hsection 'Start implementing'
echo '  %p Create file HelloWorld.java with content:'
hfile 'public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello, World")
  }
}' > HelloWorld.java
echo '  %p Stage'
hcat git add HelloWorld.java
echo '  %p Commit'
hcat "git commit --message 'Implemented HelloWorld'"

hsection 'Test and fix'
echo '  %p Ops'
hcat javac HelloWorld.java
echo '  %p Fix HelloWorld.java:'
hfile 'System.out.println("Hello, World!");' > /dev/null
echo 'public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello, World!");
  }
}' > HelloWorld.java
echo '  %p It works!'
hcat "javac HelloWorld.java && java HelloWorld"

hsection 'Ignore build results'
hcat git status
echo '  %p Create file .gitignore with content:'
hfile '/*.class' > .gitignore

hsection 'Commit changes'
echo '  %p Amend last commit with fix'
hcat git add HelloWorld.java
hcat "git commit --amend --message 'Implemented HelloWorld'"
echo '  %p Commit ignore pattern'
hcat git add .gitignore
hcat "git commit --message 'ignore /*.class'"

hsection 'Merge and delete branch'
hcat git co master
hcat "git merge --no-ff implementation --message 'merge initial implementation'"
hcat git branch -d implementation

hsection 'Show history'
hcat "git log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)%n'"
