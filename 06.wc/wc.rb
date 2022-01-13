#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 8
JUSTIFYING_COLUMN_PROC = ->(count) { count.to_s.rjust(COLUMN_SIZE) }
TOTAL_CELL_TEXT = 'total'

def main(line_only: false)
  if ARGV.empty?
    text = $stdin.read
    counts = count_text(text, line_only)
    counts.values.map(&JUSTIFYING_COLUMN_PROC).join
  else
    files_counts =
      ARGV.map do |pathname|
        File.open(pathname) do |file|
          text = file.read
          [pathname, count_text(text, line_only)]
        end
      end
    files_counts.push [TOTAL_CELL_TEXT, total_counts(files_counts)] if files_counts.size > 1
    format_lines(files_counts)
  end
end

def count_text(text, line_only)
  counts = {}
  counts[:line_count] = text.split("\n")&.size || 0
  unless line_only
    counts[:word_count] = text.split("\s")&.size || 0
    counts[:byte_count] = text.bytesize || 0
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
    counts.values.map(&JUSTIFYING_COLUMN_PROC).join + "\s#{filename}"
  end.join("\n")
end

if $PROGRAM_NAME == __FILE__
  options = ARGV.getopts('l')
  puts main(line_only: options['l'])
end
