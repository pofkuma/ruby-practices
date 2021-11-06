#!/usr/bin/env ruby

# frozen_string_literal: true

MAX_PINS = 10
MAX_FRAMES = 10
STRIKE_MARK = 'X'

def strike?(frame)
  frame[0] == MAX_PINS
end

def spare?(frame)
  !strike?(frame) && frame.sum == MAX_PINS
end

def bonus_score(frames, index, count)
  next_throws = frames.slice(index + 1, count).flatten
  if strike?(next_throws)
    next_throws.take(count + 1).sum
  else
    next_throws.take(count).sum
  end
end

def final_frame?(index)
  index >= (MAX_FRAMES - 1)
end

joined_score = ARGV[0]
scores = joined_score.split(',')

throws = []
scores.each do |score|
  if score == STRIKE_MARK
    throws << MAX_PINS
    throws << 0
  else
    throws << score.to_i
  end
end

frames = throws.each_slice(2).to_a

total_score = 0
frames.each_with_index do |frame, index|
  total_score += frame.sum
  next if final_frame?(index)

  if strike?(frame)
    total_score += bonus_score(frames, index, 2)
  elsif spare?(frame)
    total_score += bonus_score(frames, index, 1)
  end
end

puts total_score
