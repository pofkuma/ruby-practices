# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'wc'

class WcTest < Minitest::Test
  def test_wc_from_std_in
    input = <<~TEXT
      foo
      bar
    TEXT

    expected = '       2       2       8'

    assert_equal expected, wc(input)
  end
end
