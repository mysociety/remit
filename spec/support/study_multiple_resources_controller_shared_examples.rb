RSpec.shared_examples_for(
  "multiple resources controller when creating one resource") do
  context "when given valid data" do
    it "creates a resource" do
      expect do
        post action, valid_attributes
      end.to change { association.count }.by(1)
    end

    it "redirects to the study page" do
      post action, valid_attributes
      expect(response).to redirect_to(study_path(study))
    end

    it "sets a flash notice" do
      post action, valid_attributes
      expect(flash[:notice]).to eq expected_success_message
    end

    context "when a user is logged in" do
      before do
        sign_in user
      end

      it "assigns the user to the resource" do
        post action, valid_attributes
        expect(association.last.user).to eq user
      end
    end

    context "when no user is logged in" do
      before do
        sign_out :user
      end

      it "assigns no user to the resource" do
        post action, valid_attributes
        expect(association.last.user).to be_nil
      end
    end
  end

  context "when given invalid data" do
    before do
      post action, invalid_attributes
    end

    it "renders studies/show" do
      expect(response).to render_template("studies/show")
    end

    it "sets a flash alert" do
      expected_alert = "Sorry, looks like we're missing something, " \
                       "can you double check?"
      expect(flash[:alert]).to eq expected_alert
    end

    it "sets @study" do
      expect(assigns[:study]).to eq study
    end

    it "sets resource variable with errors" do
      expect(assigns[resource_name]).not_to be nil
      assigns[resource_name].values.each do |resource|
        expect(resource.errors).not_to be_empty
      end
    end
  end

  context "when given no data" do
    before do
      post action, empty_attributes
    end

    it "renders studies/show" do
      expect(response).to render_template("studies/show")
    end

    it "sets a flash alert" do
      expect(flash[:alert]).to eq expected_empty_alert
    end

    it "sets resource variable with errors" do
      expect(assigns[resource_name]).not_to be nil
      assigns[resource_name].values.each do |resource|
        expect(resource.errors).not_to be_empty
      end
    end
  end
end

RSpec.shared_examples_for(
  "multiple resources controller when creating two resources") do
  context "when given valid data" do
    it "creates two resources" do
      expect do
        post action, valid_attributes
      end.to change { association.count }.by(2)
    end

    it "redirects to the study page" do
      post action, valid_attributes
      expect(response).to redirect_to(study_path(study))
    end

    it "sets a flash notice" do
      post action, valid_attributes
      expect(flash[:notice]).to eq expected_success_message
    end

    context "when a user is logged in" do
      before do
        sign_in user
      end

      it "assigns the user to the resources" do
        post action, valid_attributes
        expect(association.last.user).to eq user
        expect(association[-2].user).to eq user
      end
    end

    context "when no user is logged in" do
      before do
        sign_out :user
      end

      it "assigns no user to the resource" do
        post action, valid_attributes
        expect(association.last.user).to be_nil
        expect(association[-2].user).to be nil
      end
    end
  end

  context "when given invalid data" do
    before do
      post action, invalid_attributes
    end

    it "renders studies/show" do
      expect(response).to render_template("studies/show")
    end

    it "sets a flash alert" do
      expected_alert = "Sorry, looks like we're missing something, " \
                       "can you double check?"
      expect(flash[:alert]).to eq expected_alert
    end

    it "sets @study" do
      expect(assigns[:study]).to eq study
    end

    it "sets resource variable with errors" do
      expect(assigns[resource_name]).not_to be nil
      resource = assigns[resource_name][invalid_id]
      expect(resource.errors).not_to be_empty
      resource = assigns[resource_name][valid_id]
      expect(resource.errors).to be_empty
    end

    it "doesn't create any resources" do
      # One of the impacts is valid, but we should do everything in a
      # transaction and not create any if one fails
      expect do
        post action, invalid_attributes
      end.not_to change { association.count }
    end
  end
end
