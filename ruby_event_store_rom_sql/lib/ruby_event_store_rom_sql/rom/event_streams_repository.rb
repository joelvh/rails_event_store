module RubyEventStoreRomSql
  module ROM
    class EventStreamsRepository < ::ROM::Repository[:event_streams]
      def get_all_streams
        (["all"] + event_streams.order(:id).pluck(:stream))
          .uniq
          .map { |name| RubyEventStore::Stream.new(name) }
      end

      def detect_invalid_event_ids(event_ids)
        event_ids - event_streams.where(id: event_ids).pluck(:id)
      end

      def last_position_for(stream_name)
        event_streams.where(stream: stream_name).order("position DESC").limit(1).pluck(:position).first
      end

      def delete_events_for(stream_name)
        event_streams.where(stream: stream_name).command(:delete).call
      end

      # TODO: Replace with Sequel::Dataset#import(columns, values, opts) ?
      # See: http://www.rubydoc.info/github/jeremyevans/sequel/Sequel%2FDataset%3Aimport
      def import(events)
        event_streams.multi_insert(events)
      end

      ### Reader interface

    end
  end
end
