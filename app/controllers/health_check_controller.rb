class HealthCheckController < ApplicationController
  def index
    delayed_alerts_name = "Delayed studies have been alerted"
    expiring_alerts_name = "Approval expiring studies have been alerted"
    overdue_alerts_name = "Response overdue studies have been alerted"
    @checks = {
      delayed_alerts_name => self.delayed_alerts_healthy?,
      expiring_alerts_name => self.approval_expired_alerts_healthy?,
      overdue_alerts_name => self.response_overdue_alerts_healthy?
    }
    @all_healthy = @checks.all? { |_check, value| value }
    if @all_healthy
      render layout: false, status: 200
    else
      render layout: false, status: 500
    end
  end

  protected

  def delayed_alerts_healthy?
    # Have all the delayed studies have been alerted about?
    delayed_query = "expected_completion_date < ?"
    unhealthy_date = Time.zone.yesterday
    delayed_studies = Study.where([delayed_query, unhealthy_date])
    alerts_exist_for_all_studies(
      delayed_studies,
      SentAlert::DELAYED_COMPLETING
    )
  end

  def approval_expired_alerts_healthy?
    # Have all the studies with expired approvals been alerted about?
    expiring_query = "erb_approval_expiry < ?"
    unhealthy_date = Study.erb_approval_expiry_warning_at - 1.day
    expiring_studies = Study.where([expiring_query, unhealthy_date])
    alerts_exist_for_all_studies(
      expiring_studies,
      SentAlert::APPROVAL_EXPIRING
    )
  end

  def response_overdue_alerts_healthy?
    # Have all the studies with overdue responses been alerted about?
    overdue_query = "erb_submitted < ?"
    unhealthy_date = Study.erb_response_overdue_at - 1.day
    overdue_studies = Study.where([overdue_query, unhealthy_date])
    alerts_exist_for_all_studies(
      overdue_studies,
      SentAlert::RESPONSE_OVERDUE
    )
  end

  def alerts_exist_for_all_studies(studies, alert_type)
    studies.each do |study|
      if SentAlert.where(alert_type: alert_type, study: study).empty?
        # There should be at least one alert, so this is not healthy
        return false
      end
    end
    # If we get here, everthing has had alerts sent, this is healthy
    true
  end
end
