module RubyEventStoreRomSql
  module ROM
    class Events < ::ROM::Relation[:sql]
      schema(:event_store_events, as: :events, infer: true) do
        associations do
          has_many :event_streams
        end
        # if postgres
        #   column :id, :uuid, default: Sequel.function(:gen_random_uuid), primary_key: true
        # else
        #   column :id, String, size: 36, null: false, primary_key: true
        # end
  
        # column :event_type, String, null: false
        # column :metadata, String, text: true
        # column :data, String, text: true, null: false
        # column :created_at, :datetime, null: false, index: true
  
        # if sqlite # TODO: Is this relevant without ActiveRecord?
        #   index :id, unique: true
        # end
      end

      struct_namespace ROM
      auto_struct true

      def for_deserialization
        rename(id: :event_id).select_append(:id)
      end
    end
  end
end
