require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "DeliveryUpdateStatusAdmin" do
  let(:singular_resource_name) { "Delivery Update Status" }
  let(:plural_resource_name) { "Delivery Update Statuses" }
  let(:resource_factory) { :delivery_update_status }
  let(:resource_class) { DeliveryUpdateStatus }

  def fill_in_extra_required_fields
    select "good", from: "Good medium bad or neutral"
  end

  it_behaves_like "simple model admin"
end
