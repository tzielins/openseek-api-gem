module Fairdom
  module OpenbisApi
    class DataStoreQuery
      include Fairdom::OpenbisApi::Common

      def initialize(dss_endpoint, token)
        @init_command = java_root_command
        @init_command += " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end
    end
  end
end
