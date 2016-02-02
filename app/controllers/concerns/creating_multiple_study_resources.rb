module CreatingMultipleStudyResources
  extend ActiveSupport::Concern

  def create_multiple_resources(study, resource_class, params, id_param, description_param)
    resources = {}
    resource_class.transaction do
      ids = params[id_param.to_s.pluralize.to_sym]
      descriptions = params[description_param.to_s.pluralize.to_sym]
      ids.values.each do |id|
        resource = resource_class.new(
          id_param => id,
          description_param => descriptions[id])
        resource.study = study
        resources[id.to_i] = resource
        # We call this and ignore the output for now, so that we can get
        # errors for each resource in one go and then decide whether to rollback
        # and show the errors, or continue
        resource.save
      end
      if resources.values.any?(&:invalid?)
        # One of the resources (at least) had an error, rollback and show it
        raise ActiveRecord::Rollback
      end
    end
    resources
  end
end