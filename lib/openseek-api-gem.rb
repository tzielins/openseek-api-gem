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
    end

    class Authentication
      include Fairdom::OpenbisApi::Common

      def initialize(username, password, as_endpoint=nil)
        as_endpoint ||= AS_ENDPOINT
        @init_command = "java -cp #{DEFAULT_PATH} org.fairdom.Authentication"
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
        @init_command = "java -cp #{DEFAULT_PATH} org.fairdom.ApplicationServerQuery"
        @init_command += " -endpoints {%as%:%#{as_endpoint}%\,%sessionToken%:%#{token}%}"

      end

      def query entity_type, query_type, property, property_value
        command = query_command entity_type, query_type, property, property_value
        read_with_open4 command
      end

      def query_command entity_type, query_type, property, property_value
        command = @init_command
        command += " -query {"
        command += "%entityType%:%#{entity_type}%\,"
        command += "%queryType%:%#{query_type}%\,"
        command += "%property%:%#{property}%\,"
        command += "%propertyValue%:%#{property_value}%"
        command += "}"
        command

      end
    end

    class DataStoreQuery
      include Fairdom::OpenbisApi::Common

      def initialize(dss_endpoint=nil, token)
        dss_endpoint ||= DSS_ENDPOINT
        @init_command = "java -cp #{DEFAULT_PATH} org.fairdom.DataStoreQuery"
        @init_command += " -endpoints {%dss%:%#{dss_endpoint}%\,%sessionToken%:%#{token}%}"
      end

      def query entity_type, query_type, property, property_value
        command = query_command entity_type, query_type, property, property_value
        read_with_open4 command
      end

      def query_command entity_type, query_type, property, property_value
        command = @init_command
        command += " -query {"
        command += "%entityType%:%#{entity_type}%\,"
        command += "%queryType%:%#{query_type}%\,"
        command += "%property%:%#{property}%\,"
        command += "%propertyValue%:%#{property_value}%"
        command += "}"
        command

      end
    end
  end
end
