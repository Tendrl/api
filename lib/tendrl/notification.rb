module Tendrl
  class Notification

    class << self

      def all
        notifications = []
        Tendrl.etcd.get("/messages/events", recursive: true).children.each do |children|
          notification = {}
          children.children.each do |child|
            key = child.key.split('/')[-1]
            next unless ['timestamp','payload', 'priority'].include? key
            if child.dir
              child.children.each do |cchild|
                ckey = cchild.key.split('/')[-1]
                next unless ['message'].include? ckey
                notification[ckey] = cchild.value
              end
            else
              notification[key] = child.value
            end
          end
          notifications << notification unless notification.blank?
        end
        notifications.select{|e| e['priority'] == 'error' }.sort do |a,b|
          Time.parse(a['timestamp']) <=> Time.parse(b['timestamp'])
        end
      end

    end
  end
end
