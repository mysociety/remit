class DelayedStudyAlerter
  def self.alert_delayed_completing
    Study.delayed_completing.each do |study|
      send_alerts(study, SentAlert::DELAYED_COMPLETING, :delayed_completing)
    end
  end

  def self.alert_approval_expiring
    Study.erb_approval_expiring.each do |study|
      send_alerts(study, SentAlert::APPROVAL_EXPIRING, :approval_expiring)
    end
  end

  def self.alert_response_overdue
    Study.erb_response_overdue.each do |study|
      send_alerts(study, SentAlert::RESPONSE_OVERDUE, :response_overdue)
    end
  end

  def self.send_alerts(study, type, mailer_action)
    recipients_for(study).each do |user|
      if SentAlert.find_by(study: study, user: user, alert_type: type).blank?
        AlertMailer.send(mailer_action.to_sym, study, user).deliver_now
        SentAlert.create(study: study, user: user, alert_type: type)
      end
    end
  end

  def self.recipients_for(study)
    recipients = []
    pi = study.principal_investigator
    rm = study.research_manager
    recipients << pi unless pi.blank?
    recipients << rm unless rm.blank?
    recipients += User.where(is_admin: true)
    recipients.uniq # Some admins could also be PIs or RMs
  end
end
