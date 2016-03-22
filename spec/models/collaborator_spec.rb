require "rails_helper"

RSpec.describe Collaborator, type: :model do
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:description).of_type(:text) }

  it do
    is_expected.to have_many(:study_collaborators).inverse_of(:collaborator)
  end
  it { is_expected.to have_many(:studies).through(:study_collaborators) }

  it { is_expected.to validate_presence_of(:name) }
end
