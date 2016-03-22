require "rails_helper"

RSpec.describe StudyCollaborator, type: :model do
  it { is_expected.to have_db_column(:study_id).of_type(:integer) }
  it { is_expected.to have_db_column(:collaborator_id).of_type(:integer) }
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:collaborator) }

  it { is_expected.to belong_to(:study).inverse_of(:study_collaborators) }
  it do
    is_expected.to belong_to(:collaborator).inverse_of(:study_collaborators)
  end

  it do
    expect(FactoryGirl.create(:study_collaborator)).to(
      validate_uniqueness_of(:collaborator_id).scoped_to(:study_id))
  end
end
