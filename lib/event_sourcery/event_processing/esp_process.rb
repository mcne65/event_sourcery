module EventSourcery
  module EventProcessing
    class ESPProcess
      def initialize(event_processor:,
                     event_source:,
                     subscription_master: EventStore::SignalHandlingSubscriptionMaster.new)
        @event_processor = event_processor
        @event_source = event_source
        @subscription_master = subscription_master
      end
      
      # This will start the Event Stream Processor which will subscribe
      # to the event stream source.
      def start
        name_process
        error_handler.with_error_handling do
          EventSourcery.logger.info("Starting #{processor_name}")
          subscribe_to_event_stream
          EventSourcery.logger.info("Stopping #{@event_processor.processor_name}")
        end
      end

      private

      def processor_name
        @event_processor.processor_name.to_s
      end

      def error_handler
        @error_handler ||= EventSourcery.config.error_handler_class.new(processor_name: processor_name)
      end

      def name_process
        Process.setproctitle(@event_processor.class.name)
      end

      def subscribe_to_event_stream
        @event_processor.subscribe_to(@event_source,
                                      subscription_master: @subscription_master)
      end
    end
  end
end
