module Fairdom
  module OpenbisApi
    class DataStoreDownload
      include Fairdom::OpenbisApi::Common

      def initialize(dss_endpoint, token)
        @init_command = java_root_command
        @init_command += " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end

      def download(options)
        command = @init_command
        command += ' -download {'
        command += command_from_options options
        command += '}'
        read_with_open4 command
      end
    end
  end
end
