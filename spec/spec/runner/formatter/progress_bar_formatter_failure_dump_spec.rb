require File.dirname(__FILE__) + '/../../../spec_helper.rb'

module Spec
module Runner
module Formatter
context "ProgressBarFormatterFailureDump" do
    setup do
        @io = StringIO.new
        @reporter = Reporter.new(ProgressBarFormatter.new(@io), QuietBacktraceTweaker.new)
        @reporter.add_context("context")
      
    end
    specify "should add spacing between sections" do
      
        error=Spec::Expectations::ExpectationNotMetError.new("message")
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "spec")
        @reporter.dump
        @io.string.should_match(/\nF\n\n1\)\nSpec::Expectations::ExpectationNotMetError in 'context spec'\nmessage\n\/a\/b\/c\/d\/e.rb:34:in `spec'\n\nFinished in /)
      
    end
    specify "should end with line break" do
      
        error=Spec::Expectations::ExpectationNotMetError.new("message")
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "spec")
        @reporter.dump
        @io.string.should_match(/\n\z/)
      
    end
    specify "should include context and setup in backtrace if error in setup" do
      
        error=RuntimeError.new
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "setup")
        @reporter.dump
        @io.string.should_match(/RuntimeError in 'context spec'/)
        @io.string.should_match(/in `setup'/)
      
    end
    specify "should include context and spec name in backtrace if error in spec" do
      
        error=RuntimeError.new("message")
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "spec")
        @reporter.dump
        @io.string.should_match(/RuntimeError in 'context spec'/)
        @io.string.should_match(/:in `spec'/)
      
    end
    specify "should include context and teardown in backtrace if error in teardown" do
      
        error=RuntimeError.new
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "teardown")
        @reporter.dump
        @io.string.should_match(/RuntimeError in 'context spec'/)
        @io.string.should_match(/in `teardown'/)
      
    end
    specify "should include informational header" do
      
        error=Spec::Expectations::ExpectationNotMetError.new("message")
        set_backtrace(error)
        @reporter.spec_finished("spec", error, "spec")
        @reporter.dump
        @io.string.should_match(/^Spec::Expectations::ExpectationNotMetError in 'context spec'/)
      
    end
    def set_backtrace  (error)
      error.set_backtrace(["/a/b/c/d/e.rb:34:in `__instance_exec'"])
    end
  
end
end
end
end