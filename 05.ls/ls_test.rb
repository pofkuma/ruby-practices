# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'ls'

class LsTest < Minitest::Test
  def test_ls_no_options_no_contents
    content_name_lists = %w[. ..]
    assert_nil list_directory_contents(content_name_lists)
  end

  def test_ls_no_options_one_contents
    content_name_lists = %w[. ..] + %w[1]
    expected = <<~TEXT
      1
    TEXT
    assert_equal expected, list_directory_contents(content_name_lists)
  end

  def test_ls_no_options_two_contents
    content_name_lists = %w[. ..] + %w[1 2].shuffle
    expected = <<~TEXT
      1       2
    TEXT
    assert_equal expected, list_directory_contents(content_name_lists)
  end

  def test_ls_no_options_three_contents
    content_name_lists = %w[. ..] + %w[1 2 3].shuffle
    expected = <<~TEXT
      1       2       3
    TEXT
    assert_equal expected, list_directory_contents(content_name_lists)
  end

  def test_ls_no_options_four_contents
    content_name_lists = %w[. ..] + %w[1 2 3 4].shuffle
    expected = <<~TEXT
      1       3
      2       4
    TEXT
    assert_equal expected, list_directory_contents(content_name_lists)
  end

  def test_ls_no_options_five_contents
    content_name_lists = %w[. ..] + %w[1 2 3 4 5].shuffle
    expected = <<~TEXT
      1       3       5
      2       4
    TEXT
    assert_equal expected, list_directory_contents(content_name_lists)
  end
end
