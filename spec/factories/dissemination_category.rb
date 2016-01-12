FactoryGirl.define do
  factory :dissemination_category, aliases: [:working_group_category] do
    name "Working group"
    dissemination_category_type "internal"

    factory :internal_msf_publication do
      name "Internal MSF publication"
      dissemination_category_type "internal"
    end

    factory :msf_conference do
      name "MSF conference"
      description "e.g. MSF Scientific Days or Operational Research Day"
      dissemination_category_type "internal"
    end

    factory :email_group do
      name "Email group"
      dissemination_category_type "internal"
    end

    factory :field do
      name "Field"
      description "i.e. mission/project where the study was conducted"
      dissemination_category_type "internal"
    end

    factory :scientific_meeting do
      name "Scientific meeting"
      description "conference/symposium"
      dissemination_category_type "external"
    end

    factory :press_release_or_press_conference do
      name "Press release or press conference"
      dissemination_category_type "external"
    end

    factory :talk_or_presentation do
      name "Talk or presentation"
      description "please describe the setting"
      dissemination_category_type "external"
    end

    factory :policy_briefing_paper do
      name "Policy briefing paper"
      dissemination_category_type "external"
    end

    factory :formal_working_group_expert_panel_advisory_body do
      name "Formal working group expert panel advisory body"
      dissemination_category_type "external"
    end

    factory :magazine_newsletter_or_online_publication do
      name "Magazine newsletter or online publication"
      description "blog website"
      dissemination_category_type "external"
    end

    factory :bilateral_meeting do
      name "Bilateral meeting"
      description "e.g. MoH"
      dissemination_category_type "external"
    end

    factory :community_involved_with_research do
      name "Community involved with research"
      dissemination_category_type "external"
    end

    factory :other_internal do
      name "Other internal"
      dissemination_category_type "internal"
    end

    factory :other_external do
      name "Other external"
      description "e.g. other meetings platforms etc. - please note"
      dissemination_category_type "external"
    end
  end
end
