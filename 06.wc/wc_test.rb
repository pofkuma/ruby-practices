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

    expected = '       2       2       8'

    assert_equal expected, main(text: input_text)
  end

  def test_wc_in_stdin_empty
    input_text = <<~TEXT
    TEXT

    expected = '       0       0       0'

    assert_equal expected, main(text: input_text)
  end

  def test_wc_in_file_single
    input_file = Tempfile.open do |file|
      file.write(<<~TEXT)
        foo
        bar
      TEXT
      file
    end
    ARGV.replace %W[#{input_file.path}]

    expected = "       2       2       8 #{input_file.path}"
    assert_equal expected, main(file_names: [input_file.path])
  end

  def test_wc_in_file_single_empty
    input_file = Tempfile.new
    ARGV.replace %W[#{input_file.path}]

    expected = "       0       0       0 #{input_file.path}"
    assert_equal expected, main(file_names: [input_file.path])
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
    ARGV.replace %W[#{input_file1.path} #{input_file2.path}]

    expected = <<-TEXT.chomp
       1       1       4 #{input_file1.path}
       1       1       4 #{input_file2.path}
       2       2       8 total
    TEXT
    assert_equal expected, main(file_names: [input_file1.path, input_file2.path])
  end

  def test_wc_in_file_multiple_empty
    input_file1 = Tempfile.new
    input_file2 = Tempfile.new
    ARGV.replace %W[#{input_file1.path} #{input_file2.path}]

    expected = <<-TEXT.chomp
       0       0       0 #{input_file1.path}
       0       0       0 #{input_file2.path}
       0       0       0 total
    TEXT
    assert_equal expected, main(file_names: [input_file1.path, input_file2.path])
  end

  def test_wc_in_file_multiple_same
    input_file = Tempfile.open do |file|
      file.puts('foo')
      file
    end
    ARGV.replace %W[#{input_file.path} #{input_file.path}]

    expected = <<-TEXT.chomp
       1       1       4 #{input_file.path}
       1       1       4 #{input_file.path}
       2       2       8 total
    TEXT
    assert_equal expected, main(file_names: [input_file.path, input_file.path])
  end

  def test_wc_in_file_multiple_many_counts
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
    ARGV.replace %W[#{input_file1.path} #{input_file2.path}]

    expected = <<-TEXT.chomp
       5      50     505 #{input_file1.path}
       5      50     505 #{input_file2.path}
      10     100    1010 total
    TEXT
    assert_equal expected, main(file_names: [input_file1.path, input_file2.path])
  end

  def test_wc_with_option_l_in_stdin
    input_text = <<~TEXT
      foo
      bar
    TEXT

    expected = '       2'

    assert_equal expected, main(text: input_text, line_only: true)
  end

  def test_wc_with_option_l_in_file_single
    input_file = Tempfile.open do |file|
      file.write(<<~TEXT)
        foo
        bar
      TEXT
      file
    end
    ARGV.replace %W[#{input_file.path}]

    expected = "       2 #{input_file.path}"

    assert_equal expected, main(file_names: [input_file.path], line_only: true)
  end

  def test_wc_with_option_l_in_file_multiple
    input_file1 = Tempfile.open do |file|
      file.puts('foo')
      file
    end
    input_file2 = Tempfile.open do |file|
      file.puts('bar')
      file
    end
    ARGV.replace %W[#{input_file1.path} #{input_file2.path}]

    expected = <<-TEXT.chomp
       1 #{input_file1.path}
       1 #{input_file2.path}
       2 total
    TEXT
    assert_equal expected, main(file_names: [input_file1.path, input_file2.path], line_only: true)
  end
end
