ActiveAdmin.register Publication do
  permit_params :doi_number, :study_id, :lead_author, :article_title,
                :book_or_journal_title, :publication_year, :user_id

  menu priority: 3

  filter :study
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs "Details" do
      f.input :study
      f.input :user
      f.input :doi_number, as: :string
      f.input :lead_author, as: :string
      f.input :article_title, as: :string
      f.input :book_or_journal_title, as: :string
      f.input :publication_year, as: :number,
                                 input_html: { value: Time.zone.now.year }
    end
    f.actions
  end
end
