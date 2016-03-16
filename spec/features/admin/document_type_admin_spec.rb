require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/shared_examples/features/simple_model_admins"

RSpec.describe "DocumentTypeAdmin" do
  let(:singular_resource_name) { "Document Type" }
  let(:plural_resource_name) { "Document Types" }
  let(:resource_factory) { :document_type }
  let(:resource_class) { DocumentType }

  def fill_in_extra_required_fields
  end

  it_behaves_like "simple model admin"
end
