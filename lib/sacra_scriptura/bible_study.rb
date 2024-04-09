# frozen_string_literal: true

require 'httparty'

API_BASE = 'https://bible.helloao.org/api'

def download_verse(translation, verse)
  req = case translation
        when 'ARBNAV' || 'HBOMAS' then "#{API_BASE}/#{translation}/#{verse.chapter}/#{verse.book}.json"
        else "#{API_BASE}/#{translation}/#{verse.book}/#{verse.chapter}.json"
        end
  res = HTTParty.get req
  return res.parsed_response if res.ok?

  puts "failed: #{res.code} response"
  []
end

def print_verse(verse)
  case verse['type']
  when 'verse' then handle_verse_type verse
  else puts '%s', verse['type']
  end
end

def handle_verse_type(verse_content)
  notes = []
  printf '%d. ', verse_content['number']
  verse_content['content'].each do |content|
    note = content['noteId']
    text = content['text']
    text.nil? ? (handle_special_content content) : (print text)
    notes << handle_verse_note(note) unless note.nil?
  end

  notes
end

def handle_special_content(content)
  puts '' unless content['lineBreak'].nil?
  print content, ' ' if content.is_a? String
end

def handle_verse_note(note)
  printf '(%d) ', note
  note
end
