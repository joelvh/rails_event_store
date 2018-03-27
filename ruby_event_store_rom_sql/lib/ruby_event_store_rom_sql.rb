require 'rom/sql'
require 'ruby_event_store_rom_sql/event_repository'
require 'ruby_event_store_rom_sql/event_repository_reader'
require 'ruby_event_store_rom_sql/index_violation_detector'
require 'ruby_event_store_rom_sql/version'

module RubyEventStoreRomSql
  class << self
    def configure(database_uri = ENV['DATABASE_URL'], &block)
      ::ROM.container(:sql, database_uri, &block)
    end

    def setup(*args)
      configure(*args) do |config|
        require 'ruby_event_store_rom_sql/rom'

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
