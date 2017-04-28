class NotificationsController < AuthenticatedUsersController

  get '/notifications' do
    begin
      notifications = Tendrl::Notification.all
      notifications.to_json
    rescue Etcd::KeyNotFound
      [].to_json
    end
  end

end
