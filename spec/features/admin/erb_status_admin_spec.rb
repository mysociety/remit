require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "ERBStatusAdmin" do
  let(:singular_resource_name) { "Erb Status" }
  let(:plural_resource_name) { "Erb Statuses" }
  let(:resource_factory) { :erb_status }
  let(:resource_class) { ErbStatus }

  def fill_in_extra_required_fields
    fill_in "Description", with: "Test erb status"
    select "good", from: "Good bad or neutral"
  end

  it_behaves_like "simple model admin"
end
