# frozen_string_literal: true

require 'optparse'

Verse = Struct.new :book, :chapter, :verses

def parse_options
  options = { translation: 'BSB' }
  OptionParser.new do |parser|
    parser.on('-t', '--translation=[TRANSLATION]') { |translation| options[:translation] = translation }
  end.parse!
  options
end

def parse_verses(verses)
  verses.collect { |verse| parse_verse verse }
end

def parse_verse(verse_str)
  book, chapter_and_verses = verse_str.split ' '
  chapter_and_verses, result = handle_multiple_chapters(book, chapter_and_verses)
  return result if chapter_and_verses == ''

  chapter, verses = chapter_and_verses.split ':'
  result << Verse.new(book, chapter.to_i, build_verses_arr(verses))
  result
end

def handle_multiple_chapters(book, chapters_and_verses)
  result, to_parse = prepare_chapters chapters_and_verses, book

  if to_parse.match(/\d+:\d+-\d+:\d+/)
    ['', handle_continuous_chapters(book, to_parse, result)]
  else
    [to_parse, result]
  end
end

def prepare_chapters(chapters_and_verses, book)
  result = []
  to_parse = chapters_and_verses

  loop do
    next_verse = to_parse.match(/,\d+:/)
    break if next_verse.nil?

    chapter, verses = chapters_and_verses[..next_verse.begin(0) - 1].split ':'
    result << Verse.new(book, chapter.to_i, build_verses_arr(verses))
    to_parse = chapters_and_verses[next_verse.begin(0) + 1..]
  end

  [result, to_parse]
end

def handle_continuous_chapters(book, to_parse, result)
  beginning, ending = to_parse.split '-'
  first_chapter, first_verse = beginning.split ':'
  last_chapter, last_verse = ending.split ':'
  result << Verse.new(book, first_chapter.to_i, [first_verse.to_i, -1])
  result << Verse.new(book, last_chapter.to_i, (1..last_verse.to_i).to_a)
  result
end

def build_verses_arr(verses_str)
  result = []
  verses_str.split(',').each do |verse|
    if verse.count('-').positive?
      min, max = verse.split('-').map(&:to_i)
      (min..max).each { |idx| result << idx }
    else
      result << verse.to_i
    end
  end
  result
end
