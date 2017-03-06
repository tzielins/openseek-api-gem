require 'open4'
require 'json'

module Fairdom
  module OpenbisApi
    class OpenbisQuery
      JAR_VERSION = '0.9'.freeze
      JAR_PATH = File.join(File.dirname(__dir__), "../../jars/openseek-api-#{JAR_VERSION}.jar")

      attr_reader :token

      def initialize(token)
        @token = token
      end

      def query(options)
        execute(options)
      end

      private

      def execute_command(options)
        "#{java_root_command} -#{command_option_key} {#{command_from_options(options)}}"
      end

      def command_from_options(options)
        command = []
        options.each do |key, value|
          command << "%#{key}%:%#{value.tr(' ', '+')}%"
        end
        command.join("\,")
      end

      def execute(options)
        command = execute_command(options)
        output = ''
        err_message = ''
        status = Open4.popen4(command) do |_pid, _stdin, stdout, stderr|
          while (line = stdout.gets) != nil
            output << line
          end
          stdout.close

          until (line = stderr.gets).nil?
            err_message << line
          end
          stderr.close
        end

        if status.to_i != 0
          raise OpenbisQueryException, output + ' ' + err_message
        end

        JSON.parse(output.strip)
      end

      # the root of the command call, without the options
      def java_root_command
        "java -jar #{JAR_PATH} #{root_command_options}"
      end

      def command_option_key
        'query'
      end
    end
  end
end
