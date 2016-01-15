require "rails_helper"

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

  context "when principal_investigator is set" do
    it "is valid when the pi user has the pi role" do
      pi = FactoryGirl.create(:principal_investigator)
      study = FactoryGirl.build(:study, principal_investigator: pi)
      expect(study).to be_valid
    end

    it "is invalid when the pi user doesn't have the pi role" do
      normal_user = FactoryGirl.create(:normal_user)
      study = FactoryGirl.build(:study, principal_investigator: normal_user)
      expect(study).to be_invalid
    end
  end

  context "when research_manager is set" do
    it "is valid when the rm user has the rm role" do
      pi = FactoryGirl.create(:research_manager)
      study = FactoryGirl.build(:study, research_manager: pi)
      expect(study).to be_valid
    end

    it "is invalid when the rm user doesn't have the rm role" do
      normal_user = FactoryGirl.create(:normal_user)
      study = FactoryGirl.build(:study, research_manager: normal_user)
      expect(study).to be_invalid
    end
  end
end
