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

  require 'etc'
  require 'fileutils'

  def test_ls_with_opton_l
    options = { l: true }
    contents = list_directory_contents(options).split("\s")
    assert_includes contents, generate_mock_file_status('test_file')
    assert_includes contents, generate_mock_file_status('test_dir', is_directory: true)
  end

  def generate_mock_file_status(pathname, is_directory: false)
    FileUtils.rm_r("#{__dir__}/test") if File.exist?("#{__dir__}/test")
    FileUtils.mkdir("#{__dir__}/test")
    FileUtils.cd("#{__dir__}/test")

    file_type = is_directory ? FileUtils.mkdir(pathname) && 'd' : FileUtils.touch(pathname) && '-'
    created_time = Time.now

    uid = Etc.getpwuid

    max_length_of_filesize = Dir.open('.').each.map { |file| File.size(file).to_s.length }.max
    filesize = File.size(pathname)

    {
      file_type_and_permission: "#{file_type}rw-r--r-- ",
      number_of_links: '1',
      owner_name: uid.name.concat("\s"),
      group_name: Etc.getgrgid(uid.gid).name << "\s",
      number_of_filesize: filesize.to_s.rjust(max_length_of_filesize),
      last_modified_date: created_time.strftime('%_2m %_2d %H:%M'),
      pathname: pathname
    }.values.join("\s")
    # example: 'drw-r--r--  1 kumakaori  staff  0 12  2 15:54 test_dir'
    # example: '-rw-r--r--  1 kumakaori  staff  0 12  2 15:54 test_file'
  end
end
