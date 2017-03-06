module Fairdom
  module OpenbisApi
    class DataStoreDownload < DataStoreQuery
      def download(options)
        execute(options)
      end

      def command_option_key
        'download'
      end
    end
  end
end
