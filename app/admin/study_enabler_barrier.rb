ActiveAdmin.register StudyEnablerBarrier do
  permit_params :enabler_barrier_id, :study_id, :description, :user_id

  menu priority: 4

  filter :study
  filter :user
  filter :enabler_barrier
  filter :created_at
end
