# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require_relative 'ls'

class LsTest < Minitest::Test
  TEST_DIR = "#{__dir__}/test"

  def setup
    FileUtils.rm_r(TEST_DIR) if File.exist?(TEST_DIR)
    FileUtils.mkdir(TEST_DIR)
  end

  def teardown
    FileUtils.rm_r(TEST_DIR) if File.exist?(TEST_DIR)
  end

  def test_ls_without_opton_no_contents
    assert_nil list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_one_contents
    %w[1].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      1
    TEXT
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_two_contents
    %w[1 2].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      1       2
    TEXT
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_three_contents
    %w[1 2 3].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      1       2       3
    TEXT
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_four_contents
    %w[1 2 3 4].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      1       3
      2       4
    TEXT
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_five_contents
    %w[1 2 3 4 5].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      1       3       5
      2       4
    TEXT
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_file_length_less
    %w[1234567 foo].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = '1234567 foo'
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_file_length_just
    %w[12345678 foo].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = '12345678        foo'
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_file_length_more
    %w[123456789 foo].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = '123456789       foo'
    assert_equal expected, list_directory_contents(TEST_DIR)
  end

  def test_ls_without_opton_a
    options = {}
    assert_nil list_directory_contents(TEST_DIR, **options)
  end

  def test_ls_with_opton_a
    options = { all: true }
    contents = list_directory_contents(TEST_DIR, **options).split("\s")
    assert(contents.find { |content| content.start_with?('.') })
    assert(contents.find { |content| content.start_with?('..') })
  end

  def test_ls_without_opton_r
    options = { all: true }
    contents = list_directory_contents(TEST_DIR, **options).split("\s")
    assert(contents[0].start_with?('.'))
  end

  def test_ls_with_opton_r
    options = { all: true, reverse: true }
    contents = list_directory_contents(TEST_DIR, **options).split("\s")
    assert(contents[-1].start_with?('.'))
  end

  def test_ls_without_opton_l
    options = { all: true }
    contents = list_directory_contents(TEST_DIR, **options)
    assert(contents[0].start_with?('.'))
  end

  def test_ls_with_opton_l
    FileUtils.mkdir("#{TEST_DIR}/dummy_dir")
    FileUtils.touch("#{TEST_DIR}/dummy_file")
    expected_contents = `ls -l #{TEST_DIR}`.split("\n")

    options = { long: true }
    contents = list_directory_contents(TEST_DIR, **options)
    assert_equal expected_contents, contents
  end

  def test_ls_with_opton_l_no_contents
    options = { long: true }
    contents = list_directory_contents(TEST_DIR, **options)
    assert_equal ['total 0'], contents
  end

  def test_ls_without_opton_a_and_r
    %w[1 2 3].each { FileUtils.touch("#{TEST_DIR}/#{_1}") }
    expected = <<~TEXT.chomp
      3       1       .
      2       ..
    TEXT

    options = { all: true, reverse: true }
    assert_equal expected, list_directory_contents(TEST_DIR, **options)
  end

  def test_filetype_char
    files =
      # Paths are on macOS
      { '-': '/var/log/system.log',                            # normal file
        'd': '/dev',                                           # directory
        'c': '/dev/null',                                      # characterSpecial file
        'b': '/dev/disk0',                                     # blockSpecial file
        'p': "#{TEST_DIR}/dummy_fifo".tap { File.mkfifo(_1) }, # fifo file
        'l': '/var',                                           # link file
        's': '/var/run/syslog' }                               # socket file

    files.each do |char, file|
      filetype = File.ftype(file)
      assert_equal char, filetype_char(filetype)
    end
  end

  def test_filetype_char_unknown
    assert_nil filetype_char('')
  end
end
