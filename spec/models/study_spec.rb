require "rails_helper"
require "support/matchers/have_latest_activity"
require "support/matchers/match_activity"

RSpec.describe Study, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_stage).of_type(:enum).
      with_options(null: false, default: "concept")
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
      with_options(null: true)
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
  it { is_expected.to have_db_column(:country_codes).of_type(:text) }
  it { is_expected.to have_db_column(:feedback_and_suggestions).of_type(:text) }

  # Associations
  it { is_expected.to belong_to(:study_type) }
  it { is_expected.to belong_to(:study_setting) }
  it { is_expected.to belong_to(:erb_status) }
  it { is_expected.to belong_to(:principal_investigator).class_name(:User) }
  it { is_expected.to belong_to(:research_manager).class_name(:User) }
  it { is_expected.to have_and_belong_to_many(:study_topics) }
  it { is_expected.to have_many(:study_enabler_barriers) }
  it { is_expected.to have_many(:study_impacts) }
  it { is_expected.to have_many(:disseminations) }
  it { is_expected.to have_many(:publications) }
  it { is_expected.to have_many(:study_notes) }

  # Validation
  it { is_expected.to validate_presence_of(:study_stage) }
  it { is_expected.to validate_presence_of(:study_setting) }
  it { is_expected.to validate_presence_of(:study_type) }
  it { is_expected.to validate_presence_of(:study_topics) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:reference_number) }
  it do
    is_expected.to validate_inclusion_of(:protocol_needed).
      in_array([true, false])
  end
  it do
    enum_options = {
      concept: "concept",
      protocol_erb: "protocol_erb",
      delivery: "delivery",
      output: "output",
      completion: "completion",
      withdrawn_postponed: "withdrawn_postponed",
    }
    is_expected.to define_enum_for(:study_stage).with(enum_options)
  end

  context "when erb_status_needed? is true" do
    let(:study) do
      FactoryGirl.build(:study, protocol_needed: true,
                                study_stage: :protocol_erb)
    end

    it "validates the presence of erb_status" do
      study.erb_status = nil
      expect(study).to be_invalid
    end
  end

  context "when erb_status_needed? is false" do
    let(:erb_status) { FactoryGirl.create(:submitted) }
    let(:study) do
      FactoryGirl.build(:study, protocol_needed: false,
                                study_stage: :protocol_erb)
    end

    it "doesn't validate the presence of erb_status" do
      study.erb_status = erb_status
      expect(study).to be_valid
    end
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

  describe "#country_codes=" do
    let(:study) { FactoryGirl.build(:study) }

    it "lets you set a list of country codes" do
      study.country_codes = %w(GB BD)
      expect(study[:country_codes]).to eq "GB,BD"
    end
  end

  describe "#country_codes" do
    let(:study) { FactoryGirl.build(:study) }

    it "returns a list of country codes" do
      study[:country_codes] = "GB,BD"
      expect(study.country_codes).to eq %w(GB BD)
    end
  end

  describe "#countries" do
    let(:study) { FactoryGirl.build(:study) }

    it "returns a list of ISO3166 countries" do
      study.country_codes = %w(GB BD)
      expect(study.countries).to eq [ISO3166::Country.new("GB"),
                                     ISO3166::Country.new("BD")]
    end

    it "returns nil for an unknown ISO3166 country name" do
      study.country_codes = %w(XX)
      expect(study.countries).to eq nil
    end

    it "returns nil when country_codes is nil" do
      expect(study.countries).to eq nil
    end

    it "returns nil when country_codes is empty" do
      study.country_codes = []
      expect(study.countries).to eq nil
    end
  end

  describe "#country_names" do
    let(:study) { FactoryGirl.build(:study) }

    it "returns a sentence of ISO3166 country names" do
      study.country_codes = %w(GB BD)
      expect(study.country_names).to eq "United Kingdom and Bangladesh"
    end

    it "returns nil for an unknown ISO3166 country name" do
      study.country_codes = %w(XX)
      expect(study.country_names).to eq nil
    end

    it "returns nil when country_codes is nil" do
      expect(study.country_names).to eq nil
    end

    it "returns nil when country_codes is empty" do
      study.country_codes = []
      expect(study.country_names).to eq nil
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
        expect(study).to have_latest_activity(key: "study.created")
      end

      it "only creates one log entry" do
        expect(study.reload.activities.length).to eq 1
      end
    end

    context "given an existing study" do
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
        expect(study).to have_latest_activity(key: "study.title_changed",
                                              parameters: {
                                                attribute: "title",
                                                before: old_title,
                                                after: study.title
                                              })
      end

      it "logs changes to the study stage" do
        old_stage = study.study_stage
        # erb_status is required in this stage too
        study.erb_status = accept_status
        study.save!
        study.study_stage = :protocol_erb
        study.save!
        expect(study.reload.activities.length).to eq 3 # create, stage and erb
        expect(study).to have_latest_activity(key: "study.study_stage_changed",
                                              parameters: {
                                                attribute: "study_stage",
                                                before: old_stage,
                                                after: "protocol_erb"
                                              })
      end

      it "logs changes to the erb status" do
        study.erb_status = accept_status
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.erb_status_id_changed",
          parameters: {
            attribute: "erb_status_id",
            before: nil,
            after: accept_status.id
          })
      end

      it "logs changes to the principal investigator" do
        study.principal_investigator = pi
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.principal_investigator_id_changed",
          parameters: {
            attribute: "principal_investigator_id",
            before: nil,
            after: pi.id
          },
          recipient: pi)
      end

      it "logs changes to the research manager" do
        study.research_manager = rm
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.research_manager_id_changed",
          parameters: {
            attribute: "research_manager_id",
            before: nil,
            after: rm.id
          },
          recipient: rm)
      end

      it "logs changes to the local erb approved date" do
        study.local_erb_approved = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.local_erb_approved_changed",
          parameters: {
            attribute: "local_erb_approved",
            before: nil,
            after: Date.new(2015, 1, 1)
          })
      end

      it "logs changes to the local erb submitted date" do
        study.local_erb_submitted = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.local_erb_submitted_changed",
          parameters: {
            attribute: "local_erb_submitted",
            before: nil,
            after: Date.new(2015, 1, 1)
          })
      end

      it "logs changes to the completed date" do
        study.completed = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(key: "study.completed_changed",
                                              parameters: {
                                                attribute: "completed",
                                                before: nil,
                                                after: Date.new(2015, 1, 1)
                                              })
      end

      it "creates separate log entries for multiple changes at once" do
        old_title = study.title
        study.title = "Some new title"
        study.erb_status = accept_status
        study.save!
        expect(study.reload.activities.length).to eq 3
        activities = study.reload.activities.last(2)

        expect(activities[0]).to match_activity(key: "study.title_changed",
                                                parameters: {
                                                  attribute: "title",
                                                  before: old_title,
                                                  after: study.title
                                                })

        expect(activities[1]).to match_activity(
          key: "study.erb_status_id_changed",
          parameters: {
            attribute: "erb_status_id",
            before: nil,
            after: accept_status.id
          })
      end
    end
  end

  describe "#latest_stage_change" do
    let(:accept_status) { FactoryGirl.create(:accept) }
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
    end

    after do
      PublicActivity.enabled = false
    end

    it "returns nil when there's been no stage change" do
      expect(study.latest_stage_change).to be nil
    end

    it "returns the latest stage change" do
      study.study_stage = "protocol_erb"
      study.erb_status = accept_status
      study.save!
      study.study_stage = "delivery"
      study.save!

      change = study.latest_stage_change
      expect(change).to match_activity(key: "study.study_stage_changed",
                                       parameters: {
                                         attribute: "study_stage",
                                         before: "protocol_erb",
                                         after: "delivery",
                                       })
    end
  end

  describe "#study_stage_since" do
    let(:accept_status) { FactoryGirl.create(:accept) }
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
    end

    after do
      PublicActivity.enabled = false
    end

    it "returns created_at when there's been no stage change" do
      expect(study.study_stage_since).to eq study.created_at
    end

    it "returns the time of the latest study change" do
      study.study_stage = "protocol_erb"
      study.erb_status = accept_status
      study.save!
      study.study_stage = "delivery"
      study.save!

      latest_change = study.latest_stage_change
      expect(study.study_stage_since).to eq latest_change.created_at
    end
  end

  describe "#title_changed?" do
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
    end

    after do
      PublicActivity.enabled = false
    end

    context "when the title has changed" do
      before do
        study.title = "Some new title"
        study.save!
      end

      it "returns true" do
        expect(study.title_changed?).to be true
      end
    end

    context "when the title hasn't changed" do
      it "returns false" do
        expect(study.title_changed?).to be false
      end
    end
  end

  describe "#original_title?" do
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
    end

    after do
      PublicActivity.enabled = false
    end

    context "when the title has changed" do
      let!(:original_title) { study.title }

      before do
        study.title = "Some new title"
        study.save!
      end

      it "returns the original title" do
        expect(study.original_title).to eq original_title
      end
    end

    context "when the title hasn't changed" do
      let!(:original_title) { study.title }

      it "returns the current title" do
        expect(study.original_title).to eq original_title
      end
    end
  end

  describe "#erb_status_needed?" do
    context "when protocol_needed is true" do
      let(:study) { FactoryGirl.build(:study, protocol_needed: true) }

      context "and study_stage is concept" do
        it "returns false" do
          study.study_stage = :concept
          expect(study.erb_status_needed?).to be false
        end
      end

      context "and study_stage is withdrawn_postponed" do
        it "returns false" do
          study.study_stage = :withdrawn_postponed
          expect(study.erb_status_needed?).to be false
        end
      end

      context "and study_stage is anything else" do
        it "returns true" do
          stages = Study.study_stages.keys
          stages = stages.delete_if do |stage|
            stage == "concept" || stage == "withdrawn_postponed"
          end
          stages.each do |stage|
            study.study_stage = stage
            expect(study.erb_status_needed?).to be true
          end
        end
      end
    end

    context "when protocol_needed is false" do
      let(:study) { FactoryGirl.build(:study, protocol_needed: false) }

      it "returns false for every stage" do
        Study.study_stages.keys.each do |stage|
          study.study_stage = stage
          expect(study.erb_status_needed?).to be false
        end
      end
    end
  end
end
