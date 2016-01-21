RSpec::Matchers.define :have_latest_activity do |key, params|
  match do |actual|
    activity = actual.activities.order(:created_at).last
    activity.key == key && activity.parameters == params
  end
  failure_message do |actual|
    activity = actual.activities.order(:created_at).last
    "expected that #{activity.inspect}\nwould have key #{key} and "\
    "parameters: #{params}"
  end
end
