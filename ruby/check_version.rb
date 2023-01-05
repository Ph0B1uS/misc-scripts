#!/usr/bin/ruby
# frozen_string_literal: true

require 'rss'
require 'open-uri'

# defaults
label = 'none'
threshold = 10
filename = 'module.data'

case ARGV.count
when 0
  puts "[\033[35mWARN\033[0m] No parameters, will default to reading module.data and threshold will be set to 10"
when 1
  puts 'No threshhold specified, defaulting to 10'
  filename = ARGV[0].to_s
when 2
  filename = ARGV[0].to_s
  threshold = ARGV[1].to_i
when 3
  filename = ARGV[0].to_s
  threshold = ARGV[1].to_i
  label = ARGV[2].to_s
end

unless File.file?(filename)
  puts "#{filename} does not exist! cannot open imaginary files, execution halted!"
  exit 1
end

def compare_versions(local_version, remote_version, threshold)
  # inject(:*) == array_sum ruby style
  version_difference = remote_version.split('.').inject(:+).to_i - local_version.split('.').inject(:+).to_i
  if version_difference.zero?
    version_colour = 32
  elsif version_difference < threshold
    version_colour = 31
  elsif version_difference >= threshold
    version_colour = 34
  end
  version_colour
end

puts "label: #{label}" unless label == 'none'
File.open(filename.to_s, 'r').each_line do |line|
  next unless line.start_with?('├──')

  line = line.split
  mod_local_version = line[2].delete('(v)')
  mod_name = line[1].split('-')
  mod_remote_version = ''
  mod_rss_feed = URI.parse("https://forge.puppet.com/modules/#{mod_name[0]}/#{mod_name[1]}/rss")
  mod_rss_feed.open do |rss|
    rss_feed = RSS::Parser.parse(rss)
    # we only need the first entry as that's the latest and greatest version number
    mod_remote_version = rss_feed.items[0].description
  end
  item_colour = compare_versions(mod_local_version, mod_remote_version, threshold)
  puts "#{line[1]} local: \033[#{item_colour}m #{mod_local_version} \033[0m remote: #{mod_remote_version}" unless item_colour == 32
end
