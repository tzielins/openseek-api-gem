require 'fairdom/openbis_api/java_execution'

module Fairdom
  module OpenbisApi
    class OpenbisQuery
      attr_reader :token

      def initialize(token)
        @token = token
      end

      def query(options)
        execute(options)
      end

      def command_option_key
        'query'
      end

      private

      def execute(options)
        JavaExecution.new(self).execute(options)
      end
    end
  end
end
