require 'ruby_event_store'
require_relative '../../support/helpers/rspec_defaults'
require_relative '../../support/helpers/mutant_timeout'
require_relative '../../support/helpers/protobuf_helper'
require 'support/correlatable'

OrderCreated = Class.new(RubyEventStore::Event)
ProductAdded = Class.new(RubyEventStore::Event)
TestEvent = Class.new(RubyEventStore::Event)

module TimestampEnrichment
  def with_timestamp(event, timestamp = Time.now.utc)
    event.metadata[:timestamp] ||= timestamp
    event
  end
  module_function :with_timestamp
end

module Subscribers
  class InvalidHandler
  end

  class ValidHandler
    def initialize
      @handled_events = []
    end
    attr_reader :handled_events

    def call(event)
      @handled_events << event
    end
  end
end

class ReverseYamlSerializer
  def self.load(value)
    YAML.load(value.reverse)
  end

  def self.dump(value)
    YAML.dump(value).reverse
  end
end

RSpec::Matchers.define :contains_ids do |expected_ids|
  match do |enum|
    @actual = enum.map(&:event_id)
    values_match?(expected_ids, @actual)
  end
  diffable
end
