#!/usr/bin/env sh

# Make commit ids independent of date
export GIT_AUTHOR_DATE='2025-01-01T00:00:00'
export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM='auto'
. /opt/local/share/git-core/git-prompt.sh

function hps(){
  printf "\e[1;33m$*\e[0;1m\$\e[m"
}

function hps_git(){
  __git_ps1 "\e[1;33m$*\e[0;1m×\e[1;36m%s\e[0;1m\$\e[m"
}

function hcat(){
  ruby -e '
    ps, command = ARGV
    print "#{ps} #{command}\n#{`(#{command}) 2>&1`}".chomp
  ' "$(hps_git '~/hello-world')" "$*" |
  a2h |
  ruby -e '
    output = $stdin.read
    puts "  <pre><code>#{output.gsub("\n", "<br />")}</code></pre>" unless output.empty?
  '
}

function htee(){
  a2h | ruby -e '
    data = $stdin.read.chomp
    ARGV.each do |path|
      File.open(path, "w"){ |f| f.puts data }
    end
    puts "  <pre><code>#{data.gsub("\n", "<br />")}</code></pre>"
  ' $*
}

function hsection(){
  echo '%section'
  echo '  %h2 Hands-on'
  echo '  %h3 '$*
}

function fragment(){
  echo '  .fragment'
  ruby -pe 'print "  "'
}

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

hsection 'A bit of config'
(
  echo "$(hps '~') git config --global user.name 'Ivan Kuchin'"
  echo "$(hps '~') git config --global user.email ivan.kuchin@cern.ch"
  echo "$(hps '~') git config --global color.ui auto"
) | htee
(
  echo '  %p And ancient bash magic:'
  HPS1='\[\e[m\e[1;33m\]\w$(__git_ps1 "\[\e[0;1m\]×\[\e[1;36m\]%s")\[\e[0;1m\]\$\[\e[m\] '
  (
    echo "$(hps '~') GIT_PS1_SHOWDIRTYSTATE=true"
    echo "$(hps '~') GIT_PS1_SHOWSTASHSTATE=true"
    echo "$(hps '~') GIT_PS1_SHOWUNTRACKEDFILES=true"
    echo "$(hps '~') GIT_PS1_SHOWUPSTREAM=auto"
    echo "$(hps '~') PS1='$HPS1'"
  ) | htee
) | fragment

hsection 'Create new repository'
(
  echo "$(hps '~') mkdir hello-world"
  echo "$(hps '~') cd hello-world"
  echo "$(hps '~/hello-world') git init"
  echo 'Initialized empty Git repository in /Users/ikuchin/hello-world/.git/'
) | htee
(
  echo '  %p Status'
  hcat git status
) | fragment

hsection 'Create readme'
(
  echo '  %p Create file <code>README</code> with content:'
  printf 'Prints "Hello, World".' | htee README
) | fragment
(
  echo '  %p Status'
  hcat git status
) | fragment

hsection 'Stage first file'
(
  echo '  %p Stage <code>README</code>'
  hcat git add README
) | fragment
(
  echo '  %p Status'
  hcat git status
) | fragment

hsection 'Commit first file'
(
  echo '  %p Commit'
  hcat "git commit --message 'README'"
) | fragment
(
  echo '  %p Status'
  hcat git status
) | fragment

hsection 'Checkout new branch'
echo '  %p <code>git checkout -b abc</code> == <code>git branch abc && git checkout abc</code>'
hcat git checkout -b implementation
(
  echo '  %p Status'
  hcat git status
) | fragment

hsection 'Start implementing'
(
  echo '  %p Create file HelloWorld.java with content:'
  printf 'public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello, World")
  }
}' | htee HelloWorld.java
) | fragment
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
  printf 'System.out.println("Hello, World!");' | htee
  ruby -pi -e 'gsub(%q{World")}, %q{World!");})' HelloWorld.java
) | fragment
(
  echo '  %p It works!'
  hcat "javac HelloWorld.java && java HelloWorld"
) | fragment

hsection 'Show diff'
(
  hcat git diff
) | fragment

hsection 'Check status'
(
  hcat git status
) | fragment

hsection 'Ignore build results'
(
  echo '  %p Create file .gitignore with content:'
  printf '/*.class' | htee .gitignore
) | fragment
(
  echo '  %p Check status'
  hcat git status
) | fragment

hsection 'Commit changes separately'
(
  echo '  %p Amend last commit with fix'
  hcat git add HelloWorld.java
  (
    hcat "git commit --amend --message 'Implemented HelloWorld'"
  ) | fragment
) | fragment
(
  echo '  %p Commit ignore pattern'
  hcat git add .gitignore
  (
    hcat "git commit --message 'ignore /*.class'"
  ) | fragment
) | fragment

hsection 'Merge branch'
(
  echo '  %p Switch to master'
  hcat git co master
) | fragment
(
  echo '  %p Merge branch'
  hcat "git merge --no-ff implementation --message 'merge initial implementation'"
) | fragment

hsection 'Show history'
hcat "git log --graph --all --format=format:'%C(bold yellow)%h%C(reset) - %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)%n'"

hsection 'Resulting files'
hcat git ls-files
for file in $(git ls-files)
do
  hcat git show HEAD:$file
done
