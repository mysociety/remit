require "rails_helper"
require "support/user_account_feature_helper"
require "support/simple_model_admin_shared_examples"

RSpec.describe "DocumentTypeAdmin" do
  let(:singular_resource_name) { "Document Type" }
  let(:plural_resource_name) { "Document Types" }
  let(:resource_factory) { :document_type }
  let(:resource_class) { DocumentType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
