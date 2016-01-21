FactoryGirl.define do
  factory :publication, aliases: [:manual_publication] do
    study
    sequence(:lead_author) { |n| "publication author #{n}" }
    sequence(:article_title) { |n| "publication #{n}" }
    sequence(:book_or_journal_title) { |n| "journal #{n}" }
    sequence(:publication_year) { |n| 1960 + n }

    factory :doi_publication do
      sequence(:doi_number) { |n| 1_000_000 + n }
    end
  end
end
