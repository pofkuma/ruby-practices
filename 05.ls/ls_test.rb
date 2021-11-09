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
    content_name_lists = %w[1]
    expected = <<~TEXT
      1       
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_two_contents
    content_name_lists = %w[1 2].shuffle
    expected = <<~TEXT
      1       2       
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_three_contents
    content_name_lists = %w[1 2 3].shuffle
    expected = <<~TEXT
      1       2       3       
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_four_contents
    content_name_lists = %w[1 2 3 4].shuffle
    expected = <<~TEXT
      1       3       
      2       4       
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_five_contents
    content_name_lists = %w[1 2 3 4 5].shuffle 
    expected = <<~TEXT
      1       3       5       
      2       4       
    TEXT
    assert_equal expected, print_content_lists(content_name_lists)
  end

  def test_ls_no_options_contents_which_have_names_starting_with_dot
    content_name_lists = %w[. ..].shuffle 
    expected = ''
    assert_equal expected, print_content_lists(content_name_lists)
  end
end
