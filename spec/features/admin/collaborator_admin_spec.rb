require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "CollaboratorAdmin" do
  let(:singular_resource_name) { "Collaborator" }
  let(:plural_resource_name) { "Collaborators" }
  let(:resource_factory) { :collaborator }
  let(:resource_class) { Collaborator }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
