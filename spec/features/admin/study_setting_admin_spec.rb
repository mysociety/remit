require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "StudySettingAdmin" do
  let(:singular_resource_name) { "Study Setting" }
  let(:plural_resource_name) { "Study Settings" }
  let(:resource_factory) { :study_setting }
  let(:resource_class) { StudySetting }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
