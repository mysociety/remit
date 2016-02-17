require "securerandom"
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :text             not null
#  msf_location_id        :integer
#  external_location      :text
#  is_admin               :boolean          default(FALSE), not null
#  invite_token           :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_msf_location_id       (msf_location_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :confirmable

  enum role: {
    principal_investigator: "principal_investigator",
    research_manager: "research_manager",
    admin: "admin",
    contributor: "contributor",
    normal_user: "normal_user",
  }

  belongs_to :msf_location, inverse_of: :users
  has_many :principal_investigator_studies,
           class_name: :Study,
           inverse_of: :principal_investigator
  has_many :research_manager_studies,
           class_name: :Study,
           inverse_of: :research_manager
  # E.g. when an admin user updates a study
  # These should not be destroyed when the user is deleted, because they're
  # an important record of who did what
  has_many :created_activities, as: :owner,
                                class_name: "PublicActivity::Activity",
                                dependent: :restrict_with_exception
  # E.g. when the user is set to a PI or RM on a study
  # These should be destroyed when the user is destroyed because that should
  # only happen if someone's made a mistake.
  has_many :involved_activities, as: :recipient,
                                 class_name: "PublicActivity::Activity",
                                 dependent: :destroy
  has_many :sent_alerts, inverse_of: :user

  has_many :documents, inverse_of: :user
  has_many :publications, inverse_of: :user
  has_many :disseminations, inverse_of: :user
  has_many :study_impacts, inverse_of: :user
  has_many :study_notes, inverse_of: :user
  has_many :study_enabler_barriers, inverse_of: :user
  has_many :created_study_invites, class_name: :StudyInvite,
                                   inverse_of: :inviting_user
  has_many :received_study_invites, class_name: :StudyInvite,
                                    inverse_of: :invited_user
  has_many :invited_studies, through: :received_study_invites,
                             source: :study

  validates :name, presence: true
  validate :external_location_is_set_if_msf_location_is_external
  validates :invite_token, uniqueness: true, allow_nil: true

  def external_location_is_set_if_msf_location_is_external
    if msf_location == MsfLocation.external_location && external_location.blank?
      message = "You must describe the location if you choose " \
        "\"#{MsfLocation::EXTERNAL_LOCATION_NAME}\""
      errors.add(:external_location, message)
    end
  end

  def studies
    query = "principal_investigator_id = ? OR research_manager_id = ?"
    Study.where(query, id, id)
  end

  # These methods are taken from has_secure_token. We can't use that gem
  # directly because don't want an invite token to be created automatically,
  # only when one use invites another.
  def regenerate_invite_token
    update_attributes invite_token: self.class.generate_unique_secure_token
  end

  def self.generate_unique_secure_token
    SecureRandom.base58(24)
  end
end
