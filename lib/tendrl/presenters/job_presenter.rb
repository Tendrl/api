module JobPresenter

  class << self

    def single(raw_job)
      {
        job_id: raw_job['job_id'],
        integration_id: raw_job['integration_id'],
        status: raw_job['status'],
        flow: raw_job['flow'], 
        parameters: raw_job['parameters'],
        created_at: raw_job['created_at'],
        log: "/jobs/#{raw_job['job_id']}/logs?type=",
        log_types: ['all', 'info', 'debug', 'warn', 'error']
      }
    end

  end

end
