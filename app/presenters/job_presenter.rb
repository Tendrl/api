module JobPresenter

  class << self

    def single(job)
      return if job['payload'].blank?
      payload = JSON.parse(job['payload'])
      if payload['created_from'] == 'API'
        {
          job_id: payload['job_id'],
          status: job['status'],
          flow: payload['name'],
          parameters: payload['parameters'],
          created_at: payload['created_at'],
          status_url: "/jobs/#{payload['job_id']}/status",
          messages_url: "/jobs/#{payload['job_id']}/messages",
          output_url: "/jobs/#{payload['job_id']}/output",
          errors: job['errors']
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
