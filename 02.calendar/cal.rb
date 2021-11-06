#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'date'

OPTIONS = ARGV.getopts('m:y:')

DATE_TODAY = Date.today
month = (OPTIONS['m'] || DATE_TODAY.mon).to_i
year  = (OPTIONS['y'] || DATE_TODAY.year).to_i

CAL_WIDTH = 20
puts "#{month}月 #{year}".center(CAL_WIDTH)

LINE_CWDAY = '日 月 火 水 木 金 土'
puts LINE_CWDAY

FIRST_DAY = 1
LAST_DAY = Date.new(year, month, -1).day
days = (FIRST_DAY..LAST_DAY).to_a

LENGTH_A_WEEK = 7
FIRST_WDAY = Date.new(year, month).wday
blanks = Array.new(FIRST_WDAY)
days.unshift(*blanks)

days = days.map { |day| day.to_s.rjust(2) }
days.each_slice(LENGTH_A_WEEK) do |sliced_days|
  puts sliced_days.join("\s")
end
