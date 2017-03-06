require 'open4'
require 'json'

module Fairdom
  module OpenbisApi
    class JavaExecution
      attr_reader :query_object

      def initialize(query_object)
        @query_object = query_object
      end

      def execute(options)
        command = execute_command(options)
        output = ''
        err_message = ''
        status = Open4.popen4(command) do |_pid, _stdin, stdout, stderr|
          while (line = stdout.gets)
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

      private

      def execute_command(options)
        "#{java_root_command} -#{query_object.command_option_key} {#{command_from_options(options)}}"
      end

      def command_from_options(options)
        command = []
        options.each do |key, value|
          command << "%#{key}%:%#{value.tr(' ', '+')}%"
        end
        command.join("\,")
      end

      def java_root_command
        "java -jar #{jar_path} #{query_object.root_command_options}"
      end

      def jar_path
        File.join(File.dirname(__dir__), "../../jars/#{jar_file}")
      end

      def jar_file
        "openseek-api-#{Fairdom::OpenbisApi::JAR_VERSION}.jar"
      end
    end
  end
end
