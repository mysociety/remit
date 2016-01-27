# An ActiveSupport::Concern for creating PublicActivity activities for the
# related study object when something is created.
# e.g. when I create a Document, it creates an activity entry for the study
# recording its creation.
module StudyActivityTrackable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :related_content,
                          class_name: "PublicActivity::Activity",
                          dependent: :destroy
    # Not using after_create because we create some things in a bigger
    # wrapping transaction, (e.g. multiple study impacts at the same time)
    # so after_create might fire and create an activity but then need to be
    # rolled back
    after_commit :log_activity, on: :create
  end

  def log_activity
    if study.present?
      key = "#{self.class.table_name.singularize}_added".to_sym
      owner = proc { |c, _m| c.current_user unless c.nil? }
      study.create_activity key, owner: owner, related_content: self
    end
  end
end
