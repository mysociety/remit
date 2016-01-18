require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "StudyTopicAdmin" do
  let(:singular_resource_name) { "Study Topic" }
  let(:plural_resource_name) { "Study Topics" }
  let(:resource_factory) { :study_topic }
  let(:resource_class) { StudyTopic }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
