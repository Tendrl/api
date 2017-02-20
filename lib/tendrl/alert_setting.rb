module Tendrl
  class AlertSetting

    class << self

      def find
        settings = {}
        Tendrl.etcd.get('/notification_settings').children.each do |child|
          settings[child.key.split('/')[-1].to_sym] = child.value
        end
        settings
      end

      def save(attributes={})
        attributes.each do |name, value|
          Tendrl.etcd.set("/notification_settings/#{name}", value: value)
        end
        find
      end
    end

  end
end
