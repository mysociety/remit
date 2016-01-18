require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "StudySettingAdmin" do
  let(:singular_resource_name) { "Study Setting" }
  let(:plural_resource_name) { "Study Settings" }
  let(:resource_factory) { :study_setting }
  let(:resource_class) { StudySetting }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
