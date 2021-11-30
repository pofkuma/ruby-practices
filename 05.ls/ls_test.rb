# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'ls'

class LsTest < Minitest::Test
  def test_format_no_contents
    content_name_lists = []
    assert_nil format(content_name_lists)
  end

  def test_format_one_contents
    content_name_lists = %w[1]
    expected = <<~TEXT.chomp
      1
    TEXT
    assert_equal expected, format(content_name_lists)
  end

  def test_format_two_contents
    content_name_lists = %w[1 2].shuffle
    expected = <<~TEXT.chomp
      1       2
    TEXT
    assert_equal expected, format(content_name_lists)
  end

  def test_format_three_contents
    content_name_lists = %w[1 2 3].shuffle
    expected = <<~TEXT.chomp
      1       2       3
    TEXT
    assert_equal expected, format(content_name_lists)
  end

  def test_format_four_contents
    content_name_lists = %w[1 2 3 4].shuffle
    expected = <<~TEXT.chomp
      1       3
      2       4
    TEXT
    assert_equal expected, format(content_name_lists)
  end

  def test_format_five_contents
    content_name_lists = %w[1 2 3 4 5].shuffle
    expected = <<~TEXT.chomp
      1       3       5
      2       4
    TEXT
    assert_equal expected, format(content_name_lists)
  end

  def test_format_five_contents_reverse
    content_name_lists = %w[1 2 3 4 5].shuffle
    expected = <<~TEXT.chomp
      5       3       1
      4       2
    TEXT
    assert_equal expected, format(content_name_lists, reverse: true)
  end

  def test_ls_without_opton_a
    options = {}
    contents = list_directory_contents(options).split("\s")
    assert_nil(contents.find { |content| content.start_with?('.') })
  end

  def test_ls_with_opton_a
    options = { a: true }
    contents = list_directory_contents(options).split("\s")
    assert(contents.find { |content| content.start_with?('.') })
    assert(contents.find { |content| content.start_with?('..') })
  end

  def test_ls_without_opton_r
    options = { a: true }
    contents = list_directory_contents(options).split("\s")
    assert(contents[0].start_with?('.'))
  end

  def test_ls_with_opton_r
    options = { a: true, r: true }
    contents = list_directory_contents(options).split("\s")
    assert(contents[-1].start_with?('.'))
  end
end
