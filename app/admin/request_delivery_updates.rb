ActiveAdmin.register_page "Request delivery updates" do
  page_action :send_requests, method: :post do
    User.pis_with_studies_in_delivery.each do |user|
      invites = []
      user.principal_investigator_studies.delivery.each do |study|
        # Make sure there's only one open invite at any one time for a given
        # user. It's not necessary technically, but it seems like a good idea
        # to keep things tidy.
        remove_existing_open_invites(study, user)
        invites << DeliveryUpdateInvite.create(study: study,
                                               invited_user: user,
                                               inviting_user: current_user)
      end
      DeliveryUpdateInviteMailer.invite(user, invites).deliver_now
    end
    redirect_to admin_request_delivery_updates_path, notice: "Requests sent!"
  end

  action_item :send_request_updates do
    count = User.pis_with_studies_in_delivery.count
    path = admin_request_delivery_updates_send_requests_path
    link_to(path, method: :post) do
      "Send #{pluralize(count, 'delivery update request')}"
    end
  end

  content title: "Request delivery updates" do
    h2 do
      "The following PIs will be asked for their updates:"
    end
    ul do
      User.pis_with_studies_in_delivery.each do |user|
        count = user.principal_investigator_studies.delivery.count
        li do
          "#{user.name} (#{user.email}) - #{pluralize(count, 'study')}"
        end
      end
    end
  end
end

def remove_existing_open_invites(study, user)
  # rubocop:disable Style/MultilineOperationIndentation
  DeliveryUpdateInvite.incomplete.
                       where(study: study, invited_user: user).
                       destroy_all
  # rubocop:enable Style/MultilineOperationIndentation
end
