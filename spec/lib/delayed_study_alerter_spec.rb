require "rails_helper"
require "delayed_study_alerter"

RSpec.shared_examples_for("delayed study alerter") do
  context "when no-ones been alerted before" do
    it "sends emails to the right people" do
      DelayedStudyAlerter.send(action)

      expect(ActionMailer::Base.deliveries.count).to eq 4
      recipients = ActionMailer::Base.deliveries.map { |m| m.to.first }
      expected_recipients = [pi.email, rm.email, admin1.email, admin2.email]
      expect(recipients).to match_array expected_recipients
    end

    it "records who it's sent emails to" do
      DelayedStudyAlerter.send(action)

      expect(SentAlert.count).to eq 4
      [pi, rm, admin1, admin2].each do |user|
        sent_alert = SentAlert.find_by(study: study,
                                       user: user,
                                       alert_type: alert_type)
        expect(sent_alert).not_to be_nil
      end
    end
  end

  context "when everyone's been alerted before" do
    it "doesn't send any more alerts" do
      SentAlert.create(study: study, user: pi, alert_type: alert_type)
      SentAlert.create(study: study, user: rm, alert_type: alert_type)
      SentAlert.create(study: study, user: admin1, alert_type: alert_type)
      SentAlert.create(study: study, user: admin2, alert_type: alert_type)

      expect do
        DelayedStudyAlerter.send(action)
      end.not_to change { SentAlert.count }
    end
  end

  context "when some people have been alerted" do
    it "only alerts those that haven't" do
      SentAlert.create(study: study, user: pi, alert_type: alert_type)
      SentAlert.create(study: study, user: admin1, alert_type: alert_type)

      expect do
        DelayedStudyAlerter.send(action)
      end.to change { SentAlert.count }.by(2)

      [rm, admin2].each do |user|
        sent_alert = SentAlert.find_by(study: study,
                                       user: user,
                                       alert_type: alert_type)
        expect(sent_alert).not_to be_nil
      end
    end
  end

  context "when an admin is also a pi" do
    it "doesn't send them an email twice" do
      study.principal_investigator = admin1
      study.save!
      DelayedStudyAlerter.send(action)

      expect(ActionMailer::Base.deliveries.count).to eq 3
      recipients = ActionMailer::Base.deliveries.map { |m| m.to.first }
      expected_recipients = [rm.email, admin1.email, admin2.email]
      expect(recipients).to match_array expected_recipients
    end
  end
end

RSpec.describe DelayedStudyAlerter, type: :mailer do
  let!(:pi) { FactoryGirl.create(:user) }
  let!(:rm) { FactoryGirl.create(:user) }
  let!(:admin1) { FactoryGirl.create(:admin_user) }
  let!(:admin2) { FactoryGirl.create(:admin_user) }

  before do
    # Creating users sends emails, so clear those out first
    ActionMailer::Base.deliveries = []
  end

  describe "#alert_delayed_completing" do
    let!(:study) do
      FactoryGirl.create(
        :study,
        principal_investigator: pi,
        research_manager: rm,
        expected_completion_date: Time.zone.today - 1.day)
    end
    let(:alert_type) { SentAlert::DELAYED_COMPLETING }
    let(:action) { :alert_delayed_completing }

    it_behaves_like "delayed study alerter"
  end

  describe "#alert_approval_expiring" do
    let(:accept) { FactoryGirl.create(:accept) }
    let!(:study) do
      FactoryGirl.create(
        :study,
        principal_investigator: pi,
        research_manager: rm,
        study_stage: :delivery,
        erb_status: accept,
        erb_approval_expiry: Time.zone.today - 1.day)
    end
    let(:alert_type) { SentAlert::APPROVAL_EXPIRING }
    let(:action) { :alert_approval_expiring }

    it_behaves_like "delayed study alerter"
  end

  describe "#alert_response_overdue" do
    let(:submitted) { ErbStatus.find_by_name("Submitted") }
    let!(:study) do
      FactoryGirl.create(
        :study,
        principal_investigator: pi,
        research_manager: rm,
        erb_status: submitted,
        local_erb_submitted: Time.zone.today - 4.months)
    end
    let(:alert_type) { SentAlert::RESPONSE_OVERDUE }
    let(:action) { :alert_response_overdue }

    it_behaves_like "delayed study alerter"
  end
end
