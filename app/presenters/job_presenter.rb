module JobPresenter
  class << self
    def single(job)
      payload = job['payload']
      return if job['payload'].blank? || payload['created_from'] != 'API'
      {
        job_id: job['job_id'],
        status: job['status'],
        flow: payload['name'] || (payload['run'] && payload['run'].split('.').last),
        parameters: payload['parameters'],
        created_at: payload['created_at'],
        updated_at: job['updated_at'],
        status_url: "/jobs/#{job['job_id']}/status",
        messages_url: "/jobs/#{job['job_id']}/messages",
        output_url: "/jobs/#{job['job_id']}/output",
        errors: job['errors']
      }
    end

    def list(jobs)
      jobs.map do |job|
        single(job)
      end.compact
    end

    def list_by_integration_id(jobs, integration_id)
      jobs.map do |job|
        next if job['payload'].blank?
        if job['payload']['parameters']['TendrlContext.integration_id'] == integration_id
          single(job)
        end
      end.compact
    end
  end
end
