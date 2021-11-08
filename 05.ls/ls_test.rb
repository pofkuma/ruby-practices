# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'ls'

class LsTest < Minitest::Test
  def test_ls_no_options_no_contents
    content_name_lists = []
    expected = ''
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_one_contents
    content_name_lists = [1]
    expected = <<~TEXT
      1
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_two_contents
    content_name_lists = %w[1 2]
    expected = <<~TEXT
      1       2
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_three_contents
    content_name_lists = %w[1 2 3]
    expected = <<~TEXT
      1       2       3
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_four_contents
    content_name_lists = %w[1 2 3 4]
    expected = <<~TEXT
      1       3
      2       4
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_five_contents
    content_name_lists = %w[1 2 3 4 5]
    expected = <<~TEXT
      1       3       5
      2       4
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end
end
