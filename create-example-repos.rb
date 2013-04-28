#!/usr/bin/env ruby

require 'pathname'
require 'shellwords'
require 'set'

class Repo
  def initialize(name)
    @path = Pathname("example-repos/#{name}") # this is unsecure

    raise "`#{@path}` already exists" if @path.exist?
    @path.mkpath

    git 'init'
    @branch = :master
    @branches = Set.new [@branch]

    raise 'block required' unless block_given?
    yield self
  end

  def commit(message)
    (@path + "#{@branch}-#{message}").open('a'){ |f| f.puts message }
    git *%W[add -A .]
    git *%W[commit -m #{message}]
  end

  def branch(name)
    @branch = name.to_sym
    git *%W[branch #{@branch}] if @branches.add?(@branch)
    git *%W[checkout #{@branch}]
  end

  def merge(ref, options = {})
    if options[:no_ff]
      git *%W[merge --no-ff #{ref}]
    else
      git *%W[merge #{ref}]
    end
  end

  def rebase(ref)
    git *%W[rebase #{ref}]
  end

  def cherry_pick(ref)
    git *%W[cherry-pick #{ref}]
  end

private

  def git(*args)
    Dir.chdir(@path) do
      args = %w[git] + args
      puts args.shelljoin
      system *args
    end
  end
end


a = proc do |r|
  r.commit('a')
  r.commit('b')
  r.branch(:feature)
  r.commit('c')
  r.commit('d')
  r.branch(:master)
end

Repo.new('a') do |r|
  a[r]
end

Repo.new('a_merge') do |r|
  a[r]
  r.merge(:feature)
end

Repo.new('a_merge-no-ff') do |r|
  a[r]
  r.merge(:feature, :no_ff => true)
end


b = proc do |r|
  r.commit('a')
  r.commit('b')
  r.branch(:feature)
  r.commit('c')
  r.commit('d')
  r.branch(:master)
  sleep 1 # ensure time difference between commits
  r.commit('e')
end

Repo.new('b') do |r|
  b[r]
end

Repo.new('b_merge') do |r|
  b[r]
  r.merge(:feature)
end

Repo.new('b_rebase-n-merge') do |r|
  b[r]
  r.branch(:feature)
  r.rebase(:master)
  r.branch(:master)
  r.merge(:feature)
end


c = proc do |r|
  r.commit('a')
  r.commit('b')
  r.branch(:feature)
  r.commit('c')
  r.commit('d')
  r.branch(:master)
  r.cherry_pick(:feature)
end

Repo.new('c') do |r|
  c[r]
end

Repo.new('c_rebase') do |r|
  c[r]
  r.branch(:feature)
  r.rebase(:master)
end
