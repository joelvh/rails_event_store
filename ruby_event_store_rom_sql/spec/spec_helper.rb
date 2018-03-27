require 'ruby_event_store_rom_sql'
require 'support/rspec_defaults'

ENV['DATABASE_URL']  ||= 'sqlite:db.sqlite3'

module SchemaHelper
  def rom
    ROM.container(:sql, ENV['DATABASE_URL'])
  end

  def rom_db
    rom.gateways[:default]
  end

  def establish_database_connection
  end

  def load_database_schema
    # drop_database
    rom_db.run_migrations(path: File.expand_path('../db/migrate', File.dirname(__FILE__)))
    puts "tables: #{rom_db.connection.tables.inspect}"
    RubyEventStoreRomSql.setup
  end

  def drop_database
    rom_db.connection.drop_table?('event_store_events')
    rom_db.connection.drop_table?('event_store_events_in_streams')
  end

  def close_database_connection
    rom_db.disconnect
  end
end

RSpec.configure do |config|
  config.failure_color = :magenta
end
