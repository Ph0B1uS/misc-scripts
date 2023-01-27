#!/usr/bin/ruby
# frozen_string_literal: true

require 'base64'
require 'yaml'
require 'openssl'
require 'date'

# defaults
limit = 15
filename = "#{Dir.home}/.kube/config"

case ARGV.count
when 0
  puts "[\033[35mWARN\033[0m] No parameters, will default to file #{filename} and limit will be set to #{limit}"
when 1
  puts "No limit specified, defaulting to #{limit}"
  filename = ARGV[0].to_s
when 2
  filename = ARGV[0].to_s
  limit = ARGV[1].to_i
end

unless File.file?(filename.to_s)
  puts "#{filename} does not exist! cannot open imaginary files, execution halted!"
  exit 1
end

cert_data = YAML.safe_load(File.read(filename))
certs = cert_data['clusters']
certs.each do |item|
  current_cert = Base64.decode64(item['cluster']['certificate-authority-data']).to_s
  current_cluster_name = item['name']
  puts "cluster name: #{current_cluster_name}"
  current_cert_obj = OpenSSL::X509::Certificate.new current_cert
  # apparently DateTime.parse doesn't like \sUTC so let's remove it, shall we?
  current_cert_enddate = current_cert_obj.not_after.to_s.chomp(' UTC')
  days_left = (DateTime.parse(current_cert_enddate) - DateTime.now).to_i
  if days_left <= limit
    puts "cert expires: #{current_cert_enddate} (\033[31m#{days_left} days left!\033[0m)\n"
  else
    puts "cert expires: #{current_cert_enddate} (\033[32m#{days_left} days left\033[0m)\n"
  end
end
