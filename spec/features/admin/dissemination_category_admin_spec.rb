require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "DisseminationCategoryAdmin" do
  let(:singular_resource_name) { "Dissemination Category" }
  let(:plural_resource_name) { "Dissemination Categories" }
  let(:resource_factory) { :dissemination_category }
  let(:resource_class) { DisseminationCategory }

  def fill_in_extra_required_fields
    select "internal", from: "Dissemination category type"
  end

  it_behaves_like "simple model admin"
end
