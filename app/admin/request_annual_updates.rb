ActiveAdmin.register_page "Request annual updates" do
  menu parent: "Study Invites"

  page_action :send_requests, method: :post do
    # We're going to create lots of invites, but they send an email on save
    # and we only want to send one email per user, so turn off the callbacks
    StudyInvite.skip_callback(:save, :after, :send_invite)
    User.all.each do |user|
      next unless user.principal_investigator_studies.active.any?
      # Create invites for each study so that we can direct users to the
      # impact adding form directly
      invites = []
      user.principal_investigator_studies.active.each do |study|
        invites << StudyInvite.create(study: study,
                                      invited_user: user,
                                      inviting_user: current_user)
      end
      AnnualUpdateMailer.invite(user, invites).deliver_now
    end
    # Turn the callbacks back on
    StudyInvite.set_callback(:save, :after, :send_invite)
    redirect_to admin_request_annual_updates_path, notice: "Requests sent!"
  end

  action_item :send_request_updates do
    count = 0
    User.all.each do |user|
      next unless user.principal_investigator_studies.active.any?
      count += 1
    end
    path = admin_request_annual_updates_send_requests_path
    link_to(path, method: :post) do
      "Send #{pluralize(count, 'annual update request')}"
    end
  end

  content title: "Request annual updates" do
    h2 do
      "The following PIs will be asked for annual updates on their" \
      " active studies:"
    end
    ul do
      User.all.each do |user|
        next unless user.principal_investigator_studies.active.any?
        count = user.principal_investigator_studies.active.count
        li do
          "#{user.name} (#{user.email}) - #{pluralize(count, 'study')}"
        end
      end
    end
  end
end
