#!/usr/bin/env ruby
# frozen_string_literal: true

CURRENT_DIRECTORY = '.'
PADDING_SIZE = 7
MAX_COLUMUNS = 3

public
def print_content_lists(content_name_lists)
  content_name_lists.format_width.format_lines
end

# 所定のディレクトリ直下のファイル(ディレクトリを含む)を取得する: Dir.entries
# ファイル名を昇順で並び替える: sort
# ドットで始まるファイルsを除外する
def fetch_target_content_names(directory_path)
  lists = Dir.entries(directory_path).sort
  lists.reject { |list| list =~ /^\./ }
end

# 表示幅を空白詰めで揃える
def format_width
  #   最長のファイル名の桁数を取得する: max_byとlength
  max_name_length = map(&:length).max
  #   上の桁数＋余白の桁数で左詰する: mapとljust
  map { |list| list.ljust(max_name_length + PADDING_SIZE) }
end

# 折り返して表示する
def format_lines
  #   表示行数を求める
  rows = size / MAX_COLUMUNS
  #      ファイル数を列数で割って、割り切れたら商の値、割り切れなかったら商+1の値
  rows += 1 unless (size % MAX_COLUMUNS).zero?
  return self if rows == 0

  #   表示行数で区切って、列数分だけ横にくっつける
  lines = Array.new(rows) { '' }
  each_slice(rows) do |sliced_lists|
    sliced_lists.each_with_index do |list, index|
      lines[index] += list
    end
  end
  lines
end

content_name_lists = fetch_target_content_names(CURRENT_DIRECTORY)
puts print_content_lists(content_name_lists)
