#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 8
FAKE_FILE_NAME = '-'

def main(line_only: false)
  filenames_counts = make_filenames_counts(line_only)
  filenames_counts.push(['total', total_counts(filenames_counts)]) if filenames_counts.size > 1
  format_display_lines(filenames_counts)
end

def make_filenames_counts(line_only)
  if ARGV.empty?
    text = $stdin.gets(rs = nil)
    [[FAKE_FILE_NAME, count_text(text, line_only)]]
  else
    ARGV.map do |pathname|
      File.open(pathname) do |file|
        text = file.gets(rs = nil)
        [pathname, count_text(text, line_only)]
      end
    end
  end
end

def count_text(text, line_only)
  counts = {}
  counts[:line_count] = text&.split("\n")&.size || 0
  unless line_only
    counts[:word_count] = text&.split("\s")&.size || 0
    counts[:byte_count] = text&.bytesize || 0
  end
  counts
end

def total_counts(filenames_counts)
  total_counts = Hash.new { |counts, target| counts[target] = 0 }
  filenames_counts.each do |_id, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts
end

def format_display_lines(filenames_counts)
  filenames_counts.map do |filename, counts|
    formatted_count = counts.values.map { _1.to_s.rjust(COLUMN_SIZE) }.join
    filename == FAKE_FILE_NAME ? formatted_count : formatted_count + "\s#{filename}"
  end.join("\n")
end

if $PROGRAM_NAME == __FILE__
  options = ARGV.getopts('l')
  puts main(line_only: options['l'])
end
