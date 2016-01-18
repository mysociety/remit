require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "EnablerBarrierAdmin" do
  let(:singular_resource_name) { "Enabler Barrier" }
  let(:plural_resource_name) { "Enabler Barriers" }
  let(:resource_factory) { :enabler_barrier }
  let(:resource_class) { EnablerBarrier }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
