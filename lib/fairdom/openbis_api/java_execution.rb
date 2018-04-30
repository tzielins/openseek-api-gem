require 'terrapin'
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
        output = Terrapin::CommandLine.new(command).run
        JSON.parse(output.strip)
      rescue Terrapin::ExitStatusError => exception
        raise OpenbisQueryException, exception.message
      end

      private

      def execute_command(options)
        "#{java_root_command} -#{query_object.command_option_key} {#{command_from_options(options)}}"
      end

      def command_from_options(options)
        options.collect do |key, value|
          "%#{key}%:%#{value.tr(' ', '+')}%"
        end.join("\,")
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
