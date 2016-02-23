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
  it { is_expected.to have_db_column(:erb_submitted).of_type(:date) }
  it { is_expected.to have_db_column(:erb_approved).of_type(:date) }
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
  it { is_expected.to have_db_column(:expected_completion_date).of_type(:date) }
  it do
    is_expected.to have_db_column(:hidden).of_type(:boolean).
      with_options(default: false)
  end

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
  it { is_expected.to have_many(:sent_alerts) }
  it { is_expected.to have_many(:study_invites).inverse_of(:study) }
  it { is_expected.to have_many(:invited_users).through(:study_invites) }

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
    let(:study) do
      FactoryGirl.build(:study, protocol_needed: false,
                                study_stage: :protocol_erb)
    end

    it "doesn't validate the presence of erb_status" do
      study.erb_status = nil
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

    # https://github.com/mysociety/remit/issues/99 - it was possible to set
    # duplicate country codes from the admin because we have a helpful list of
    # common countries in the country select that are extra to the normal list
    # and so get selected twice if you re-save a study with one of them.
    it "only saves a unique set of codes" do
      study.country_codes = %w(GB BD GB)
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
          },
          related_content: accept_status)
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

      it "logs changes to the erb approved date" do
        study.erb_approved = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.erb_approved_changed",
          parameters: {
            attribute: "erb_approved",
            before: nil,
            after: Date.new(2015, 1, 1)
          })
      end

      it "logs changes to the erb submitted date" do
        study.erb_submitted = Date.new(2015, 1, 1)
        study.save!
        expect(study.reload.activities.length).to eq 2
        expect(study).to have_latest_activity(
          key: "study.erb_submitted_changed",
          parameters: {
            attribute: "erb_submitted",
            before: nil,
            after: Date.new(2015, 1, 1)
          })
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

  describe "#active" do
    let(:active_studies) do
      [
        FactoryGirl.create(:study, study_stage: :delivery,
                                   protocol_needed: false),
        FactoryGirl.create(:study, study_stage: :completion,
                                   protocol_needed: false,
                                   completed: Time.zone.today),
        FactoryGirl.create(:study, study_stage: :completion,
                                   protocol_needed: false,
                                   completed: Time.zone.today - 1.year)
      ]
    end

    let(:inactive_studies) do
      [
        FactoryGirl.create(:study),
        FactoryGirl.create(:study, study_stage: protocol_needed,
                                   protocol_needed: false),
        FactoryGirl.create(:study, study_stage: :completion,
                                   protocol_needed: false,
                                   completed: Time.zone.today - 366.days),
        FactoryGirl.create(:study, study_stage: :withdrawn_postponed)
      ]
    end

    it "returns active studies" do
      expect(Study.active).to match_array(active_studies)
    end
  end

  describe "#impactful_count" do
    before do
      # Make some studies active
      studies = FactoryGirl.create_list(:study, 5)

      # Create some impact
      FactoryGirl.create(:publication, study: studies.first)
      FactoryGirl.create(:dissemination, study: studies.first)
      FactoryGirl.create(:study_impact, study: studies.first)
      FactoryGirl.create(:dissemination, study: studies.second)
      FactoryGirl.create(:publication, study: studies.second)
      FactoryGirl.create(:study_impact, study: studies.third)
    end

    it "returns the count of impactful studies" do
      expect(Study.impactful_count).to eq 3
    end
  end

  describe "archiving studies" do
    let(:archive_date) { Time.zone.today - 1.year }
    let!(:on_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date,
                                 protocol_needed: false)
    end
    let!(:older_than_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date - 1.day,
                                 protocol_needed: false)
    end
    let!(:younger_than_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date + 1.day,
                                 protocol_needed: false)
    end
    let!(:completed_but_not_in_right_stage) do
      # Some of the existing data has a completion date but the study is still
      # marked as being in delivery
      FactoryGirl.create(:study, study_stage: :delivery,
                                 completed: archive_date - 1.day,
                                 protocol_needed: false)
    end
    let!(:not_archived) do
      # Make one of every other stage to check they're excluded too
      stages = Study.study_stages.keys
      stages.delete("completion")
      not_archived = []
      stages.each do |stage|
        not_archived << FactoryGirl.create(:study, study_stage: stage,
                                                   protocol_needed: false)
      end
      not_archived << on_archive_date
      not_archived << younger_than_archive_date
      not_archived << completed_but_not_in_right_stage
      not_archived
    end

    describe "#archived" do
      it "only returns archived studies" do
        expect(Study.archived).to match_array([older_than_archive_date])
      end
    end

    describe "#not_archived" do
      it "only returns non-archived studies" do
        expect(Study.not_archived).to match_array(not_archived)
      end
    end

    describe "#archived?" do
      context "when a study is archived" do
        it "returns true" do
          expect(older_than_archive_date.archived?).to be true
        end
      end

      context "when a study is not archived" do
        it "returns false" do
          not_archived.each do |study|
            expect(study.archived?).to be false
          end
        end
      end
    end
  end

  describe "#not_withdrawn" do
    let!(:withdrawn) do
      FactoryGirl.create(:study, study_stage: :withdrawn_postponed)
    end
    let!(:not_withdrawn) do
      # Make one of every other stage to check they're excluded too
      stages = Study.study_stages.keys
      stages.delete("withdrawn_postponed")
      not_withdrawn = []
      stages.each do |stage|
        not_withdrawn << FactoryGirl.create(:study, study_stage: stage,
                                                    protocol_needed: false)
      end
      not_withdrawn
    end

    it "only returns non-withdrawn studies" do
      expect(Study.not_withdrawn).to match_array(not_withdrawn)
    end
  end

  describe "#not_archived_or_withdrawn" do
    let(:archive_date) { Time.zone.today - 1.year }
    let!(:on_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date,
                                 protocol_needed: false)
    end
    let!(:older_than_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date - 1.day,
                                 protocol_needed: false)
    end
    let!(:younger_than_archive_date) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 completed: archive_date + 1.day,
                                 protocol_needed: false)
    end
    let!(:withdrawn) do
      FactoryGirl.create(:study, study_stage: :withdrawn_postponed)
    end
    let!(:not_archived_or_withdrawn) do
      # Make one of every other stage to check they're excluded too
      stages = Study.study_stages.keys
      stages.delete("completion")
      stages.delete("withdrawn_postponed")
      not_archived_or_withdrawn = []
      stages.each do |stage|
        study = FactoryGirl.create(:study, study_stage: stage,
                                           protocol_needed: false)
        not_archived_or_withdrawn << study
      end
      not_archived_or_withdrawn << on_archive_date
      not_archived_or_withdrawn << younger_than_archive_date
      not_archived_or_withdrawn
    end

    it "only returns not archived or withdrawn studies" do
      expect(Study.not_archived_or_withdrawn).to(
        match_array(not_archived_or_withdrawn))
    end
  end

  describe "#delayed_completing and delayed_completing?" do
    let(:today) { Time.zone.today }

    let!(:delayed) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today - 1.day,
                                 completed: nil)
    end

    let!(:used_to_be_delayed) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today - 1.day,
                                 completed: today)
    end

    let!(:not_yet_delayed) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today + 1.day,
                                 completed: nil)
    end

    let!(:on_threshold) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today,
                                 completed: nil)
    end

    let!(:no_expected_date) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: nil,
                                 completed: nil)
    end

    describe "#delayed_completing" do
      it "only returns delayed studies" do
        expect(Study.delayed_completing).to match_array([delayed])
      end
    end

    describe "#delayed_completing?" do
      it "returns true for delayed studies" do
        expect(delayed.delayed_completing?).to be true
      end

      it "returns false otherwise" do
        expect(used_to_be_delayed.delayed_completing?).to be false
        expect(not_yet_delayed.delayed_completing?).to be false
        expect(on_threshold.delayed_completing?).to be false
        expect(no_expected_date.delayed_completing?).to be false
      end
    end
  end

  describe "#erb_approval_expiring and erb_approval_expiring?" do
    let(:today) { Time.zone.today }
    let(:threshold) { today + 1.month }
    let(:inside_threshold) { threshold - 1.day }
    let(:outside_threshold) { threshold + 1.day }
    let(:accept) { FactoryGirl.create(:accept) }

    let!(:expired) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: today - 1.day)
    end

    let!(:on_warning_threshold) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: threshold)
    end

    let!(:expiring_inside_threshold) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 erb_status: accept,
                                 erb_approval_expiry: inside_threshold)
    end

    let!(:expiring_outside_threshold) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: outside_threshold)
    end

    let!(:no_expiry) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: nil)
    end

    let!(:expiring_but_completed) do
      FactoryGirl.create(:study, study_stage: :completion,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: inside_threshold)
    end

    describe "#erb_approval_expiring" do
      it "only returns studies whose approval is expiring" do
        expected = [expired, expiring_inside_threshold]
        expect(Study.erb_approval_expiring).to match_array(expected)
      end
    end

    describe "#erb_approval_expiring?" do
      it "returns true when approval is expiring" do
        expect(expiring_inside_threshold.erb_approval_expiring?).to be true
      end

      it "returns true when approval has expired" do
        expect(expired.erb_approval_expiring?).to be true
      end

      it "returns false otherwise" do
        expect(on_warning_threshold.erb_approval_expiring?).to be false
        expect(expiring_outside_threshold.erb_approval_expiring?).to be false
        expect(no_expiry.erb_approval_expiring?).to be false
        expect(expiring_but_completed.erb_approval_expiring?).to be false
      end
    end
  end

  describe "#erb_response_overdue and #erb_response_overdue?" do
    let(:rereview) { FactoryGirl.create(:rereview) }
    let(:accept) { FactoryGirl.create(:accept) }
    let(:submitted) { ErbStatus.find_by_name("Submitted") }
    let(:today) { Time.zone.today }
    let(:threshold) { today - 3.months }
    let!(:response_due_yesterday) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: submitted,
                                 erb_submitted: threshold - 1.day)
    end
    let!(:response_due_today) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: submitted,
                                 erb_submitted: threshold)
    end
    let!(:response_due_tomorrow) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: submitted,
                                 erb_submitted: threshold + 1.day)
    end
    let!(:no_submission_date) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: submitted,
                                 erb_submitted: nil)
    end
    let!(:received_response_overdue) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_submitted: threshold + 1.day)
    end
    let!(:overdue_but_re_submitted) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: rereview,
                                 erb_submitted: threshold + 1.day)
    end

    describe "#erb_response_overdue" do
      it "only returns studies whose erb response is overdue" do
        expected = [response_due_yesterday]
        expect(Study.erb_response_overdue).to match_array(expected)
      end
    end

    describe "#erb_response_overdue?" do
      it "returns true for overdue studies" do
        expect(response_due_yesterday.erb_response_overdue?).to be true
      end

      it "returns false otherwise" do
        expect(response_due_today.erb_response_overdue?).to be false
        expect(response_due_tomorrow.erb_response_overdue?).to be false
        expect(no_submission_date.erb_response_overdue?).to be false
        expect(received_response_overdue.erb_response_overdue?).to be false
        expect(overdue_but_re_submitted.erb_response_overdue?).to be false
      end
    end
  end

  describe "#user_can_manage?" do
    let(:study) { FactoryGirl.create(:study) }
    let(:user) { FactoryGirl.create(:user) }

    context "when the user is not related to the study" do
      it "returns false" do
        expect(study.user_can_manage?(user)).to be false
      end
    end

    context "when the user is the study pi" do
      before do
        study.principal_investigator = user
        study.save!
      end

      it "returns true" do
        expect(study.user_can_manage?(user)).to be true
      end
    end

    context "when the user is the study rm" do
      before do
        study.research_manager = user
        study.save!
      end

      it "returns true" do
        expect(study.user_can_manage?(user)).to be true
      end
    end

    context "when the user is an admin" do
      before do
        user.is_admin = true
        user.save!
      end

      it "returns true" do
        expect(study.user_can_manage?(user)).to be true
      end
    end
  end

  describe "#in_country" do
    let(:uk_study) { FactoryGirl.create(:study, country_codes: ["GB"]) }
    let(:bd_study) { FactoryGirl.create(:study, country_codes: ["BD"]) }
    let(:bd_and_uk_study) do
      FactoryGirl.create(:study, country_codes: %w(BD GB))
    end

    it "lists studies in the given country" do
      uk_expected = [uk_study, bd_and_uk_study]
      expect(Study.in_country("GB")).to match_array(uk_expected)
      bd_expected = [bd_study, bd_and_uk_study]
      expect(Study.in_country("BD")).to match_array(bd_expected)
    end
  end

  describe "#flagged and #flagged?" do
    let(:accept) { FactoryGirl.create(:accept) }
    let(:submitted) { ErbStatus.find_by_name("Submitted") }
    let(:today) { Time.zone.today }
    let!(:normal_study) { FactoryGirl.create(:study) }
    let!(:response_overdue) do
      FactoryGirl.create(:study, study_stage: :protocol_erb,
                                 protocol_needed: true,
                                 erb_status: submitted,
                                 erb_submitted: today - 4.months)
    end
    let!(:expired) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: true,
                                 erb_status: accept,
                                 erb_approval_expiry: today - 1.day)
    end
    let!(:delayed) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today - 1.day,
                                 completed: nil)
    end
    let!(:delayed_and_expired) do
      FactoryGirl.create(:study, study_stage: :delivery,
                                 protocol_needed: false,
                                 expected_completion_date: today - 1.day,
                                 completed: nil,
                                 erb_status: accept,
                                 erb_approval_expiry: today - 1.day)
    end

    describe "#flagged" do
      it "includes delayed, overdue and expiring studies, without duplicates" do
        expected = [response_overdue, expired, delayed, delayed_and_expired]
        expect(Study.flagged).to match_array(expected)
      end
    end

    describe "#flagged?" do
      it "returns true for expired studies" do
        expect(expired.flagged?).to be true
      end
      it "returns true for overdue studies" do
        expect(response_overdue.flagged?).to be true
      end
      it "returns true for delayed studies" do
        expect(delayed.flagged?).to be true
      end
      it "returns true for delayed and expired studies" do
        expect(delayed_and_expired.flagged?).to be true
      end
      it "returns false otherwise" do
        expect(normal_study.flagged?).to be false
      end
    end
  end

  describe "#visible" do
    let(:hidden) { FactoryGirl.create(:study, hidden: true) }
    let(:visible) { FactoryGirl.create(:study) }

    it "only returns visible studies" do
      expect(Study.visible).to eq [visible]
    end
  end
end
