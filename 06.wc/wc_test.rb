# frozen_string_literal: true

require 'minitest/autorun'
require 'tempfile'
require_relative 'wc'

class WcTest < Minitest::Test
  def test_wc_in_stdin
    input_text = <<~TEXT
      foo
      bar
    TEXT

    expected = "       2       2       8\n"

    assert_equal expected, count_text(input_text)
  end

  def test_wc_in_stdin_empty
    input_text = <<~TEXT
    TEXT

    expected = "       0       0       0\n"

    assert_equal expected, count_text(input_text)
  end

  def test_wc_in_stdin_many
    line_count = 10 / 2
    word_count = 10
    word_and_whitespace = '123456789 '

    input_file1 = Tempfile.open do |file|
      line_count.times { file.puts(word_and_whitespace * word_count) }
      file
    end

    input_file2 = Tempfile.open do |file|
      line_count.times { file.puts(word_and_whitespace * word_count) }
      file
    end

    expected = `wc #{input_file1.path} #{input_file2.path}`

    assert_equal expected, wc_in_file(input_file1.path, input_file2.path)
  end

  def test_wc_in_stdin_with_option_l
    input_text = <<~TEXT
      foo
      bar
    TEXT

    expected = "       2\n"

    assert_equal expected, count_text(input_text)
  end

  def test_wc_in_file_single
    input_file = Tempfile.open do |file|
      file.write(<<~TEXT)
        foo
        bar
      TEXT
      file
    end

    expected = `wc #{input_file.path}`

    assert_equal expected, wc_in_file(input_file.path)
  end

  def test_wc_in_file_multiple
    input_file1 = Tempfile.open do |file|
      file.puts('foo')
      file
    end

    input_file2 = Tempfile.open do |file|
      file.puts('bar')
      file
    end

    expected = `wc #{input_file1.path} #{input_file2.path}`

    assert_equal expected, wc_in_file(input_file1.path, input_file2.path)
  end

  def test_wc_in_file_multiple_with_option_l
    input_file1 = Tempfile.open do |file|
      file.puts('foo')
      file
    end

    input_file2 = Tempfile.open do |file|
      file.puts('bar')
      file
    end

    expected = `wc -l #{input_file1.path} #{input_file2.path}`

    assert_equal expected, wc_in_file(input_file1.path, input_file2.path)
  end
end
