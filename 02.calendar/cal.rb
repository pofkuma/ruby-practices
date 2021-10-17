#!/usr/bin/env ruby

require 'optparse'
require 'date'

OPTIONS = ARGV.getopts("m:y:")

DATE_TODAY = Date.today
month = OPTIONS["m"] ? OPTIONS["m"].to_i : DATE_TODAY.mon
year  = OPTIONS["y"] ? OPTIONS["y"].to_i : DATE_TODAY.year

CAL_WIDTH = 20
puts "#{month}月 #{year}".center(CAL_WIDTH)

LINE_CWDAY = "日 月 火 水 木 金 土"
puts LINE_CWDAY

FIRST_DAY = 1
LAST_DAY = Date.new(year, month, -1).day
days = (FIRST_DAY..LAST_DAY).to_a.map(&:to_s)

LENGTH_A_WEEK = 7
FIRST_CWDAY = Date.new(year, month).cwday
FIRST_CWDAY.times { days.unshift("\s") } if FIRST_CWDAY < LENGTH_A_WEEK

days = days.map { |day| day.rjust(2) }
days.each_slice(LENGTH_A_WEEK) do |sliced_days|
  puts (sliced_days.join("\s"))
end
