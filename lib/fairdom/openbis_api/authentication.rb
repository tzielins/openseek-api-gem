module Fairdom
  module OpenbisApi
    class Authentication
      include Fairdom::OpenbisApi::Common

      def initialize(username, password, as_endpoint)
        @init_command = java_root_command
        @init_command += " -account {%username%:%#{username}%\,%password%:%#{password}%}"

        @init_command += " -endpoints {%as%:%#{as_endpoint}%}"
      end

      def login
        command = @init_command
        read_with_open4 command
      end
    end
  end
end
