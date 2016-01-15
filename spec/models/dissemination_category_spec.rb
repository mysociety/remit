require "rails_helper"

RSpec.describe DisseminationCategory, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:dissemination_category_type).
      of_type(:enum).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it do
    is_expected.to have_many(:disseminations).
      inverse_of(:dissemination_category)
  end

  # Validation
  describe "validations" do
    let(:other_internal) do
      DisseminationCategory.find_by_name("Other internal")
    end

    let(:other_external) do
      DisseminationCategory.find_by_name("Other external")
    end

    subject { FactoryGirl.build(:dissemination_category) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:dissemination_category_type) }
    expected_enum_options = {
      internal: "internal",
      external: "external",
    }
    it do
      is_expected.to define_enum_for(:dissemination_category_type).
        with(expected_enum_options)
    end

    it "should not allow changing the 'Other (internal)' category name" do
      other_internal.name = "new name"
      expect(other_internal).to be_invalid
    end

    it "should not allow changing the 'Other (external)' category name" do
      other_external.name = "new name"
      expect(other_external).to be_invalid
    end

    # Methods
    describe "#other_internal_category" do
      it "should return the 'Other (internal)' category record" do
        expect(DisseminationCategory.other_internal_category).to(
          eq(other_internal))
      end

      it "should error if no 'Other (internal)' category record exists" do
        other_internal.destroy
        expect { DisseminationCategory.other_internal_category }.to(
          raise_error(ActiveRecord::RecordNotFound))
      end
    end

    describe "#other_external_category" do
      it "should return the 'Other (external)' category record" do
        expect(DisseminationCategory.other_external_category).to(
          eq(other_external))
      end

      it "should error if no 'Other (external)' category record exists" do
        other_external.destroy
        expect { DisseminationCategory.other_external_category }.to(
          raise_error(ActiveRecord::RecordNotFound))
      end
    end
  end
end
