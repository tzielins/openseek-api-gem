require 'rubygems'
require 'bundler/setup'

require "openseek-api-gem/version"
require 'open4'
require 'json'

module Fairdom
  module OpenbisApi
    class OpenbisQueryException < Exception
    end

    module Common
      JAR_VERSION="0.6"
      JAR_PATH = File.dirname(__FILE__) + "/../jars/openseek-api-#{JAR_VERSION}.jar"
      AS_ENDPOINT = 'https://openbis-api.fair-dom.org/openbis/openbis'
      DSS_ENDPOINT = 'https://openbis-api.fair-dom.org/datastore_server'
      OPTION_FLAGS = {:entityType=>"",:queryType=>"",:attribute=>"",:attributeValue=>"",:property=>"",:propertyValue=>"",
                      :downloadType=>"",:permID=>"",:source=>"",:dest=>""}

      attr_reader :init_command

      def query options
        command = @init_command
        command += " -query {"
        command += command_from_options options
        command += "}"
        read_with_open4 command
      end

      def command_from_options options
        command = []
        options.keys.each do |key|
          value = options[key].gsub(" ", "+")
          command << "%#{key}%:%#{value}%"
        end
        command.join("\,")
      end

      def read_with_open4 command
        output = ""
        err_message = ""
        status = Open4::popen4(command) do |pid, stdin, stdout, stderr|
          while ((line = stdout.gets) != nil) do
            output << line
          end
          stdout.close

          while ((line=stderr.gets)!= nil) do
            err_message << line
          end
          stderr.close
        end

        if status.to_i != 0
          raise OpenbisQueryException.new(output + " " + err_message)
        end

        JSON.parse(output.strip)
      end

      #the root of the command call, without the options
      def java_root_command
        "java -jar #{JAR_PATH}"
      end
    end

    class Authentication
      include Fairdom::OpenbisApi::Common

      def initialize(username, password, as_endpoint=nil)
        as_endpoint ||= AS_ENDPOINT
        @init_command = java_root_command
        @init_command += " -account {%username%:%#{username}%\,%password%:%#{password}%}"

        @init_command += " -endpoints {%as%:%#{as_endpoint}%}"
      end

      def login
        command = @init_command
        read_with_open4 command
      end
    end

    class ApplicationServerQuery
      include Fairdom::OpenbisApi::Common

      def initialize(as_endpoint=nil, token)
        as_endpoint ||= AS_ENDPOINT
        @init_command = java_root_command
        @init_command += " -endpoints {%as%:%#{as_endpoint}%\,%sessionToken%:%#{token}%}"

      end
    end

    class DataStoreQuery
      include Fairdom::OpenbisApi::Common

      def initialize(dss_endpoint=nil, token)
        dss_endpoint ||= DSS_ENDPOINT
        @init_command = java_root_command
        @init_command += " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end
    end

    class DataStoreDownload
      include Fairdom::OpenbisApi::Common

      def initialize(dss_endpoint=nil, token)
        dss_endpoint ||= DSS_ENDPOINT
        @init_command = java_root_command
        @init_command += " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end

      def download options
        command = @init_command
        command += " -download {"
        command += command_from_options options
        command += "}"
        read_with_open4 command
      end
    end
  end
end
