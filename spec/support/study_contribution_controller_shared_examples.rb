RSpec.shared_examples_for "study contribution controller" do
  context "when given valid data" do
    it "creates a resource" do
      expect do
        post :create, valid_attributes
      end.to change { association.count }.by(1)
    end

    it "redirects to the study page" do
      post :create, valid_attributes
      expect(response).to redirect_to(study_path(study))
    end

    it "sets a flash notice" do
      post :create, valid_attributes
      expect(flash[:notice]).to eq expected_success_message
    end
  end

  context "when given invalid data" do
    before do
      post :create, invalid_attributes
    end

    it "renders studies/show" do
      expect(response).to render_template("studies/show")
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
