#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'fileutils'

COLUMN_SIZE = 8
MAX_COLUMNS = 3

FILETYPE_CHAR =
  {
    file: :-,
    directory: :d,
    characterSpecial: :c,
    blockSpecial: :b,
    fifo: :p,
    link: :l,
    socket: :s
  }.freeze

def list_directory_contents(path, all: false, reverse: false, long: false)
  return "ls: #{path}: No such file or directory" unless FileTest.exist?(path)

  flags = all ? File::FNM_DOTMATCH : 0
  entries = Dir.glob('*', flags, base: path, sort: true)
               .then { reverse ? _1.reverse : _1 }

  long ? format_contents_long(entries, path) : format_contents(entries)
end

def format_contents_long(files, base_path)
  total_blocks = 0
  contents = files.map do |file|
    query_file_properties("#{base_path}/#{file}", ->(blocks) { total_blocks += blocks })
  end

  ["total #{total_blocks}"] + justify_properties_values(contents)
end

def query_file_properties(file, totalize)
  filestat = File.stat(file)
  totalize.call(filestat.blocks)
  {
    filetype: FILETYPE_CHAR[File.ftype(file).to_sym],
    permissions: permissions_string(filestat.world_readable?),
    number_of_links: filestat.nlink.to_s,
    owner_name: Etc.getpwuid(filestat.uid).name,
    group_name: Etc.getgrgid(filestat.gid).name,
    number_of_filesize: filestat.size.to_s,
    last_modified_date: File.ctime(file),
    file: File.basename(file)
  }
end

def permissions_string(number)
  format('%o', number).to_s.chars.map { |char| convert_permission_to_rwx(char) }.join
end

def convert_permission_to_rwx(number)
  number.to_i.to_s(2).rjust(3, '0').chars.map.with_index do |flag, index|
    flag.to_i.zero? ? '-' : %i[r w x][index]
  end.join
end

def justify_properties_values(file_properties_lists)
  keys = %i[number_of_links owner_name group_name number_of_filesize]
  max_lengths = keys.map { |key| [key, file_properties_lists.map { _1[key].to_s.length }.max] }.to_h
  file_properties_lists.map do |file_properties|
    [
      "#{file_properties[:filetype]}#{file_properties[:permissions]}\s",
      file_properties[:number_of_links].rjust(max_lengths[:number_of_links]),
      file_properties[:owner_name].ljust(max_lengths[:owner_name] + 1),
      file_properties[:group_name].ljust(max_lengths[:group_name] + 1),
      file_properties[:number_of_filesize].rjust(max_lengths[:number_of_filesize]),
      file_properties[:last_modified_date].strftime('%_2m %_2d %H:%M'),
      file_properties[:file]
    ].join("\s")
  end
end

def format_contents(contents)
  return if contents.size.zero?

  line_count = (contents.size / MAX_COLUMNS.to_f).ceil
  max_name_length = contents.map(&:length).max

  convert_layout(contents, line_count, max_name_length)
end

def convert_layout(file_names, line_count, max_name_length)
  width = calc_content_width(max_name_length)
  columns = file_names.map { _1.ljust(width) }.each_slice(line_count).to_a
  rows = columns[0].zip(*columns[1..])
  rows.map { _1.join.rstrip }.join("\n")
end

def calc_content_width(name_length)
  column_count = (name_length / COLUMN_SIZE) + 1
  COLUMN_SIZE * column_count
end

if $PROGRAM_NAME == __FILE__
  require 'optparse'
  opt = OptionParser.new

  options = {}
  opt.on('-a') { |v| options[:all] = v }
  opt.on('-r') { |v| options[:reverse] = v }
  opt.on('-l') { |v| options[:long] = v }

  opt.parse!(ARGV)

  path = ARGV[0] || '.'
  if (result = list_directory_contents(path, **options))
    puts result
  end
end
