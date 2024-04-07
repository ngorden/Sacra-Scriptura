#! /usr/bin/ruby

# frozen_string_literal: true

require_relative 'bible_study'
require_relative 'parsing'

def main
  options = parse_options
  verses = (ARGV.empty? ? parse_verses(['John 3:16']) : parse_verses(ARGV)).flatten
  verses.each { |verse| format_verse verse, download_verse(options[:translation], verse) }
end

def format_verse(verse, scripture)
  content = trim_content scripture
  verse = fill_verses(content, verse)
  puts "#{verse.book} #{verse.chapter}:#{verse.verses.join ','}", ''
  footnotes = content.select { |cnt| verse.verses.include? cnt['number'] }
                     .collect { |cnt| print_verse(cnt) }.flatten!

  puts '', ''
  handle_footnotes scripture, footnotes
end

def fill_verses(scripture, verse)
  return verse unless verse.verses.include?(-1)

  verse.verses = (verse.verses[0]..scripture.max { |ver| ver['number'] }['number']).to_a
  verse
end

def trim_content(content)
  content['chapter']['content'].reject { |cnt| cnt['type'].nil? || cnt['type'] != 'verse' }
end

def handle_footnotes(scripture, footnotes)
  scripture['chapter']['footnotes']
    .select { |note| footnotes.include? note['noteId'] }
    .each { |note| puts "(#{note['noteId']}) #{note['text']}" }
end

main if __FILE__ == $PROGRAM_NAME
