class ChangeStudyTopicToHasMany < ActiveRecord::Migration
  # From http://manuel.manuelles.nl/blog/2013/03/04/rails-belongs-to-to-has-many/
  def up
    create_table :studies_study_topics, id: false do |t|
      t.belongs_to :study_topic, index: true, null: false, foreign_key: true
      t.belongs_to :study, index: true, null: false, foreign_key: true
    end

    # define the old belongs_to study_topic associate
    Study.class_eval do
      belongs_to :old_study_topic,
                 class_name: "StudyTopic",
                 foreign_key: "study_topic_id"
    end

    # add the belongs_to study_topic to the has_and_belongs_to_many
    # study_topics
    Study.all.each do |study|
      unless study.old_study_topic.nil?
        study.study_topics << study.old_study_topic
        study.save
      end
    end

    # remove the old study_topic_id column for the belongs_to associate
    remove_column :studies, :study_topic_id
  end

  def down
    add_column :studies, :study_topic_id, :integer

    Study.class_eval do
      belongs_to :new_study_topic,
                 class_name: "StudyTopic",
                 foreign_key: "study_topic_id"
    end

    Study.all.each do |study|
      # NOTE: we'll grab the first study_topic (if present),
      # so if there are more, these will be lost!
      unless study.study_topics.empty?
        study.new_study_topic = study.study_topics.first
        study.save
      end
    end

    drop_table :studies_study_topics
  end
end
