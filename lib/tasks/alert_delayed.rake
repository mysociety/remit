require "delayed_study_alerter"
# Send email alerts about Studies that are delayed in some way.
#
# We loop over every set of studies that trigger alerts and then send them to
# the people who need to know. We do it this way because we assume that it's
# unlikely that multiple studies will alert anyone on the same day.

desc "Alert Admins, PIs and RMs about studies that are delayed completing"
task alert_delayed_completing: [:environment] do
  DelayedStudyAlerter.alert_delayed_completing
end

desc "Alert Admins, PIs and RMs about studies whose erb approval is expiring"
task alert_approval_expiring: [:environment] do
  DelayedStudyAlerter.alert_approval_expiring
end

desc "Alert Admins, PIs and RMs about studies where an erb response is overdue"
task alert_response_overdue: [:environment] do
  DelayedStudyAlerter.alert_response_overdue
end
