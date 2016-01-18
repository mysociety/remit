require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "StudyTypeAdmin" do
  let(:singular_resource_name) { "Study Type" }
  let(:plural_resource_name) { "Study Types" }
  let(:resource_factory) { :study_type }
  let(:resource_class) { StudyType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
