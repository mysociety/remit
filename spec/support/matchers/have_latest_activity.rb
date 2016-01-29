require "support/matchers/match_activity"

RSpec::Matchers.define :have_latest_activity do |activity_values|
  match do |actual|
    expect(actual.activities.first).to match_activity(activity_values)
  end
  failure_message do |actual|
    activity = actual.activities.first
    "expected that #{activity.inspect}\nwould have #{activity_values.inspect}"
  end
end
