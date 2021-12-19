#!/usr/bin/env ruby
# frozen_string_literal: true
def wc
  count_results = Hash.new { |hash, key| hash[key] = Hash.new(&DEFAULT_COUNT_PROC) }

  ARGF.each do |line|
    primary_keys = {
      object_id: ARGF.file.object_id,
      filename_or_total: ARGF.filename
    }
    count_results[primary_keys][:line_count] += 1
    count_results[primary_keys][:word_count] += line.split("\s").size
    count_results[primary_keys][:byte_count] += line.bytesize
  end

  if count_results.size > 1
    total_counts = Hash.new(&DEFAULT_COUNT_PROC)
    count_results.each do |_id, counts|
      counts.each { |key, value| total_counts[key] += value }
    end

    count_results[{ filename_or_total: 'total' }] = total_counts
  end

  count_results.map do |key, counts|
    colmuns = counts.values.map { _1.to_s.rjust(COLUMN_SIZE) }.join

    "#{colmuns}\s#{key[:filename_or_total]}" unless key[:filename_or_total] == FILE_NAME
  end
end


DEFAULT_COUNT_PROC = proc { |counts, target| counts[target] = 0 }
COLUMN_SIZE = 8
FILE_NAME = '-'

if $PROGRAM_NAME == __FILE__

  puts wc
end
