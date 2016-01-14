ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Studies over 12 months old that haven't completed" do
          ul do
            completion = StudyStage.find_by_name!("Completion")
            withdrawn = StudyStage.find_by_name!("Withdrawn or Postponed")
            query = "concept_paper_date < :year_ago AND study_stage_id NOT " \
              "IN (:completed_stage_ids)"
            Study.where(
              query,
              year_ago: Time.zone.today - 1.year,
              completed_stage_ids: [completion.id, withdrawn.id]
            ).limit(5).map do |study|
              li link_to(study.title, admin_study_path(study))
            end
          end
        end
      end

      column do
        panel "Info" do
          para "Welcome to ReMIT's Admin pages."
          para "Some helpful links or notes could go here..."
        end
      end
    end
  end # content
end
