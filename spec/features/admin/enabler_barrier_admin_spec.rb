require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "EnablerBarrierAdmin" do
  let(:singular_resource_name) { "Enabler Barrier" }
  let(:plural_resource_name) { "Enabler Barriers" }
  let(:resource_factory) { :enabler_barrier }
  let(:resource_class) { EnablerBarrier }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
