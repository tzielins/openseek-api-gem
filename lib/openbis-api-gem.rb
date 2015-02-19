require 'rubygems'
require 'bundler/setup'

require "openbis-api-gem/version"
require 'open4'

module Fairdom
  module OpenbisApi
    JAR_VERSION="0.1.0"
    DEFAULT_PATH = File.dirname(__FILE__) + "/../jars/openbis-api-#{JAR_VERSION}.jar"


    def query type, id
      read_with_open4 type, id
    end

    def query_command type, id
      command = "java -jar #{DEFAULT_PATH}"
      command +=  " #{type}"
      command += " #{id}"
      command
    end

    private

    def read_with_open4 type, id
      output = ""
      err_message = ""
      command = query_command type, id
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
      end

      output.strip
    end
  end
end
