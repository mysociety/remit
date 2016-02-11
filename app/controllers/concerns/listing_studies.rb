module ListingStudies
  extend ActiveSupport::Concern

  included do
    before_action :set_include_archived, only: :index
    before_action :set_study_scope, only: :index
  end

  def set_include_archived
    @include_archived = params[:include_archived] == "1"
  end

  def set_study_scope
    @study_scope = :not_archived_or_withdrawn
    if @include_archived
      @study_scope = :not_withdrawn
    end
  end
end
