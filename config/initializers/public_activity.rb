PublicActivity::Activity.class_eval do
  belongs_to :related_content, polymorphic: true
end
