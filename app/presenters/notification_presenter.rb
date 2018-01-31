module NotificationPresenter

  class << self

    def list(raw_notifications)
      notifications = []
      raw_notifications.each do |notification|
        notification.each do |notification_id, attributes|
          attributes.slice!('message_id', 'timestamp', 'priority', 'payload')
          payload = attributes.delete('payload')
          message = JSON.parse(payload['message'])['tags']['message'] rescue ""
          attributes['message_id'] = notification_id
          attributes['message'] = message
          notifications << attributes
        end
      end
      notifications.sort do |a,b|
        Time.parse(b['timestamp']) <=> Time.parse(a['timestamp'])
      end
    end

    def list_by_cluster_id(raw_notifications, cluster_id)
      notifications = []
      raw_notifications.each do |notification|
        notification.each do |notification_id, attributes|
          if attributes.key?("cluster_id") && attributes['cluster_id'] == cluster_id
            attributes.slice!('message_id', 'timestamp', 'priority', 'payload')
            payload = attributes.delete('payload')
            message = JSON.parse(payload['message'])['tags']['message'] rescue ""
            attributes['message_id'] = notification_id
            attributes['message'] = message
            notifications << attributes
          end
        end
      end
      notifications.sort do |a,b|
        Time.parse(b['timestamp']) <=> Time.parse(a['timestamp'])
      end
    end

  end

end
