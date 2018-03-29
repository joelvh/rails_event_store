require 'rom/sql'

module RubyEventStoreRomSql
  module Env
    class << self
      def run_migrations_for(gateway)
        gateway.run_migrations # (path: File.expand_path('../db/migrate', File.dirname(__FILE__)))
      end

      def build_container(database_uri = ENV['DATABASE_URL'], &block)
        ::ROM.container(:sql, database_uri, &block)
      end
  
      def setup(*args)
        build_container(*args) do |config|
          require_relative 'rom'
  
          config.register_relation(ROM::Events)
          config.register_relation(ROM::EventStreams)
          # config.relation(:events) do
          #   schema(:event_store_events, as: :events)
          #   auto_struct true
          # end
  
          # config.relation(:event_streams) do
          #   schema(:event_store_events_in_streams, as: :event_streams) do
          #     associations do
          #       belongs_to :event
          #     end
          #   end
  
          #   auto_struct true
          # end
        end
      end
    end
  end
end
