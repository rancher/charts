#! /usr/bin/env ruby

require "json"
require "pathname"
require "yaml"
require 'pp'

script_dir = Pathname(__dir__)
repo_root = script_dir.parent
config_file_path = repo_root + "config/regsync.yaml"

pp script_dir
pp repo_root
pp config_file_path

unless config_file_path.exist?
  abort "Error: Config file not found at calculated path: #{config_file_path}"
end

regsync = YAML.load(config_file_path.read)

regsync["sync"].sum do |sync|
  allow_tags = sync.dig("tags", "allow") || []
  allow_tags.count
end.then do |sum|
  puts "total tags to consider: #{sum}"
end

regsync["sync"].each do |sync|
  regsync.merge("sync" => [sync]).then do |regsync|
    (repo_root + "split-regsync" + sync["source"]).then do |dir|
      dir.mkpath
      (dir + "split-regsync.yaml").write(YAML.dump(regsync))
    end
  end
end