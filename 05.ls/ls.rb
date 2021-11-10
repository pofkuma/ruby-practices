#!/usr/bin/env ruby
# frozen_string_literal: true

CURRENT_DIRECTORY = '.'
PADDING_SIZE = 7
MAX_COLUMUNS = 3

def calculate_line_count(size)
  line_count = size / MAX_COLUMUNS
  line_count += 1 unless (size % MAX_COLUMUNS).zero?
  line_count
end

def convert_layout(line_count, max_name_length)
  lines = Array.new(line_count) { '' }
  each_slice(line_count) do |lists|
    lists.each_with_index do |list, index|
      lines[index] += list.ljust(max_name_length + PADDING_SIZE)
    end
  end
  lines.map(&:rstrip).join("\n") << "\n"
end

def format
  line_count = calculate_line_count(size)
  max_name_length = map(&:length).max
  convert_layout(line_count, max_name_length)
end

def filter_by_name
  reject { |name| name.start_with?("\.") }
end

def list_directory_contents(content_lists)
  filterd_content_lists = content_lists.filter_by_name
  return if filterd_content_lists.size.zero?

  filterd_content_lists.sort.format
end

public :format, :filter_by_name, :list_directory_contents

if $PROGRAM_NAME == __FILE__
  content_name_lists = Dir.entries(CURRENT_DIRECTORY)
  print list_directory_contents(content_name_lists)
end
