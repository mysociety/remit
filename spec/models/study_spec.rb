require "rails_helper"
require "support/matchers/have_latest_activity"

RSpec.describe Study, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_stage_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:title).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:reference_number).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:study_type_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:study_setting_id).of_type(:integer).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:research_team).of_type(:text) }
  it do
    is_expected.to have_db_column(:concept_paper_date).of_type(:date).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:protocol_needed).of_type(:boolean).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:pre_approved_protocol).of_type(:boolean)
  end
  it { is_expected.to have_db_column(:erb_status_id).of_type(:integer) }
  it { is_expected.to have_db_column(:erb_reference).of_type(:text) }
  it { is_expected.to have_db_column(:erb_approval_expiry).of_type(:date) }
  it { is_expected.to have_db_column(:local_erb_submitted).of_type(:date) }
  it { is_expected.to have_db_column(:local_erb_approved).of_type(:date) }
  it { is_expected.to have_db_column(:completed).of_type(:date) }
  it { is_expected.to have_db_column(:local_collaborators).of_type(:text) }
  it do
    is_expected.to have_db_column(:international_collaborators).of_type(:text)
  end
  it { is_expected.to have_db_column(:other_study_type).of_type(:text) }
  it do
    is_expected.to have_db_column(:principal_investigator_id).of_type(:integer)
  end
  it { is_expected.to have_db_column(:research_manager_id).of_type(:integer) }
  it { is_expected.to have_db_column(:country_code).of_type(:text) }
  it { is_expected.to have_db_column(:feedback_and_suggestions).of_type(:text) }
  it do
    is_expected.to have_db_column(:study_topic_id).of_type(:integer).
      with_options(null: false)
  end

  # Associations
  it { is_expected.to belong_to(:study_stage) }
  it { is_expected.to belong_to(:study_type) }
  it { is_expected.to belong_to(:study_topic) }
  it { is_expected.to belong_to(:study_setting) }
  it { is_expected.to belong_to(:erb_status) }
  it { is_expected.to have_and_belong_to_many(:enabler_barriers) }
  it { is_expected.to belong_to(:principal_investigator).class_name(:User) }
  it { is_expected.to belong_to(:research_manager).class_name(:User) }
  it { is_expected.to have_many(:study_impacts) }
  it { is_expected.to have_many(:disseminations) }
  it { is_expected.to have_many(:publications) }
  it { is_expected.to have_many(:study_notes) }

  # Validation
  it { is_expected.to validate_presence_of(:study_stage) }
  it { is_expected.to validate_presence_of(:study_setting) }
  it { is_expected.to validate_presence_of(:study_type) }
  it { is_expected.to validate_presence_of(:study_topic) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:reference_number) }
  it { is_expected.to validate_presence_of(:concept_paper_date) }
  it do
    is_expected.to validate_inclusion_of(:protocol_needed).
      in_array([true, false])
  end

  context "when the when study_type field is 'Other'" do
    let(:study) { FactoryGirl.build(:study) }
    let(:other_study_type) { StudyType.find_by_name("Other") }

    it "should be invalid when the other_study_type field is nil" do
      study.study_type = other_study_type
      study.other_study_type = nil
      expect(study).to be_invalid
    end

    it "should be invalid when the other_study_type field is empty" do
      study.study_type = other_study_type
      study.other_study_type = ""
      expect(study).to be_invalid
    end

    it "should be valid when we set the other_study_type field" do
      study.study_type = other_study_type
      study.other_study_type = "some other type"
      expect(study).to be_valid
    end
  end

  describe "activity log" do
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
    end

    after do
      PublicActivity.enabled = false
    end

    context "when a study is created" do
      it "creates a 'created' log entry" do
        expect(study.reload.activities.first.key).to eq "study.created"
      end

      it "only creates one log entry" do
        expect(study.reload.activities.length).to eq 1
      end
    end

    context "given an existing study" do
      let(:protocol_stage) { FactoryGirl.create(:protocol_stage) }
      let(:accept_status) { FactoryGirl.create(:accept) }
      let(:pi) { FactoryGirl.create(:user) }
      let(:rm) { FactoryGirl.create(:user) }

      it "doesn't create any activities when nothing changes" do
        study.save!
        expect(study.reload.activities.length).to eq 1
      end

      it "logs changes to the title" do
        old_title = study.title
        study.title = "Some new title"
        study.save!
        study.reload
        expect(study.activities.length).to eq 2
        expect(study).to have_latest_activity("study.title_changed",
                                              attribute: "title",
                                              before: old_title,
                                              after: study.title)
      end

      it "logs changes to the study stage" do
        old_stage = study.study_stage
        study.study_stage = protocol_stage
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity("study.study_stage_id_changed",
                                              attribute: "study_stage_id",
                                              before: old_stage.id,
                                              after: protocol_stage.id)
      end

      it "logs changes to the erb status" do
        study.erb_status = accept_status
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity("study.erb_status_id_changed",
                                              attribute: "erb_status_id",
                                              before: nil,
                                              after: accept_status.id)
      end

      it "logs changes to the principal investigator" do
        study.principal_investigator = pi
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          "study.principal_investigator_id_changed",
          attribute: "principal_investigator_id",
          before: nil,
          after: pi.id)
      end

      it "logs changes to the research manager" do
        study.research_manager = rm
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          "study.research_manager_id_changed",
          attribute: "research_manager_id",
          before: nil,
          after: rm.id)
      end

      it "logs changes to the local erb approved date" do
        study.local_erb_approved = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          "study.local_erb_approved_changed",
          attribute: "local_erb_approved",
          before: nil,
          after: Date.new(2015, 1, 1))
      end

      it "logs changes to the local erb submitted date" do
        study.local_erb_submitted = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          "study.local_erb_submitted_changed",
          attribute: "local_erb_submitted",
          before: nil,
          after: Date.new(2015, 1, 1))
      end

      it "logs changes to the completed date" do
        study.completed = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity("study.completed_changed",
                                              attribute: "completed",
                                              before: nil,
                                              after: Date.new(2015, 1, 1))
      end

      it "creates separate log entries for multiple changes at once" do
        old_title = study.title
        study.title = "Some new title"
        study.erb_status = accept_status
        study.save!
        expect(study.reload.activities.length).to eq 3
        activities = study.reload.activities.last(2)

        expect(activities[0].key).to eq "study.title_changed"
        expect(activities[0].parameters[:attribute]).to eq "title"
        expect(activities[0].parameters[:before]).to eq old_title
        expect(activities[0].parameters[:after]).to eq study.title

        expect(activities[1].key).to eq "study.erb_status_id_changed"
        expect(activities[1].parameters[:attribute]).to eq "erb_status_id"
        expect(activities[1].parameters[:before]).to eq nil
        expect(activities[1].parameters[:after]).to eq accept_status.id
      end
    end
  end
end
