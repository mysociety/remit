require "support/devise"

RSpec.shared_examples_for "study contribution controller" do
  before do
    sign_in pi
  end

  context "when given valid data" do
    it "creates a resource" do
      expect do
        post :create, valid_attributes
      end.to change { association.count }.by(1)
    end

    it "sets a flash notice" do
      post :create, valid_attributes
      expect(flash[:success]).to eq expected_success_message
    end

    it "assigns the user to the resource" do
      post :create, valid_attributes
      expect(association.last.user).to eq pi
    end
  end

  context "when given invalid data" do
    before do
      post :create, invalid_attributes
    end

    it "renders the expected template" do
      expect(response).to render_template(expected_error_template)
    end

    it "sets a flash alert" do
      expected_alert = "Sorry, looks like we're missing something, can you " \
                       "double check?"
      expect(flash[:alert]).to eq expected_alert
    end

    it "sets @study" do
      expect(assigns[:study]).to eq study
    end

    it "sets resource variable with errors" do
      expect(assigns[resource_name]).not_to be nil
      expect(assigns[resource_name].errors).not_to be_empty
    end
  end
end
