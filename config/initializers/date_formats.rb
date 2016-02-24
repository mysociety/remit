Date::DATE_FORMATS[:short_ordinal] = lambda do |date|
  date.strftime("#{date.day.ordinalize} %B")
end
Date::DATE_FORMATS[:medium_ordinal] = lambda do |date|
  date.strftime("#{date.day.ordinalize} %B %Y")
end
