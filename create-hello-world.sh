#!/usr/bin/env sh

# Make commit ids independent of date
export GIT_AUTHOR_DATE='2025-01-01T00:00:00'
export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE

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

function fragment(){
  echo '  .fragment'
  while read line
  do
    echo "    $line"
  done
}

hsection 'Identify yourself'
echo '  :markdown'
echo "        $ git config --global user.name 'Ivan Kuchin'"
echo "        $ git config --global user.email ivan.kuchin@cern.ch"

hsection 'Create new repository'
echo '  :markdown'
echo '        $ mkdir hello-world'
echo '        $ cd hello-world'
echo '        $ git init'
echo '        Initialized empty Git repository in /Users/ikuchin/hello-world/.git/'
mkdir -p example-repos
cd example-repos
rm -rf hello-world
mkdir hello-world
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
(
  echo '  %p Create file README with content:'
  hfile 'Prints "Hello, World".' > README
) 2>&1 | fragment
(
  echo '  %p Stage'
  hcat git add README
) | fragment
(
  echo '  %p Commit'
  hcat "git commit --message 'README'"
) | fragment

hsection 'Checkout new branch'
hcat git checkout -b implementation

hsection 'Start implementing'
(
  echo '  %p Create file HelloWorld.java with content:'
  hfile 'public class HelloWorld {
    public static void main(String[] args) {
      System.out.println("Hello, World")
    }
  }' > HelloWorld.java
) 2>&1 | fragment
(
  echo '  %p Stage'
  hcat git add HelloWorld.java
) | fragment
(
  echo '  %p Commit'
  hcat "git commit --message 'Implemented HelloWorld'"
) | fragment

hsection 'Test and fix'
(
  echo '  %p Oops…'
  hcat javac HelloWorld.java
) | fragment
(
  echo '  %p Fix HelloWorld.java:'
  hfile 'System.out.println("Hello, World!");' > /dev/null
  echo 'public class HelloWorld {
    public static void main(String[] args) {
      System.out.println("Hello, World!");
    }
  }' > HelloWorld.java
) 2>&1 | fragment
(
  echo '  %p It works!'
  hcat "javac HelloWorld.java && java HelloWorld"
) | fragment

hsection 'Ignore build results'
(
  echo '  %p Check status'
  hcat git status
) | fragment
(
  echo '  %p Create file .gitignore with content:'
  hfile '/*.class' > .gitignore
) 2>&1 | fragment

hsection 'Commit changes'
(
  echo '  %p Amend last commit with fix'
  hcat git add HelloWorld.java
  hcat "git commit --amend --message 'Implemented HelloWorld'"
) | fragment
(
  echo '  %p Commit ignore pattern'
  hcat git add .gitignore
  hcat "git commit --message 'ignore /*.class'"
) | fragment

hsection 'Merge and delete branch'
(
  echo '  %p Switch to master'
  hcat git co master
) | fragment
(
  echo '  %p Merge branch'
  hcat "git merge --no-ff implementation --message 'merge initial implementation'"
) | fragment
(
  echo '  %p Delete branch'
  hcat git branch -d implementation
) | fragment

hsection 'Show history'
hcat "git log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)%n'"
