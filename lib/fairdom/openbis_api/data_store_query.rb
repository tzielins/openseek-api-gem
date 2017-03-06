

module Fairdom
  module OpenbisApi
    class DataStoreQuery < OpenbisQuery
      attr_reader :dss_endpoint

      def initialize(dss_endpoint, token)
        super(token)
        @dss_endpoint = dss_endpoint
      end

      def root_command_options
        " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end
    end
  end
end
