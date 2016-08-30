require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone)
  new_phone = phone.to_s.gsub(/[^0-9]/, "")
  if new_phone.length == 10
    return new_phone
  elsif new_phone.length == 11 && new_phone[0] == "1"
    return new_phone[1..-1]
  else
    return "Bad Number"
  end
end

def target_DateTime(regdate)
  d = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
end

def hour_frequency(hours)
  hour_freq = hours.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  best_hour = hours.max_by { |v| hour_freq[v] }
  #h = DateTime.strptime(best_hour.to_s, '%H')
  puts "The best time for advertisement is #{best_hour}:00"
  puts "With #{hour_freq[best_hour]} registration(s) at that time for the previous conference."
end

def day_frequency(days)
  day_freq = days.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  best_day = days.max_by { |v| day_freq[v] }
  puts "Most people registered on a #{best_day.strftime('%A')}."
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone = clean_phone(row[:homephone])
  d = target_DateTime(row[:regdate])

  hours << d.hour
  days << d

  puts "#{name}, #{phone}"

  #form_letter = erb_template.result(binding)

  #save_thank_you_letters(id, form_letter)
end

hour_frequency(hours)
day_frequency(days)
