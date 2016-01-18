require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

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
