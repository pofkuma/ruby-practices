#!/usr/bin/env ruby
# frozen_string_literal: true

PADDING_SIZE = 7
MAX_COLUMUNS = 3

def calculate_line_count(size)
  line_count = size / MAX_COLUMUNS
  line_count += 1 unless (size % MAX_COLUMUNS).zero?
  line_count
end

def convert_layout(line_count, max_name_length)
  lines = Array.new(line_count) { '' }
  each_slice(line_count) do |contents|
    contents.each_with_index do |content, index|
      lines[index] += content.ljust(max_name_length + PADDING_SIZE)
    end
  end
  lines.map(&:rstrip).join("\n") << "\n"
end

def format
  line_count = calculate_line_count(size)
  max_name_length = map(&:length).max
  convert_layout(line_count, max_name_length)
end

def list_directory_contents(contents)
  contents.sort.format unless contents.size.zero?
end

public :format, :list_directory_contents

if $PROGRAM_NAME == __FILE__
  entries = Dir.glob('*')
  print list_directory_contents(entries)
end
