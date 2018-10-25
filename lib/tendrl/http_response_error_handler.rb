module Tendrl
  class HttpResponseErrorHandler < StandardError
    attr_reader :status, :body

    EXCEPTION_MAPPING = {
      '/_tendrl/definitions' => {
        body: {
          errors: {
            message: 'Node definitions file not found.'
          }
        },
        status: 404
      },
      '/clusters' => {
        status: 200,
        body: { clusters: [] }
      },
      '/queue' => {
        status: 200,
        body: { jobs: [] }
      },
      '/clusters/definitions' => {
        status: 404,
        body: {
          errors: {
            message: 'Cluster definitions for cluster_id %s not found.'
          }
        }
      },
      '/clusters/id' => {
        status: 404,
        body: {
          errors: {
            message: 'Cluster with cluster_id %s not found.'
          }
        }
      },
      '/jobs/id' => {
        status: 404,
        body: {
          errors: {
            message: 'Job with job_id %s not found.'
          }
        }
      },
      'invalid_json' => {
        status: 400,
        body: {
          errors: {
            message: 'Invalid JSON received.'
          }
        }
      },
      'etcd_timeout' => {
        status: 408,
        body: {
          errors: {
            message: 'Service timeout'
          }
        }
      },
      'etcd_not_reachable' => {
        status: 503,
        body: {
          errors: {
            message: 'Service unavailable'
          }
        }
      },
      'gd2_api_error' => {
        status: 503,
        body: {
          errors: {
            message: 'GD2 API Error at: %s',
            details: true
          }
        }
      },
      'uncaught_exception' => {
        status: 500,
        body: {
          errors: {
            message: 'Internal server error'
          }
        }
      }
    }.freeze

    def initialize(error, cause: nil, object_id: nil, details: nil)
      @error = error
      @cause = cause
      @object_id = object_id
      @mapping = EXCEPTION_MAPPING[cause] || default_mapping
      @body = @mapping[:body]
      if @object_id
        @body[:errors][:message] = @body[:errors][:message] % [@object_id]
      end
      @body[:errors][:details] = @error if @body[:errors][:details]
      @status = @mapping[:status]
    end

    def default_mapping
      {
        body: {
          errors: {
            message: @error.message.to_s
          }
        },
        status: 404
      }
    end
  end
end
