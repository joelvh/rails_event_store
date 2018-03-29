module RubyEventStoreRomSql
  module ROM
    class EventsRepository < ::ROM::Repository[:events]
      # relations :event_streams
      commands :create

      ### Reader interface

      def has_event?(event_id)
        events.where(id: event_id).exist?
      end

      def last_stream_event(stream_name)
        backward_for(stream_name).first.event
      end

      def read_events_forward(stream_name, after_event_id, count)
        stream = forward_for(stream_name)

        unless after_event_id.equal?(:head)
          after_id = stream.where(event_id: after_event_id).one!.pluck(:id)
          stream = stream.where { id > after_id }
        end

        stream.limit(count).to_a.map(&:event)
      end

      def read_events_backward(stream_name, before_event_id, count)
        stream = backward_for(stream_name)
        
        unless before_event_id.equal?(:head)
          before_id = stream.where(event_id: before_event_id).one!.pluck(:id)
          stream = stream.where { id < before_id }
        end

        stream.limit(count).to_a.map(&:event)
      end

      def read_stream_events_forward(stream_name)
        forward_for(stream_name).to_a.map(&:event)
      end

      def read_stream_events_backward(stream_name, last_stream_event: false)
        backward_for(stream_name).to_a
      end

      def read_all_streams_forward(after_event_id, count)
        stream = forward_for(RubyEventStore::GLOBAL_STREAM, order: 'id ASC')

        unless after_event_id.equal?(:head)
          after_id = stream.where(event_id: after_event_id).one!.pluck(:id)
          stream = stream.where { id > after_id }
        end

        stream.limit(count).to_a.map(&:event)
      end

      def read_all_streams_backward(before_event_id, count)
        stream = backward_for(RubyEventStore::GLOBAL_STREAM, order: 'id DESC')

        unless before_event_id.equal?(:head)
          before_id = stream.where(event_id: before_event_id).one!.pluck(:id)
          stream = stream.where { id < before_id }
        end

        stream.limit(count).to_a.map(&:event)
      end

      def read_event(event_id)
        events.for_deserialization.fetch(event_id)
      # rescue ActiveRecord::RecordNotFound
      rescue ::ROM::TupleCountMismatchError
        raise RubyEventStore::EventNotFound.new(event_id)
      end

    private

      def forward_for(stream_name, order: 'position ASC, id ASC')
        event_streams.eager_load(event_streams.assoc(:event_for_deserialization)).where(stream: stream_name).order(order)
      end

      def backward_for(stream_name, order: 'position DESC, id DESC')
        event_streams.eager_load(event_streams.assoc(:event_for_deserialization)).where(stream: stream_name).order(order)
      end
    end
  end
end
