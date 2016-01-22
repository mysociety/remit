module ApplicationHelper
  # Return a hash that details a study's progress through the stages
  # Useful for printing the progress indicator on study pages
  def study_timeline(study)
    # Initialise a timeline object with a nice label for each stage
    # and a state field for whether it's "done", "doing" or not yet reached.
    stages = Study.study_stages.keys.map(&:to_sym)
    timeline = initial_study_timeline(stages)

    # We only want to show the "withdrawn" stage if the study is actually
    # withdrawn though...
    unless study.withdrawn_postponed?
      timeline.delete(:withdrawn_postponed)
    end

    # Fill in the state field based on the activities we've recorded against
    # the study.
    stage_changes = study.activities.
                    where(key: "study.study_stage_changed").
                    order(created_at: :asc)
    timeline = populate_timeline_states(timeline, stage_changes)

    # Ensure that stages before the current one are completed, even if the
    # history shows the study jumped straight to it (e.g. because we
    # imported it when it was already in progress, or completed).
    # Only for non-withdrawn studies, because we can't tell what other
    # stages a withdrawn study would have been through otherwise.
    current_stage_index = stages.index(study.study_stage.to_sym)
    unless study.withdrawn_postponed?
      timeline = ensure_timeline_is_complete timeline,
                                             stages,
                                             current_stage_index
    end

    # Finally, ensure that the current stage is marked as "doing"
    timeline[stages[current_stage_index]][:state] = "doing"

    timeline
  end

  protected

  def initial_study_timeline(stages)
    timeline = {}
    stages.each do |stage|
      timeline[stage] = {
        label: Study::STUDY_STAGE_LABELS[stage],
        state: ""
      }
    end
    timeline
  end

  def populate_timeline_states(timeline, changes)
    changes.each do |change_activity|
      stage_before = change_activity.parameters[:before].to_sym
      stage_after = change_activity.parameters[:after].to_sym
      unless stage_before.blank?
        timeline[stage_before][:state] = "done"
      end
      timeline[stage_after][:state] = "doing"
    end
    timeline
  end

  def ensure_timeline_is_complete(timeline, stages, current_stage_index)
    if current_stage_index > 0
      stages_before = stages.slice(0..current_stage_index - 1)
      stages_before.each do |stage|
        timeline[stage][:state] = "done"
      end
    end
    timeline
  end
end
