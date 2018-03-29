require 'ruby_event_store/repository'

module RubyEventStoreRomSql
  class EventRepository
    include RubyEventStore::Repository

    def initialize(rom: RubyEventStoreRomSql.env, mapper: RubyEventStore::Mappers::Default.new)
      @rom           = rom
      @events        = ROM::EventsRepository.new(rom)
      @event_streams = ROM::EventStreamsRepository.new(rom)
      @mapper        = mapper
    end

    def append_to_stream(event_ids, stream_name, expected_version)
      add_to_stream(event_ids, stream_name, expected_version, true) do |event|
        serialized_event = build_event_record(event)
        puts "serialized_event: #{serialized_event.inspect}"
        @events.create(serialized_event)
        event.event_id
      end
    end

    def link_to_stream(event_ids, stream_name, expected_version)
      @event_streams.detect_invalid_event_ids(normalize_to_array(event_ids)).each do |id|
        raise RubyEventStore::EventNotFound.new(id)
      end
      event_ids = normalize_to_array(event_ids)
      add_to_stream(event_ids, stream_name, expected_version, nil) do |event_id|
        event_id
      end
    end

    def delete_stream(stream_name)
      @event_streams.delete_events_for(stream_name)
    end

    def has_event?(event_id)
      @events.has_event?(event_id)
    end

    def last_stream_event(stream_name)
      deserialize @events.last_stream_event(stream_name)
    end

    def read_events_forward(stream_name, after_event_id, count)
      deserialize @events.read_events_forward(stream_name, after_event_id, count)
    end

    def read_events_backward(stream_name, before_event_id, count)
      deserialize @events.read_events_backward(stream_name, before_event_id, count)
    end

    def read_stream_events_forward(stream_name)
      deserialize @events.read_stream_events_forward(stream_name)
    end

    def read_stream_events_backward(stream_name)
      deserialize @events.read_stream_events_backward(stream_name)
    end

    def read_all_streams_forward(after_event_id, count)
      deserialize @events.read_all_streams_forward(after_event_id, count)
    end

    def read_all_streams_backward(before_event_id, count)
      deserialize @events.read_all_streams_backward(before_event_id, count)
    end

    def read_event(event_id)
      deserialize @events.read_event(event_id)
    end

    def get_all_streams
      @event_streams.get_all_streams
    end

    def add_metadata(event, key, value)
      @mapper.add_metadata(event, key, value)
    end

    private

    def append(event_ids, stream_name, expected_version, include_global, &to_event_id)
      created_at = Time.now.utc
      # @event_streams.transaction(savepoint: true) do
        in_stream = event_ids.flat_map.with_index do |event_id, index|
          position = compute_position(expected_version, index)
          event_id = to_event_id.call(event_id)

          collection = []
          collection.unshift(
            stream: RubyEventStore::GLOBAL_STREAM,
            position: nil,
            event_id: event_id,
            created_at: created_at
          ) if include_global

          collection.unshift(
            stream:   stream_name,
            position: position,
            event_id: event_id,
            created_at: created_at
          ) unless stream_name.eql?(RubyEventStore::GLOBAL_STREAM)

          collection
        end

        @event_streams.import(in_stream)
      # end
      self
    # rescue ActiveRecord::RecordNotUnique => e
    rescue Sequel::UniqueConstraintViolation => e
      raise_error(e)
    end

    def raise_error(e)
      raise RubyEventStore::EventDuplicatedInStream if detect_index_violated(e.message)
      raise RubyEventStore::WrongExpectedEventVersion
    end

    def last_position_for(stream_name)
      @event_streams.last_position_for(stream_name)
    end

    def detect_index_violated(message)
      IndexViolationDetector.new.detect(message)
    end

    def build_event_record(event)
      serialized_record = @mapper.event_to_serialized_record(event)
      {
        id:         serialized_record.event_id,
        data:       serialized_record.data,
        metadata:   serialized_record.metadata,
        event_type: serialized_record.event_type,
        created_at: Time.now.utc
      }
    end

    def deserialize(events)
      mapped = Array(events).map(&@mapper.method(:serialized_record_to_event))
      events.is_a?(Enumerable) ? mapped : mapped.first
    end
  end
end
