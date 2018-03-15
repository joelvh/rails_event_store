module RubyEventStore
  class NewClient

    def initialize(repository:)
      @repository = repository
      @old_client = Client.new(repository: repository)
    end

    def read_stream_events_forward(stream_name)
      read.stream(stream_name).forward.each.to_a
    end

    def publish_events(*args, **kwargs)
      @old_client.publish_events(*args, **kwargs)
    end

    private

    def read
      Specification.new(@repository)
    end

    class Specification

      def initialize(repository)
        @repository = repository
      end

      def stream(stream_name)
        @stream_name = stream_name
        self
      end

      def forward
        self
      end

      def each
        @repository.read_events_forward(@stream_name, :head, 1)
      end

    end

  end
end

