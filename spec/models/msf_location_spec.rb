require "rails_helper"

RSpec.describe MsfLocation, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it { is_expected.to have_many(:users).inverse_of(:msf_location) }

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it "should not allow you to change the 'External' location's name" do
    external_location = FactoryGirl.create(:external_location)
    external_location.name = "new name"
    expect(external_location).to be_invalid
  end

  # Methods
  describe "#external_location" do
    it "should return the 'External' location record" do
      external_location = FactoryGirl.create(:external_location)
      expect(MsfLocation.external_location).to eq(external_location)
    end

    it "should raise an error if no 'External' location record exists" do
      expect { MsfLocation.external_location }.to(
        raise_error(ActiveRecord::RecordNotFound))
    end
  end
end
