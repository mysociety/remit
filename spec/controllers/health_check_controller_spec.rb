require "rails_helper"

RSpec.describe HealthCheckController, type: :controller do
  describe "delayed study alerts health check" do
    it "returns true if there are no delayed studies" do
      get :index
      result = assigns[:checks]["Delayed studies have been alerted"]
      expect(result).to be true
    end

    it "returns true if there are delayed studies which have been alerted" do
      study = FactoryGirl.create(:delayed_completing_study)
      FactoryGirl.create(:delayed_completing, study: study)
      get :index
      result = assigns[:checks]["Delayed studies have been alerted"]
      expect(result).to be true
    end

    it "returns false if delayed studies haven't been alerted" do
      FactoryGirl.create(:delayed_completing_study)
      get :index
      result = assigns[:checks]["Delayed studies have been alerted"]
      expect(result).to be false
    end

    it "ignores other sent alerts for the study" do
      study = FactoryGirl.create(:delayed_completing_study)
      FactoryGirl.create(:erb_approval_expiring, study: study)
      FactoryGirl.create(:erb_response_overdue, study: study)
      get :index
      result = assigns[:checks]["Delayed studies have been alerted"]
      expect(result).to be false
    end

    it "gives delayed studies a day's grace" do
      FactoryGirl.create(
        :study,
        expected_completion_date: Time.zone.today
      )
      get :index
      result = assigns[:checks]["Delayed studies have been alerted"]
      expect(result).to be true
    end
  end

  describe "erb approval expiring alerts health check" do
    it "returns true if there are no expiring studies" do
      get :index
      result = assigns[:checks]["Approval expiring studies have been alerted"]
      expect(result).to be true
    end

    it "returns true if there are expiring studies which have been alerted" do
      study = FactoryGirl.create(:erb_approval_expiring_study)
      FactoryGirl.create(:erb_approval_expiring, study: study)
      get :index
      result = assigns[:checks]["Approval expiring studies have been alerted"]
      expect(result).to be true
    end

    it "returns false if expiring studies haven't been alerted" do
      FactoryGirl.create(:erb_approval_expiring_study)
      get :index
      result = assigns[:checks]["Approval expiring studies have been alerted"]
      expect(result).to be false
    end

    it "ignores other sent alerts for the study" do
      study = FactoryGirl.create(:erb_approval_expiring_study)
      FactoryGirl.create(:delayed_completing, study: study)
      FactoryGirl.create(:erb_response_overdue, study: study)
      get :index
      result = assigns[:checks]["Approval expiring studies have been alerted"]
      expect(result).to be false
    end

    it "gives expiring studies a day's grace" do
      FactoryGirl.create(
        :study,
        erb_approval_expiry: Study.erb_approval_expiry_warning_at
      )
      get :index
      result = assigns[:checks]["Approval expiring studies have been alerted"]
      expect(result).to be true
    end
  end

  describe "erb response overdue alerts health check" do
    it "returns true if there are no overdue studies" do
      get :index
      result = assigns[:checks]["Response overdue studies have been alerted"]
      expect(result).to be true
    end

    it "returns true if there are overdue studies which have been alerted" do
      study = FactoryGirl.create(:erb_response_overdue_study)
      FactoryGirl.create(:erb_response_overdue, study: study)
      get :index
      result = assigns[:checks]["Response overdue studies have been alerted"]
      expect(result).to be true
    end

    it "returns false if overdue studies haven't been alerted" do
      FactoryGirl.create(:erb_response_overdue_study)
      get :index
      result = assigns[:checks]["Response overdue studies have been alerted"]
      expect(result).to be false
    end

    it "ignores other sent alerts for the study" do
      study = FactoryGirl.create(:erb_response_overdue_study)
      FactoryGirl.create(:delayed_completing, study: study)
      FactoryGirl.create(:erb_approval_expiring, study: study)
      get :index
      result = assigns[:checks]["Response overdue studies have been alerted"]
      expect(result).to be false
    end

    it "gives overdue studies a day's grace" do
      FactoryGirl.create(
        :study,
        erb_submitted: Study.erb_response_overdue_at
      )
      get :index
      result = assigns[:checks]["Response overdue studies have been alerted"]
      expect(result).to be true
    end
  end

  describe "summarising health checks" do
    it "returns a 200 when all the checks are healthy" do
      delayed_study = FactoryGirl.create(:delayed_completing_study)
      expiring_study = FactoryGirl.create(:erb_approval_expiring_study)
      overdue_study = FactoryGirl.create(:erb_response_overdue_study)
      FactoryGirl.create(:delayed_completing, study: delayed_study)
      FactoryGirl.create(:erb_approval_expiring, study: expiring_study)
      FactoryGirl.create(:erb_response_overdue, study: overdue_study)
      get :index
      expect(response.status).to eq 200
    end

    it "returns a 500 when any check is unhealthy" do
      FactoryGirl.create(:delayed_completing_study)
      expiring_study = FactoryGirl.create(:erb_approval_expiring_study)
      overdue_study = FactoryGirl.create(:erb_response_overdue_study)
      # No corresponding alert for the delayed study
      FactoryGirl.create(:erb_approval_expiring, study: expiring_study)
      FactoryGirl.create(:erb_response_overdue, study: overdue_study)
      get :index
      expect(response.status).to eq 500
    end
  end
end
