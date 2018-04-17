module Tendrl
  class Job

    attr_reader :job_id, :payload

    def initialize(user, flow, options={})
      @user = user
      @flow = flow
      @job_id = SecureRandom.uuid
      @type = options[:type] || 'node'
      @integration_id = options[:integration_id] || SecureRandom.uuid
    end

    def default_payload
      {
        status: 'new',
        name: @flow.flow_name,
        run: @flow.run,
        type: @type,
        created_from: 'API',
        created_at: Time.now.utc.iso8601,
        username: @user.username
      }
    end

    def create(parameters, routing = {})
      parameters['TendrlContext.integration_id'] = @integration_id
      @payload = default_payload.merge parameters: parameters
      @payload[:node_ids] = routing[:node_ids] if routing[:node_ids].present?
      @payload[:tags] = @flow.tags(parameters)
      data = {
        status: 'new',
        payload: @payload
      }
      Tendrl.etcd.set("/queue/#{@job_id}/data", value: data.to_json)
      self
    end

    class << self
      def all
        Tendrl.etcd.get('/queue', recursive: true).children.map do |job|
          Tendrl.recurse(job).values.first
        end
      end

      def find(job_id)
        Tendrl.recurse(
          Tendrl.etcd.get("/queue/#{job_id}", recursive: true)
        )[job_id]
      end

      def messages(job_id)
        messages = []
        begin
          Tendrl.etcd.get("/messages/jobs/#{job_id}", recursive: true)
            .children.each do |child|
            begin
              if child.value.present?
                messages << JSON.parse(child.value)
              end
            rescue JSON::ParserError
            end
          end
        rescue Etcd::KeyNotFound
        end
        messages
      end
    end
  end
end
