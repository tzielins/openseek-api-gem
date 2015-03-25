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
      JAR_VERSION="0.3.0"
      DEFAULT_PATH = File.dirname(__FILE__) + "/../jars/openbis-api-#{JAR_VERSION}.jar"
      ENDPOINT = 'https://openbis-testing.fair-dom.org/openbis'
      OPTION_FLAGS = {:type=>"-t",:attribute=>"-a",:attribute_value=>"-av",:property=>"-p",:property_value=>"-pv"}

      attr_reader :start_command

      def initialize(username, password, endpoint=nil)
        endpoint ||= ENDPOINT
        @start_command = "java -jar #{DEFAULT_PATH}"
        @start_command +=  " -e #{endpoint}"
        @start_command +=  " -u #{username.dump}"
        @start_command +=  " -pw #{password.dump}"
      end

      def query options
        command = query_command options
        read_with_open4 command
      end

      def query_command options



        command = start_command
        options.keys.each do |key|
          flag = OPTION_FLAGS[key]
          if flag
            command << " #{flag} #{options[key].dump}"
          else
            raise "Unknown option #{key}"
          end
        end
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
