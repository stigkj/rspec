require 'spec/runner/formatter/html_formatter'

module Spec
  module Mate
    # Formats backtraces so they're clickable by TextMate
    class TextMateFormatter < Spec::Runner::Formatter::HtmlFormatter
      def backtrace_line(line)
        line.gsub(/([^:]*\.rb):(\d*)/) do
          "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
        end
      end
    end
  end
end