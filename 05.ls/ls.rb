#!/usr/bin/env ruby
# frozen_string_literal: true

CURRENT_DIRECTORY = '.'
PADDING_SIZE = 7
MAX_COLUMUNS = 3

def format
  max_name_length = map(&:length).max
  rows = size / MAX_COLUMUNS
  rows += 1 unless (size % MAX_COLUMUNS).zero?

  lines = Array.new(rows) { '' }
  each_slice(rows) do |lists|
    lists.each_with_index do |list, index|
      lines[index] += list.ljust(max_name_length + PADDING_SIZE)
    end
  end

  lines.map(&:rstrip).join("\n") << "\n"
end

def filter_by_names
  reject { |name| name.start_with?("\.") }
end

def list_directory_contents(content_lists)
  filterd_content_lists = content_lists.filter_by_names
  filterd_content_lists.sort.format if filterd_content_lists.size.nonzero?
end

public :format, :filter_by_names, :list_directory_contents

content_name_lists = Dir.entries(CURRENT_DIRECTORY)
print list_directory_contents(content_name_lists)
