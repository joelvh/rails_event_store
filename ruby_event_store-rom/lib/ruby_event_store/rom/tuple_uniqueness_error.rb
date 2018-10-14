module RubyEventStore
  module ROM
    class TupleUniquenessError < StandardError
      class << self
        def for_event_id(event_id)
          new(
            "Uniquness violated for event_id (#{event_id.inspect})",
            event_id: event_id
          )
        end

        def for_stream_and_event_id(stream_name, event_id)
          new(
            "Uniquness violated for stream (#{stream_name.inspect}) and event_id (#{event_id.inspect})",
            event_id: event_id,
            stream_name: stream_name
          )
        end

        def for_stream_and_position(stream_name, position)
          new(
            "Uniquness violated for stream (#{stream_name.inspect}) and position (#{position.inspect})",
            stream_name: stream_name,
            position: position
          )
        end
      end
      
      attr_reader :event_id, :stream_name, :position
      
      def initialize(message, event_id: nil, stream_name: nil, position: nil)
        @event_id    = event_id
        @stream_name = stream_name
        @position    = position

        super(message)
      end
    end
  end
end
