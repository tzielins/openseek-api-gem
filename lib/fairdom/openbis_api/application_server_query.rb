module Fairdom
  module OpenbisApi
    class ApplicationServerQuery
      include Fairdom::OpenbisApi::Common

      def initialize(as_endpoint, token)
        @init_command = java_root_command
        @init_command += " -endpoints {%as%:%#{as_endpoint}%\,%sessionToken%:%#{token}%}"
      end
    end
  end
end
