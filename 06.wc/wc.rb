#!/usr/bin/env ruby
# frozen_string_literal: true

DEFAULT_COUNT_PROC = proc { |counts, target| counts[target] = 0 }
COLUMN_SIZE = 8
FILE_NAME = '-'

def main
  count_results = Hash.new { |hash, key| hash[key] = Hash.new(&DEFAULT_COUNT_PROC) }

  ARGF.each do |line|
    primary_keys = {
      object_id: ARGF.file.object_id,  # different when filepath is same
      filename_or_total: ARGF.filename
    }
    count_results[primary_keys][:line_count] += 1
    count_results[primary_keys][:word_count] += line.split("\s").size
    count_results[primary_keys][:byte_count] += line.bytesize
  end

  count_results[{ filename_or_total: 'total' }] = total_counts(count_results) if count_results.size > 1

  puts generate_display_lines(count_results)
end

def generate_display_lines(count_results)
  count_results.map do |key, counts|
    colmuns = counts.values.map { _1.to_s.rjust(COLUMN_SIZE) }.join

    "#{colmuns}\s#{key[:filename_or_total]}" unless key[:filename_or_total] == FILE_NAME
  end
end

def total_counts(each_counts)
  total_counts = Hash.new(&DEFAULT_COUNT_PROC)
  each_counts.each do |_id, counts|
    counts.each { |key, value| total_counts[key] += value }
  end
  total_counts
end

main if $PROGRAM_NAME == __FILE__
