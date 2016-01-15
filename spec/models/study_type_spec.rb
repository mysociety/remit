require "rails_helper"

RSpec.describe StudyType, type: :model do
  let(:other_study_type) { StudyType.find_by_name("Other") }
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it { is_expected.to have_many(:studies).inverse_of(:study_type) }

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it "should not allow you to change the 'Other' study type's name" do
    other_study_type.name = "new name"
    expect(other_study_type).to be_invalid
  end

  # Methods
  describe "#other_study_type" do
    it "should return the 'Other' study type record" do
      expect(StudyType.other_study_type).to eq(other_study_type)
    end

    it "should raise an error if no 'Other' study type record exists" do
      other_study_type.destroy
      expect { StudyType.other_study_type }.to raise_error(
        ActiveRecord::RecordNotFound)
    end
  end
end
