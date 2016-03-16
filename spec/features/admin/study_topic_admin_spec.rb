require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "StudyTopicAdmin" do
  let(:singular_resource_name) { "Study Topic" }
  let(:plural_resource_name) { "Study Topics" }
  let(:resource_factory) { :study_topic }
  let(:resource_class) { StudyTopic }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
