require "rails_helper"
require "support/devise"
require "support/shared_examples/controllers/concerns/listing_studies"
require "support/shared_examples/controllers/study_management_access_control"

RSpec.describe StudiesController, type: :controller do
  describe "GET #show" do
    let(:study) { FactoryGirl.create(:study) }

    it "returns http success" do
      get :show, id: study.id
      expect(response).to have_http_status(:success)
    end

    it "sets the study" do
      get :show, id: study.id
      expect(assigns[:study]).to eq study
    end

    context "when the study is hidden" do
      before do
        study.hidden = true
        study.save!
      end

      it "is hidden from anonymous users" do
        expect do
          get :show, id: study.id
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "is shown to logged in users" do
        sign_in FactoryGirl.create(:user)
        get :show, id: study.id
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #index" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      get :index, user_id: user.id
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders home/index" do
      expect(response).to render_template("home/index")
    end

    it "sets @show_flagged" do
      expect(assigns[:show_flagged]).to be true
    end

    context "when the user has some principal_investigator studies" do
      let!(:studies) do
        FactoryGirl.create_list(:study, 20, principal_investigator: user)
      end
      let!(:other_studies) do
        FactoryGirl.create_list(:study, 20)
      end

      let(:action) { :index }
      let(:params) { { user_id: user.id } }

      it_behaves_like "study listing controller"

      it "sets @flagged_studies_count" do
        FactoryGirl.create(
          :study,
          study_stage: :delivery,
          protocol_needed: false,
          expected_completion_date: Time.zone.today - 1.day,
          completed: nil,
          principal_investigator: user)
        get action, params
        expect(assigns[:flagged_studies_count]).to eq 1
      end
    end

    context "when the user has some research_manager studies" do
      let!(:studies) do
        FactoryGirl.create_list(:study, 20, research_manager: user)
      end
      let!(:other_studies) do
        FactoryGirl.create_list(:study, 20)
      end

      let(:action) { :index }
      let(:params) { { user_id: user.id } }

      it_behaves_like "study listing controller"

      it "sets @flagged_studies_count" do
        FactoryGirl.create(
          :study,
          study_stage: :delivery,
          protocol_needed: false,
          expected_completion_date: Time.zone.today - 1.day,
          completed: nil,
          research_manager: user)
        get action, params
        expect(assigns[:flagged_studies_count]).to eq 1
      end
    end

    describe "access control" do
      let(:other_user) { FactoryGirl.create(:user) }
      let(:admin_user) { FactoryGirl.create(:admin_user) }

      it "redirects un-authenticated users to login" do
        sign_out :user
        get :index, user_id: user.id
        expect(response).to redirect_to new_user_session_path
      end

      it "allows admin to access any page" do
        sign_out :user
        sign_in admin_user
        get :index, user_id: user.id
        expect(response).to have_http_status(:success)
        get :index, user_id: other_user.id
        expect(response).to have_http_status(:success)
      end

      it "forbids users from accessing other user's pages" do
        get :index, user_id: other_user.id
        expect(response).to have_http_status(403)
      end
    end
  end

  describe "PUT #progress_to_delivery" do
    it_behaves_like "study management action" do
      def trigger_action(study)
        study.study_stage = :protocol_erb
        study.protocol_needed = false
        study.save!
        put :progress_to_delivery, study_id: study.id
      end
    end
  end

  describe "PUT #progress_to_completion" do
    it_behaves_like "study management action" do
      def trigger_action(study)
        study.study_stage = :delivery
        study.protocol_needed = false
        study.save!
        put :progress_to_completion, study_id: study.id
      end
    end
  end
end
