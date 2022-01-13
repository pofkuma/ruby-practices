#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 8
TOTAL_CELL_TEXT = 'total'

def main(text: '', file_names: [], line_only: false)
  files_counts =
    if file_names.empty?
      [['', count_text(text, line_only)]]
    else
      file_names.map do |pathname|
        text = File.read(pathname)
        [pathname, count_text(text, line_only)]
      end
    end
  files_counts.push [TOTAL_CELL_TEXT, total_counts(files_counts)] if files_counts.size > 1
  format_lines(files_counts)
end

def count_text(text, line_only)
  counts = {}
  counts[:line_count] = text.lines.size
  unless line_only
    counts[:word_count] = text.split("\s").size
    counts[:byte_count] = text.bytesize
  end
  counts
end

def total_counts(files_counts)
  total_counts = Hash.new { |counts, target| counts[target] = 0 }
  files_counts.each do |_filename, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts
end

def format_lines(files_counts)
  files_counts.map do |filename, counts|
    justifying = ->(count) { count.to_s.rjust(COLUMN_SIZE) }
    line = counts.values.map(&justifying).join + "\s#{filename}"
    line.rstrip
  end.join("\n")
end

if $PROGRAM_NAME == __FILE__
  options = ARGV.getopts('l')
  input = ARGV.empty? ? { text: $stdin.read } : { file_names: ARGV }
  puts main(**input, line_only: options['l'])
end
