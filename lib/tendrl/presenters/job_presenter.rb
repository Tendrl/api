module JobPresenter

  class << self

    def single(job)
      payload = JSON.parse(job['payload'])
      if payload['created_from'] == 'API'
        {
          job_id: payload['job_id'],
          status: job['status'],
          integration_id: payload['integration_id'],
          flow: payload['flow'],
          parameters: payload['parameters'],
          created_at: payload['created_at'],
          status_url: "/jobs/#{payload['job_id']}/status",
          messages_url: "/jobs/#{payload['job_id']}/messages"
        }
      end
    end

    def list(jobs)
      jobs.map do |job|
        single(job)
      end.compact
    end

  end

end
