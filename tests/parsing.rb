# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../main'

# tests parsing strings into verses
class ParsingTest < Minitest::Test
  def test_parse_single_chapters
    expected = [Verse.new('Genesis', 1, [3, 4, 5, 6, 9, 11])]
    actual = parse_verse('Genesis 1:3-6,9,11')
    assert_equal expected, actual

    expected = [Verse.new('Genesis', 1, [20, 21, 22, 24])]
    actual = parse_verse('Genesis 1:20-22,24')
    assert_equal expected, actual
  end

  def test_parse_multiple_chapters
    expected = [
      Verse.new('Exodus', 12, [43, 44, 45, 46, 47, 48, 50]),
      Verse.new('Exodus', 13, [1, 2, 4])
    ]

    actual = parse_verse 'Exodus 12:43-48,50,13:1-2,4'
    assert_equal expected, actual
  end

  def test_parse_multiple_chapters_no_breaks
    expected = [
      Verse.new('Isaiah', 52, [13, -1]),
      Verse.new('Isaiah', 53, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
    ]

    actual = parse_verse 'Isaiah 52:13-53:12'
    assert_equal expected, actual
  end
end
