require "rails_helper"
require "support/shared_examples/models/concerns/study_activity_trackable"

RSpec.describe Dissemination, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:dissemination_category_id).
      of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:details).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:other_dissemination_category).of_type(:text)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:disseminations) }
  it { is_expected.to belong_to(:user).inverse_of(:disseminations) }
  it do
    is_expected.to belong_to(:dissemination_category).
      inverse_of(:disseminations)
  end

  # Validations
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:dissemination_category) }
  it { is_expected.to validate_presence_of(:details) }

  context "when dissemination_category is 'Other internal'" do
    let(:other_internal_category) do
      DisseminationCategory.find_by_name("Other internal")
    end

    it "should be invalid when the dissemination_category field is nil" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_internal_category,
        other_dissemination_category: nil)
      expect(category).to be_invalid
    end

    it "should be invalid when the dissemination_category field is empty" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_internal_category,
        other_dissemination_category: "")
      expect(category).to be_invalid
    end

    it "should be valid when we set the dissemination_category field" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_internal_category,
        other_dissemination_category: "some other category")
      expect(category).to be_valid
    end
  end

  context "when dissemination_category is 'Other external'" do
    let(:other_external_category) do
      DisseminationCategory.find_by_name("Other external")
    end

    it "should be invalid when the dissemination_category field is nil" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_external_category,
        other_dissemination_category: nil)
      expect(category).to be_invalid
    end

    it "should be invalid when the dissemination_category field is empty" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_external_category,
        other_dissemination_category: "")
      expect(category).to be_invalid
    end

    it "should be valid when we set the dissemination_category field" do
      category = FactoryGirl.build(
        :dissemination,
        dissemination_category: other_external_category,
        other_dissemination_category: "some other category")
      expect(category).to be_valid
    end
  end

  it_behaves_like "study_activity_trackable"
end
