FactoryGirl.define do
  factory :study do
    sequence(:title) { |n| "Study #{n}" }
    sequence(:concept_paper_date) { |n| n.weeks.ago }
    protocol_needed true
    study_stage "concept"
    operating_center "OCA"
    sequence(:generated_reference_id) { |n| "015-#{n}" }

    # Associations are to things that must have unique names, so we create
    # them in these hooks and look up any existing ones first
    after(:build) do |study|
      if study.study_type.nil?
        rct_type = StudyType.find_by_name("Randomised controlled trial (RCT)")
        study.study_type = rct_type || create(:randomised_type)
      end

      if study.study_setting.nil?
        stable_setting = StudySetting.find_by_name("Stable")
        study.study_setting = stable_setting || create(:stable_setting)
      end

      if study.study_topics.empty?
        if topic = StudyTopic.find_by_name("AMR")
          study.study_topics << topic
        else
          study.study_topics << create(:amr_topic)
        end
      end
    end

    factory :delayed_completing_study do
      expected_completion_date Time.zone.today - 2.days
    end

    factory :erb_approval_expiring_study do
      erb_approval_expiry Study.erb_approval_expiry_warning_at - 2.days
    end

    factory :erb_response_overdue_study do
      erb_submitted Study.erb_response_overdue_at - 2.days
    end
  end
end
