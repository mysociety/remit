Time::DATE_FORMATS[:short_ordinal] = lambda do |time|
  time.strftime("#{time.day.ordinalize} %B")
end
Time::DATE_FORMATS[:medium_ordinal] = lambda do |time|
  time.strftime("#{time.day.ordinalize} %B %Y")
end
