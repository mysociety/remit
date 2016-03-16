require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "MsfLocationAdmin" do
  let(:singular_resource_name) { "Msf Location" }
  let(:plural_resource_name) { "Msf Locations" }
  # We're using a different factory than the default in the hope that it's
  # not already connected to a user or required by other model validation
  let(:resource_factory) { :epicentre_location }
  let(:resource_class) { MsfLocation }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
