#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'fileutils'

PADDING_SIZE = 7
MAX_COLUMUNS = 3

def convert_layout(file_names, line_count, max_name_length)
  lines = Array.new(line_count) { '' }
  file_names.each_slice(line_count) do |names|
    names.each_with_index do |name, index|
      lines[index] += name.ljust(max_name_length + PADDING_SIZE)
    end
  end
  lines.map(&:rstrip).join("\n")
end

def format_contents(contents)
  line_count = (contents.size / MAX_COLUMUNS.to_f).ceil
  max_name_length = contents.map(&:length).max

  convert_layout(contents, line_count, max_name_length)
end

def filetype_char(file_type)
  case file_type
  when 'file'             then :-
  when 'directory'        then :d
  when 'characterSpecial' then :c
  when 'blockSpecial'     then :b
  when 'fifo'             then :p
  when 'link'             then :l
  when 'socket'           then :s
  else raise 'unkown file type'
  end.to_s
end

def convert_permission_to_rwx(numbers)
  numbers.to_i.to_s(2).rjust(3, '0').chars.map.with_index do |flag, index|
    flag.to_i.zero? ? '-' : %i[r w x][index]
  end.join
end

def permissions_string(number)
  format('%o', number).to_s.chars.map { |char| convert_permission_to_rwx(char) }.join
end

def query_file_statuses(file)
  filestatus = File.stat(file)
  filetype = filetype_char(File.ftype(file))
  permisions_number = permissions_string(filestatus.world_readable?)

  [[:filetype_and_permissions, "#{filetype}#{permisions_number} "],
   [:number_of_links,          filestatus.nlink],
   [:owner_name,               "#{Etc.getpwuid(filestatus.uid).name} "],
   [:group_name,               "#{Etc.getgrgid(filestatus.gid).name} "],
   [:number_of_filesize,       filestatus.size],
   [:last_modified_date,       File.ctime(file).strftime('%_2m %_2d %H:%M')],
   [:file,                     File.basename(file)]].to_h
end

def justify_contents_value(contents)
  justfying_procs =
    [[:number_of_links,    ->(value, width) { value.rjust(width) }],
     [:owner_name,         ->(value, width) { value.ljust(width) }],
     [:group_name,         ->(value, width) { value.ljust(width) }],
     [:number_of_filesize, ->(value, width) { value.rjust(width) }]].to_h

  justfying_procs.each do |name, proc|
    max_length = contents.map { _1.fetch(name).to_s.length }.max
    contents.map { |content| content[name] = proc.call(content.fetch(name).to_s, max_length) }
  end
  contents
end

def format_contents_long(files, base_path)
  pathnames = files.map { |file| "#{base_path}/#{file}" }
  total_blocks = pathnames.map { File.stat(_1).blocks }.sum
  contents = pathnames.map { query_file_statuses(_1) }

  ["total #{total_blocks}"] + justify_contents_value(contents).map { _1.values.join("\s") }
end

def list_directory_contents(path, all: false, reverse: false, long: false)
  return "ls: #{path}: No such file or directory" unless FileTest.exist?(path)

  flag = all ? File::FNM_DOTMATCH : nil
  entries = Dir.glob(*['*', flag].compact, base: path, sort: true)
               .then { reverse ? _1.reverse : _1 }
  return if entries.size.zero?

  long ? format_contents_long(entries, path) : format_contents(entries)
end

if $PROGRAM_NAME == __FILE__
  require 'optparse'
  opt = OptionParser.new

  options = {}
  opt.on('-a') { |boolean| options[:all] = boolean }
  opt.on('-r') { |boolean| options[:reverse] = boolean }
  opt.on('-l') { |boolean| options[:long] = boolean }

  opt.parse!(ARGV)

  path = ARGV[0] || '.'
  puts list_directory_contents(path, **options)
end
