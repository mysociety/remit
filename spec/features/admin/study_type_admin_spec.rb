require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "StudyTypeAdmin" do
  let(:singular_resource_name) { "Study Type" }
  let(:plural_resource_name) { "Study Types" }
  let(:resource_factory) { :study_type }
  let(:resource_class) { StudyType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
