#!/usr/bin/env ruby
# frozen_string_literal: true

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

def format(contents, reverse: false)
  return if contents.size.zero?

  line_count = (contents.size / MAX_COLUMUNS.to_f).ceil
  max_name_length = contents.map(&:length).max
  convert_layout(
    contents.sort.then { reverse ? _1.reverse : _1 },
    line_count,
    max_name_length
  )
end

def list_directory_contents(options)
  entries =
    if options[:a]
      Dir.glob('*', File::FNM_DOTMATCH)
    else
      Dir.glob('*')
    end
  format(entries, reverse: options[:r])
end

if $PROGRAM_NAME == __FILE__
  require 'optparse'
  opt = OptionParser.new

  options = {}
  opt.on('-a') { |boolean| options[:a] = boolean }
  opt.on('-r') { |boolean| options[:r] = boolean }

  opt.parse!(ARGV)
  puts list_directory_contents(options)
end
