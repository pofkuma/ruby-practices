#!/usr/bin/env ruby
# frozen_string_literal: true

PADDING_SIZE = 7
MAX_COLUMUNS = 3

def calculate_line_count(size)
  line_count = size / MAX_COLUMUNS
  line_count += 1 unless (size % MAX_COLUMUNS).zero?
  line_count
end

def convert_layout(file_names, line_count, max_name_length)
  lines = Array.new(line_count) { '' }
  file_names.each_slice(line_count) do |names|
    names.each_with_index do |name, index|
      lines[index] += name.ljust(max_name_length + PADDING_SIZE)
    end
  end
  lines.map(&:rstrip).join("\n")
end

def format(contents)
  line_count = calculate_line_count(contents.size)
  max_name_length = contents.map(&:length).max
  convert_layout(contents, line_count, max_name_length)
end

def list_directory_contents(contents)
  format(contents.sort) unless contents.size.zero?
end

if $PROGRAM_NAME == __FILE__
  entries = Dir.glob('*')
  puts list_directory_contents(entries)
end
