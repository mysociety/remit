FactoryGirl.define do
  factory :user, aliases: [:confirmed_user, :normal_user] do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@msf.org" }
    msf_location

    # This is the best way to set the password for the factory
    after(:build) { |u| u.password_confirmation = u.password = "password" }
    # This makes the user full confirmed
    after :create, &:confirm

    factory :principal_investigator do
      role "principal_investigator"
    end

    factory :research_manager do
      role "research_manager"
    end

    factory :admin_user do
      role "admin"
    end
  end
end
