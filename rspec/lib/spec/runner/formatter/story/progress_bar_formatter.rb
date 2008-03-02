require 'spec/runner/formatter/base_text_formatter'

module Spec
  module Runner
    module Formatter
      module Story
        class ProgressBarFormatter < BaseTextFormatter
          def initialize(options, where)
            super
            @successful_scenario_count = 0
            @pending_scenario_count = 0
            @failed_scenarios = []
            @pending_steps = []
          end
          
          def run_started(count)
            @count = count
            @start_time = Time.now
          end

          def story_started(title, narrative)
            @current_story_title = title
          end

          def scenario_started(story_title, scenario_name)
            @current_scenario_name = scenario_name
            @scenario_already_failed = false
          end

          def scenario_succeeded(story_title, scenario_name)
            @output.print green('.')
            @output.flush
            @successful_scenario_count += 1
          end

          def scenario_failed(story_title, scenario_name, err)
            @options.backtrace_tweaker.tweak_backtrace(err)
            @output.print red('F')
            @output.flush
            @failed_scenarios << [story_title, scenario_name, err] unless @scenario_already_failed
            @scenario_already_failed = true
          end

          def scenario_pending(story_title, scenario_name, msg)
            @output.print yellow('P')
            @output.flush
            @pending_scenario_count += 1 unless @scenario_already_failed
            @scenario_already_failed = true
          end

          def run_ended
            @output.puts
            
            unless @pending_steps.empty?
              @output.puts "\nPending Steps:"
              @pending_steps.each_with_index do |pending, i|
                story_name, scenario_name, msg = pending
                @output.puts "#{i+1}) #{story_name} (#{scenario_name}): #{msg}"
              end
            end
            
            unless @failed_scenarios.empty?
              @output.print "\nFAILURES:\n"
              @failed_scenarios.each_with_index do |failure, i|
                title, scenario_name, err = failure
                @output.puts
                @output.puts red("#{i+1}) #{title} (#{scenario_name}) FAILED")
                @output.puts red("#{err.class}: #{err.message}")
                @output.puts err.backtrace.join("\n")
              end
            end

            @output.puts "\nFinished in #{duration} seconds"
            summary = "\n#@count scenarios: #@successful_scenario_count succeeded, #{@failed_scenarios.size} failed, #@pending_scenario_count pending"

            if @failed_scenarios.any?
              @output.puts red(summary)
            elsif @pending_scenario_count > 0
              @output.puts yellow(summary)
            else
              @output.puts green(summary)
            end
          end

          def step_pending(type, description, *args)
            @pending_steps << [@current_story_title, @current_scenario_name, description]
          end

          def method_missing(sym, *args, &block) #:nodoc:
            # noop - ignore unknown messages
          end

        private
          
          def duration
            Time.now - @start_time
          end
        end
      end
    end
  end
end
