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
      JAR_VERSION="S220"
      DEFAULT_PATH = File.dirname(__FILE__) + "/../jars/openseek-api-#{JAR_VERSION}.jar"
      AS_ENDPOINT = 'https://openbis-api.fair-dom.org/openbis/openbis'
      DSS_ENDPOINT = 'https://openbis-api.fair-dom.org/datastore_server'

      def query type, property, property_value
        command = query_command type, property, property_value
        read_with_open4 command
      end

      def query_command type, property, property_value
        command = @init_command
        command += " -t #{type.dump}"
        command += " -p #{property.dump}"
        command += " -pv #{property_value.dump}"
        command
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
          raise OpenbisQueryException.new(err_message)
        end

        JSON.parse(output.strip)
      end
    end

    class ApplicationServerQuery
      include Fairdom::OpenbisApi::Common

      def initialize(username, password, as_endpoint=nil, dss_endpoint=nil)
        as_endpoint ||= AS_ENDPOINT
        dss_endpoint ||= DSS_ENDPOINT
        @init_command = "java -cp #{DEFAULT_PATH} org.fairdom.ApplicationServerQuery"
        @init_command += " -ae #{as_endpoint}"
        @init_command += " -de #{dss_endpoint}"
        @init_command += " -u #{username.dump}"
        @init_command += " -pw #{password.dump}"
      end
    end

    class DataStoreQuery
      include Fairdom::OpenbisApi::Common

      def initialize(username, password, as_endpoint=nil, dss_endpoint=nil)
        as_endpoint ||= AS_ENDPOINT
        dss_endpoint ||= DSS_ENDPOINT
        @init_command = "java -cp #{DEFAULT_PATH} org.fairdom.DataStoreQuery"
        @init_command += " -ae #{as_endpoint}"
        @init_command += " -de #{dss_endpoint}"
        @init_command += " -u #{username.dump}"
        @init_command += " -pw #{password.dump}"
      end
    end
  end
end
