require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "ImpactTypeAdmin" do
  let(:singular_resource_name) { "Impact Type" }
  let(:plural_resource_name) { "Impact Types" }
  let(:resource_factory) { :impact_type }
  let(:resource_class) { ImpactType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
