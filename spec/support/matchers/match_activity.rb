RSpec::Matchers.define :match_activity do |activity_values|
  match do |actual|
    return false if actual.nil? && activity_values.present?
    pass = true
    activity_values.each do |name, expected_value|
      pass &&= actual.send(name.to_sym) == expected_value
      break unless pass
    end
    pass
  end
  failure_message do |actual|
    "expected that #{actual.inspect}\nwould match #{activity_values.inspect}"
  end
end
