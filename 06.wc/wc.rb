#!/usr/bin/env ruby
# frozen_string_literal: true

DEFAULT_COUNT_PROC = proc { |counts, target| counts[target] = 0 }
COLUMN_SIZE = 8
FAKE_FILE_NAME = '-'

def main
  filenames = ARGV.dup
  files_counts = Hash.new { |hash, key| hash[key] = Hash.new(&DEFAULT_COUNT_PROC) }
  ARGF.each do |line|
    unique_keys = { object_id: ARGF.file.object_id, # different when filenames are same
                    filename: ARGF.filename }
    # TODO: -lオプションに対応する
    files_counts[unique_keys][:line_count] += 1
    files_counts[unique_keys][:word_count] += line.split("\s").size
    files_counts[unique_keys][:byte_count] += line.bytesize
  end

  filenames_counts = filenames.map do |filename|
    counts = [0, 0, 0]
    files_counts.map do |unique_keys, count_tables|
      counts = count_tables.values if unique_keys[:filename] == filename
    end
    [filename, counts]
  end

  filenames_counts.push(['total', total_counts(files_counts)]) if files_counts.size > 1

  generate_display_lines(filenames_counts)
end

def each_counts(lines)
  counts = Hash.new(&DEFAULT_COUNT_PROC)
  lines.each do |line|
    counts[:line_count] += 1
    counts[:word_count] += line.split("\s").size
    counts[:byte_count] += line.bytesize
  end
  counts
end

def total_counts(contents_with_counts)
  total_counts = Hash.new(&DEFAULT_COUNT_PROC)
  contents_with_counts.each do |_id, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts.values
end

def generate_display_lines(filenames_counts)
  filenames_counts.map do |filename, counts|
    line = counts.map { _1.to_s.rjust(COLUMN_SIZE) }.join
    filename == FAKE_FILE_NAME ? line : line + "\s#{filename}"
  end
end

puts main if $PROGRAM_NAME == __FILE__
