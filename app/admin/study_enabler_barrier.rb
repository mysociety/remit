ActiveAdmin.register StudyEnablerBarrier do
  permit_params :enabler_barrier_id, :study_id, :description

  menu priority: 4

  filter :study
  filter :enabler_barrier
  filter :created_at
end
