# An ActiveSupport::Concern for creating PublicActivity activities for the
# related study object when something is created.
# e.g. when I create a Document, it creates an activity entry for the study
# recording its creation.
module StudyActivityTrackable
  extend ActiveSupport::Concern

  included do
    after_create :log_activity
  end

  def log_activity
    if study.present?
      key = "#{self.class.table_name.singularize}_added".to_sym
      params = { type: self.class.name, id: id }
      owner = proc { |c, _m| c.current_user unless c.nil? }
      study.create_activity key, parameters: params, owner: owner
    end
  end
end
