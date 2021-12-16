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
  return if contents.size.zero?

  line_count = (contents.size / MAX_COLUMUNS.to_f).ceil
  max_name_length = contents.map(&:length).max

  convert_layout(contents, line_count, max_name_length)
end

def filetype_char(file_type)
  {
    file:             :-,
    directory:        :d,
    characterSpecial: :c,
    blockSpecial:     :b,
    fifo:             :p,
    link:             :l,
    socket:           :s,
  }[file_type.to_sym]
end

def convert_permission_to_rwx(numbers)
  numbers.to_i.to_s(2).rjust(3, '0').chars.map.with_index do |flag, index|
    flag.to_i.zero? ? '-' : %i[r w x][index]
  end.join
end

def permissions_string(number)
  format('%o', number).to_s.chars.map { |char| convert_permission_to_rwx(char) }.join
end

def query_file_properties(file, totalize)
  filestatus = File.stat(file)
  filetype = filetype_char(File.ftype(file))
  permisions_number = permissions_string(filestatus.world_readable?)

  totalize.call(filestatus.blocks)

  {
    filetype_and_permissions: "#{filetype}#{permisions_number} ",
    number_of_links:    filestatus.nlink,
    owner_name:         "#{Etc.getpwuid(filestatus.uid).name} ",
    group_name:         "#{Etc.getgrgid(filestatus.gid).name} ",
    number_of_filesize: filestatus.size,
    last_modified_date: File.ctime(file).strftime('%_2m %_2d %H:%M'),
    file:               File.basename(file),
  }
end

def justify_contents_value(contents)
  justfying_procs =
    {
      number_of_links:    ->(value, width) { value.rjust(width) },
      owner_name:         ->(value, width) { value.ljust(width) },
      group_name:         ->(value, width) { value.ljust(width) },
      number_of_filesize: ->(value, width) { value.rjust(width) },
    }

  justfying_procs.each do |name, proc|
    max_length = contents.map { _1.fetch(name).to_s.length }.max
    contents.map { |content| content[name] = proc.call(content.fetch(name).to_s, max_length) }
  end
  contents
end

def format_contents_long(files, base_path)
  total_blocks = 0
  contents = files.map do |file|
    query_file_properties("#{base_path}/#{file}", ->(blocks) { total_blocks += blocks })
  end

  ["total #{total_blocks}"] + justify_contents_value(contents).map { _1.values.join("\s") }
end

def list_directory_contents(path, all: false, reverse: false, long: false)
  return "ls: #{path}: No such file or directory" unless FileTest.exist?(path)

  flag = all ? File::FNM_DOTMATCH : nil
  entries = Dir.glob(*['*', flag].compact, base: path, sort: true)
               .then { reverse ? _1.reverse : _1 }

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
  if (result = list_directory_contents(path, **options))
    puts result
  end
end
