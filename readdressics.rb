#!/usr/bin/ruby

require 'rubygems'
require 'tmail'
require 'mime'

# Grab addresses
($primary, $secondary) = ARGV
exit unless ( ($primary != nil) and ($secondary != nil) )

# Parse the stdin email grabbing the text and ics
ics = ""
text = ""
orig = TMail::Mail.parse($stdin.read)
orig.parts.each do |part|
  if part.content_type == 'text/plain' then
    text = part.body
  end
  if part.content_type == 'text/calendar' then
    ics = part.body
    ics.gsub!(/\r\n /,'')
    ics.gsub!($primary, $secondary)
  end
end

# The Mail
mail = MIME::Message.new
mail.date = orig.date
mail.to = $secondary
mail.from = orig.from
mail.subject = orig.subject

# The Plaintext
plain = MIME::TextMedia.new(text, "text/plain")

# The Meeting
meeting = MIME::TextMedia.new(ics, "text/calendar")
meeting.content_transfer_encoding = "8bit"

# The Body
body = MIME::MultipartMedia::Mixed.new
body.inline_entity(plain)
body.attach_entity(meeting, 'filename' => "meeting.ics")
mail.body = body

puts mail.to_s
