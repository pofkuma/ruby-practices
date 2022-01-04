#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DEFAULT_COUNT_PROC = proc { |counts, target| counts[target] = 0 }
COLUMN_SIZE = 8
FAKE_FILE_NAME = '-'

def main(line_only: false)
  filenames = ARGV.dup
  files_counts = Hash.new { |hash, key| hash[key] = Hash.new(&DEFAULT_COUNT_PROC) }
  ARGF.each do |line|
    unique_keys = { object_id: ARGF.file.object_id, # different when filenames are same
                    filename: ARGF.filename }

    files_counts[unique_keys][:line_count] += 1
    next if line_only

    files_counts[unique_keys][:word_count] += line.split("\s").size
    files_counts[unique_keys][:byte_count] += line.bytesize
  end

  filenames_counts =
    if filenames.empty?
      files_counts.map { |unique_keys, counts| [unique_keys[:filename], counts] }
    else
      count_keys = [:line_count]
      count_keys += [:word_count] + [:byte_count] unless line_only

      filenames.map do |filename|
        counts = Hash.new(&DEFAULT_COUNT_PROC)
        count_keys.each { |key| counts[key] }
        files_counts.map do |unique_keys, count_tables|
          counts = count_tables if unique_keys[:filename] == filename
        end
        [filename, counts]
      end
    end
  filenames_counts.push(['total', total_counts(files_counts)]) if files_counts.size > 1
  generate_display_lines(filenames_counts)
end

def total_counts(contents_with_counts)
  total_counts = Hash.new(&DEFAULT_COUNT_PROC)
  contents_with_counts.each do |_id, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts
end

def generate_display_lines(filenames_counts)
  filenames_counts.map do |filename, counts|
    line = counts.values.map { _1.to_s.rjust(COLUMN_SIZE) }.join
    filename == FAKE_FILE_NAME ? line : line + "\s#{filename}"
  end
end

if $PROGRAM_NAME == __FILE__
  options = ARGV.getopts('l')
  puts main(line_only: options['l'])
end
