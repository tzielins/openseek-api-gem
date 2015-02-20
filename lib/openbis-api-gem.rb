require 'rubygems'
require 'bundler/setup'

require "openbis-api-gem/version"
require 'open4'
require 'json'

module Fairdom
  module OpenbisApi
    class OpenbisQueryException < Exception
    end

    class Query
      JAR_VERSION="0.1.0"
      DEFAULT_PATH = File.dirname(__FILE__) + "/../jars/openbis-api-#{JAR_VERSION}.jar"
      ENDPOINT = 'https://openbis-testing.fair-dom.org/openbis'

      def initialize(username, password, endpoint=nil)
        endpoint ||= ENDPOINT
        @init_command = "java -jar #{DEFAULT_PATH}"
        @init_command +=  " -e #{endpoint}"
        @init_command +=  " -u #{username}"
        @init_command +=  " -pw #{password}"
      end

      def query type, property, property_value
        command = query_command type, property, property_value
        read_with_open4 command
      end

      def query_command type, property, property_value
        command = @init_command
        command +=  " -t #{type}"
        command += " -p #{property}"
        command += " -pv #{property_value}"
        command
      end

      private

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
  end
end
