module Tendrl
  class Alert
    class << self
      def all(path='alerts')
        alerts = Tendrl.etcd.get("/alerting/#{path}", recursive: true)
                       .children.map do |alert|
          alert = Tendrl.recurse(alert).values.first
          alert['tags'] = JSON.parse(alert['tags']) || []
          alert
        end
        alerts.sort do |a, b|
          Time.parse(a['time_stamp']) <=> Time.parse(b['time_stamp'])
        end
      end

      def find(alert_id)
        alert = Tendrl.recurse(
          Tendrl.etcd.get("/alerting/alerts/#{alert_id}")
        )[alert_id]
        alert['tags'] = JSON.parse(alert['tags']) rescue []
        alert
      end
    end
  end
end
