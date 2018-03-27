require 'rom-repository'

module RubyEventStoreRomSql
  module ROM
    class Events < ::ROM::Relation[:sql]
      schema(:event_store_events, as: :events, infer: true)

      struct_namespace ROM
      auto_struct true
    end

    class EventStreams < ::ROM::Relation[:sql]
      schema(:event_store_events_in_streams, as: :event_streams, infer: true) do
        associations do
          belongs_to :event
        end
      end

      struct_namespace ROM
      auto_struct true
    end
  
    class EventsRepository < ::ROM::Repository[:events]
    end
  
    class EventStreamsRepository < ::ROM::Repository[:event_streams]
    end

    class Event < ::ROM::Struct
    end

    class EventStream < ::ROM::Struct
    end
  end
end
