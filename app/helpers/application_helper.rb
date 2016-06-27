module ApplicationHelper
  # Return a hash that details a study's progress through the stages
  # Useful for printing the progress indicator on study pages
  def study_timeline(study)
    # Initialise a timeline object with a nice label for each stage
    # and a state field for whether it's "done", "doing" or not yet reached.
    stages = Study.study_stages.keys.map(&:to_sym)

    # We only want to show the "withdrawn" stage if the study is actually
    # withdrawn though...
    unless study.withdrawn_postponed?
      stages.delete(:withdrawn_postponed)
    end

    # Likewise, only archived studies get that stage
    if study.archived?
      stages << :archived
    end

    timeline = initial_study_timeline(stages)

    # Fill in the state field based on the activities we've recorded against
    # the study.
    stage_changes = study.activities.
                    where(key: "study.study_stage_changed").
                    order(created_at: :asc)
    timeline = populate_timeline_states(timeline, stage_changes)

    # Ensure that stages before the current one are completed, even if the
    # history shows the study jumped straight to it (e.g. because we
    # imported it when it was already in progress, or completed).
    study_stage = study.archived? ? :archived : study.study_stage.to_sym
    current_stage_index = stages.index(study_stage)

    # Withdrawn studies are different because we want them to end directly
    # in withdrawn from whatever state they were in before.
    if study.withdrawn_postponed?
      timeline = ensure_withdrawn_timeline_is_complete timeline,
                                                       stages,
                                                       stage_changes
    else
      timeline = ensure_timeline_is_complete timeline,
                                             stages,
                                             current_stage_index
    end

    timeline
  end

  # Return a string that describes a transition from one study stage to
  # another, for printing
  def study_stage_transition(before = nil, after = nil)
    # We don't need a state machine, because actually we only care about
    # either the end state or the before state for the purposes of this
    unless after.blank?
      label = after_stage_transitions(after)
      return label unless label.blank?
    end

    unless before.blank?
      return before_stage_transitions(before)
    end
  end

  def total_not_archived_or_withdrawn_studies
    Study.not_archived_or_withdrawn.count
  end

  def total_not_withdrawn_studies
    Study.not_withdrawn.count
  end

  def total_locations
    # Note: this is slightly wrong, in that it counts studies in multiple
    # countries as a new unique study location, but there aren't that many of
    # those and the alternative is really slow, so I'm ignoring it for now.
    Study.select(:country_codes).distinct.count
  end

  def total_impactful_studies
    Study.impactful_count
  end

  def bootstrap_class_for(flash_type)
    case flash_type
    when "success"
      "alert-success"
    when "alert"
      "alert-danger"
    when "notice"
      "alert-info"
    else
      flash_type.to_s
    end
  end

  protected

  def initial_study_timeline(stages)
    timeline = {}
    stages.each do |stage|
      timeline[stage] = {
        label: Study::STUDY_STAGE_LABELS[stage],
        state: "todo"
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
    # Finally, ensure that the current stage is marked as "doing"
    timeline[stages[current_stage_index]][:state] = "doing"
    timeline
  end

  def ensure_withdrawn_timeline_is_complete(timeline, stages, stage_changes)
    if stage_changes.present?
      # There's at least one stage that happened before we withdrew this study
      # so we can show that and the stages up to it as having been completed
      # then show it as having been withdrawn directly afterwards.
      stage_before_withdrawn = stage_changes.last.parameters[:before].to_sym
      stage_before_withdrawn_index = stages.index(stage_before_withdrawn)
      stages_before = stages.slice(0..stage_before_withdrawn_index - 1)
      stages_after = stages.slice(stage_before_withdrawn_index + 1..-2)
      if stages_before.present?
        stages_before.each do |stage|
          timeline[stage][:state] = "done"
        end
      end
      if stages_after.present?
        stages_after.each do |stage|
          timeline.delete(stage)
        end
      end
    else
      # The study has no history of other stages, so we can only show the
      # current withdrawn state - delete all the others.
      # We assume that the concept stage is always done before
      # something is withdrawn though, otherwise the timeline looks weird
      timeline[:concept][:state] = "done"
      other_stages = stages.slice(1..-2)
      other_stages.each do |stage|
        timeline.delete(stage)
      end
    end
    # Finally, ensure that the current stage is marked as "doing"
    timeline[:withdrawn_postponed][:state] = "doing"
    timeline
  end

  def after_stage_transitions(after)
    case after
    when "completion" then "Study completed"
    when "withdrawn_postponed" then "Study was withdrawn or postponed"
    end
  end

  def before_stage_transitions(before)
    case before
    when "concept" then "Concept note approved"
    when "protocol_erb" then "Protocol passed ERB"
    when "delivery" then "Study delivery ended"
    end
  end
end
