class DeliveryUpdatesController < ApplicationController
  include InvitingUsers

  before_action :set_study_from_study_id, only: [:new, :create]
  before_action :check_user_can_contribute_to_study, only: [:new, :create]

  def new
    set_selected_statuses
  end

  def create
    build_delivery_update
    set_selected_statuses
    if @delivery_update.save
      connect_update_to_invites
      set_pending_invites
    else
      set_error_message
    end
    render "new"
  end

  private

  def set_selected_statuses
    set_previous_update
    data_analysis_status = nil
    data_collection_status = nil
    write_up_status = nil
    if @delivery_update
      if @delivery_update.data_analysis_status.present?
        data_analysis_status = @delivery_update.data_analysis_status
      end
      if @delivery_update.data_collection_status.present?
        data_collection_status = @delivery_update.data_collection_status
      end
      if @delivery_update.interpretation_and_write_up_status.present?
        write_up_status = @delivery_update.interpretation_and_write_up_status
      end
    end
    set_selected_data_analysis_status(data_analysis_status)
    set_selected_data_collection_status(data_collection_status)
    set_selected_write_up_status(write_up_status)
  end

  def set_selected_data_analysis_status(current_status)
    @selected_data_analysis_status = nil
    if @previous_update && current_status.blank?
      previous_status = @previous_update.data_analysis_status
      @selected_data_analysis_status = previous_status.id
    elsif current_status.present?
      @selected_data_analysis_status = current_status.id
    end
  end

  def set_selected_data_collection_status(current_status)
    @selected_data_collection_status = nil
    if @previous_update && current_status.blank?
      previous_status = @previous_update.data_collection_status
      @selected_data_collection_status = previous_status.id
    elsif current_status.present?
      @selected_data_collection_status = current_status.id
    end
  end

  def set_selected_write_up_status(current_status)
    @selected_write_up_status = nil
    if @previous_update && current_status.blank?
      previous_status = @previous_update.interpretation_and_write_up_status
      @selected_write_up_status = previous_status.id
    elsif current_status.present?
      @selected_write_up_status = current_status.id
    end
  end

  def set_previous_update
    @previous_update = @study.latest_delivery_update
  end

  def build_delivery_update
    @delivery_update = DeliveryUpdate.new(delivery_update_params)
    @delivery_update.study = @study
    @delivery_update.user = current_user
  end

  def connect_update_to_invites
    # We don't want there to be any outstanding invites for this study if the
    # user has just completed an update, so find them all (you can be invited
    # multiple times) and make sure they all get the update attached.
    invites = @study.outstanding_delivery_update_invites_for_user(current_user)
    if invites.any?
      invites.each do |invite|
        invite.delivery_update = @delivery_update
        invite.save
      end
    end
  end

  def delivery_update_params
    # rubocop:disable Metrics/LineLength
    params.require(:delivery_update).permit(:data_analysis_status_id,
                                            :data_collection_status_id,
                                            :interpretation_and_write_up_status_id,
                                            :comments)
    # rubocop:enable Metrics/LineLength
  end

  def set_pending_invites
    if pending_invites.any?
      @pending_invites = pending_invites
    else
      @pending_invites = []
    end
  end

  def set_error_message
    flash.now[:alert] = "Sorry, looks like we're missing something, can you " \
                        "double check?"
  end

  def pending_invites
    # Check for any other updates they should be creating
    pending_updates_sql = <<-SQL
      invited_user_id = ?
      AND delivery_update_id IS NULL
    SQL
    DeliveryUpdateInvite.where(pending_updates_sql, current_user.id)
  end

  def set_invited_user
    @invited_user = User.find_by_delivery_update_token(params[:token])
  end

  def set_invite
    # You can invite someone multiple times (in theory), so we just assume
    # they're responding to the latest invite.
    # rubocop:disable Style/MultilineOperationIndentation
    @invite = DeliveryUpdateInvite.where(study: @study,
                                         invited_user: @invited_user).
                                   order(created_at: :desc).
                                   take
    # rubocop:enable Style/MultilineOperationIndentation
  end
end
