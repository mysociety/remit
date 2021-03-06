# == Schema Information
#
# Table name: publications
#
#  id                    :integer          not null, primary key
#  study_id              :integer
#  doi_number            :text
#  lead_author           :text             not null
#  article_title         :text             not null
#  book_or_journal_title :text             not null
#  publication_year      :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#
# Indexes
#
#  index_publications_on_study_id  (study_id)
#  index_publications_on_user_id   (user_id)
#

class Publication < ActiveRecord::Base
  include StudyActivityTrackable

  belongs_to :study, inverse_of: :publications
  belongs_to :user, inverse_of: :publications

  # This has to run first, because it potentially sets other values that
  # following validators check
  validates_with DoiNumberValidator
  validates :lead_author, presence: true
  validates :article_title, presence: true
  validates :book_or_journal_title, presence: true
  validates :publication_year, presence: true
end
