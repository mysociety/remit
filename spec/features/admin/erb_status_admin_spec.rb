require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "ERBStatusAdmin" do
  let(:singular_resource_name) { "Erb Status" }
  let(:plural_resource_name) { "Erb Statuses" }
  let(:resource_factory) { :erb_status }
  let(:resource_class) { ErbStatus }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
