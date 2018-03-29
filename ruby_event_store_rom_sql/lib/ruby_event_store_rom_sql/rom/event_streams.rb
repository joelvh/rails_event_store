module RubyEventStoreRomSql
  module ROM
    class EventStreams < ::ROM::Relation[:sql]
      schema(:event_store_events_in_streams, as: :event_streams, infer: true) do
        associations do
          belongs_to :events, as: :event, foreign_key: :event_id
          belongs_to :events, as: :event_for_deserialization, foreign_key: :event_id, view: :for_deserialization
          
          # primary_key :id, type: :Bignum
    
          # column :stream, String, null: false
          # column :position, Integer, null: true
    
          # if postgres
          #   column :event_id, :uuid, null: false, index: true
          # else
          #   column :event_id, String, null: false, index: true
          # end
    
          # column :created_at, :datetime, null: false, index: true
          
          # index %i[stream position], unique: true
          # index %i[stream event_id], unique: true
        end
      end

      struct_namespace ROM
      auto_struct true
    end
  end
end
