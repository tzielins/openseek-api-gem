module Fairdom
  module OpenbisApi
    class ApplicationServerQuery < OpenbisQuery
      attr_reader :as_endpoint

      def initialize(as_endpoint, token)
        super(token)
        @as_endpoint = as_endpoint
      end

      def root_command_options
        " -endpoints {%as%:%#{as_endpoint}%\,%sessionToken%:%#{token}%}"
      end
    end
  end
end
