class NotificationsController < AuthenticatedUsersController

  get '/notifications' do
    notifications = Tendrl::Notification.all
    NotificationPresenter.list(notifications).to_json
  end

end
