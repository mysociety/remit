ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  action_item :view_site do
    link_to "View Site", "/"
  end
  action_item :request_delivery_updates do
    link_to "Request delivery updates", admin_request_delivery_updates_path
  end
  action_item :request_delivery_updates do
    link_to "Request annual updates", admin_request_annual_updates_path
  end

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Studies over 12 months old that haven't completed" do
          ul do
            query = "concept_paper_date < :year_ago AND " \
                    "study_stage NOT IN (:completed_stages)"
            Study.where(
              query,
              year_ago: Time.zone.today - 1.year,
              completed_stages: %w(completion withdrawn_postponed)
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
