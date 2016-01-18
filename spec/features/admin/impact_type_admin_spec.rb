require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "ImpactTypeAdmin" do
  let(:singular_resource_name) { "Impact Type" }
  let(:plural_resource_name) { "Impact Types" }
  let(:resource_factory) { :impact_type }
  let(:resource_class) { ImpactType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
