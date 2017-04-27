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
        job_id: @job_id,
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
      Tendrl.etcd.set("/queue/#{@job_id}/status", value: 'new')
      Tendrl.etcd.set("/queue/#{@job_id}/payload", value: @payload.to_json)
      self
    end

    class << self

      def all
        jobs = []
        Tendrl.etcd.get('/queue', recursive: true).children.each do |job|
          attrs = {}
          job.children.each do |child|
            child_attr = child.key.split('/')[-1]
            attrs[child_attr] = child.value
          end
          jobs << attrs
        end
        jobs
      end

      def find(job_id)
        attrs = {}
        Tendrl.etcd.get("/queue/#{job_id}", recursive: true).
          children.each do |child|
          child_attr = child.key.split('/')[-1]
          attrs[child_attr] = child.value
        end
        attrs
      end

      def messages(job_id)
        messages = []
        begin
          Tendrl.etcd.get("/messages/jobs/#{job_id}", recursive: true).
            children.each do |child|
            messages << JSON.parse(child.value)
          end
        rescue Etcd::KeyNotFound
        end
        messages
      end

      def children_messages(job_id)
        messages = []
        begin
          JSON.parse(Tendrl.etcd.get("/queue/#{job_id}/children").value).each do
            |job_id|
            messages << self.messages(job_id)
          end
        rescue Etcd::KeyNotFound
        end
        messages
      end

      def status(job_id)
        { status: Tendrl.etcd.get("/queue/#{job_id}/status").value }
      end

    end

  end
end

