#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

INITIAL_COUNT_PROC = proc { |counts, target| counts[target] = 0 }
COLUMN_SIZE = 8
FAKE_FILE_NAME = '-'

def main(line_only: false)
  filenames = ARGV.dup # ARGF shifts ARGV
  filenames_counts = make_filenames_counts_using_argf(line_only)
  unless filenames.empty?
    filenames_counts =
      make_filenames_counts_include_emptyfile(filenames, filenames_counts, line_only)
  end
  filenames_counts.push(['total', total_counts(filenames_counts)]) if filenames_counts.size > 1

  format_display_lines(filenames_counts)
end

def make_filenames_counts_using_argf(line_only)
  files_counts = Hash.new { |hash, key| hash[key] = Hash.new(&INITIAL_COUNT_PROC) }
  ARGF.each do |line|
    unique_keys = { object_id: ARGF.file.object_id, # different when filenames are same
                    filename: ARGF.filename }
    files_counts[unique_keys][:line_count] += 1
    next if line_only

    files_counts[unique_keys][:word_count] += line.split("\s").size
    files_counts[unique_keys][:byte_count] += line.bytesize
  end
  files_counts.map { |unique_keys, counts| [unique_keys[:filename], counts] }
end

def make_filenames_counts_include_emptyfile(filenames, filenames_counts, line_only)
  count_keys = make_count_keys(line_only)
  filenames.map do |filename|
    counts = Hash.new(&INITIAL_COUNT_PROC)
    count_keys.each { |key| counts[key] }
    filenames_counts.map do |to_filename, to_counts|
      counts = to_counts if to_filename == filename
    end
    [filename, counts]
  end
end

def make_count_keys(line_only)
  return [:line_count] if line_only

  %i[line_count word_count byte_count]
end

def total_counts(contents_with_counts)
  total_counts = Hash.new(&INITIAL_COUNT_PROC)
  contents_with_counts.each do |_id, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts
end

def format_display_lines(filenames_counts)
  filenames_counts.map do |filename, counts|
    formatted_count = counts.values.map { _1.to_s.rjust(COLUMN_SIZE) }.join
    filename == FAKE_FILE_NAME ? formatted_count : formatted_count + "\s#{filename}"
  end
end

if $PROGRAM_NAME == __FILE__
  options = ARGV.getopts('l')
  puts main(line_only: options['l'])
end
