module EventSourcery
  module EventProcessing
    module ErrorHandlers
      class ExponentialBackoffRetry
        include EventSourcery::EventProcessing::ErrorHandlers::ErrorHandler

        # The starting value for the retry interval used with {with_error_handling}.
        #
        # @api private
        DEFAULT_RETRY_INVERAL = 1

        # The maximum retry interval value to be used with {with_error_handling}.
        #
        # @api private
        MAX_RETRY_INVERVAL = 64

        def initialize(processor_name:)
          @processor_name = processor_name
          @retry_interval = DEFAULT_RETRY_INVERAL
        end

        # Will yield the block and attempt to retry in an exponential backoff.
        def with_error_handling
          yield
        rescue => error
          report_error(error)
          update_retry_interval(error)
          sleep(@retry_interval)
          retry
        end

        private

        def update_retry_interval(error)
          if error.instance_of?(EventSourcery::EventProcessingError)
            if @error_event_uuid == error.event.uuid
              @retry_interval *= 2 if @retry_interval < MAX_RETRY_INVERVAL
            else
              @error_event_uuid = error.event.uuid
              @retry_interval = DEFAULT_RETRY_INVERAL
            end
          else
            @retry_interval = DEFAULT_RETRY_INVERAL
          end
        end
      end
    end
  end
end
