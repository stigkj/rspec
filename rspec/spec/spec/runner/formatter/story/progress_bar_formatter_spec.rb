require File.dirname(__FILE__) + '/../../../../spec_helper.rb'
require 'spec/runner/formatter/story/progress_bar_formatter'

module Spec
  module Runner
    module Formatter
      module Story
        describe ProgressBarFormatter do
          before :each do
            # given
            @out = StringIO.new
            @tweaker = mock('tweaker')
            @tweaker.stub!(:tweak_backtrace)
            @options = mock('options')
            @options.stub!(:colour).and_return(false)
            @options.stub!(:backtrace_tweaker).and_return(@tweaker)
            @formatter = ProgressBarFormatter.new(@options, @out)
          end

          it 'should summarize the number of scenarios when the run ends' do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario2')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario3')
            @formatter.run_ended

            # then
            @out.string.should include('3 scenarios')
          end
          
          it 'should summarize the number of successful scenarios when the run ends' do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario2')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario3')
            @formatter.run_ended
          
            # then
            @out.string.should include('3 scenarios: 3 succeeded')
          end
          
          it 'should summarize the number of failed scenarios when the run ends' do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops' })
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario3', exception_from { raise RuntimeError, 'oops' })
            @formatter.run_ended
          
            # then
            @out.string.should include("3 scenarios: 1 succeeded, 2 failed")
          end
          
          it 'should end cleanly (no characters on the last line) with successes' do
            # when
            @formatter.run_started(1)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario')
            @formatter.run_ended
          
            # then
            @out.string.should =~ /\n\z/
          end
          
          it 'should end cleanly (no characters on the last line) with failures' do
            # when
            @formatter.run_started(1)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario', exception_from { raise RuntimeError, 'oops' })
            @formatter.run_ended
          
            # then
            @out.string.should =~ /\n\z/
          end
          
          it 'should end cleanly (no characters on the last line) with pending steps' do
            # when
            @formatter.run_started(1)
            @formatter.scenario_started(nil, nil)
            @formatter.step_pending(:then, 'do pend')
            @formatter.scenario_pending('story', 'scenario', exception_from { raise RuntimeError, 'oops' })
            @formatter.run_ended
          
            # then
            @out.string.should =~ /\n\z/
          end
          
          it "should push a green dot for a succeeded scenario" do
            @out.should_receive(:tty?).and_return(true)
            @options.should_receive(:colour).and_return(true)
            @formatter.scenario_succeeded('story', 'scenario')
            @out.string.should include("\e[32m.\e[0m")
          end
          
          it "should push a red F for a failed scenario" do
            @out.should_receive(:tty?).and_return(true)
            @options.should_receive(:colour).and_return(true)
            @formatter.scenario_failed('story', 'scenario', exception_from { raise RuntimeError, 'oops' })
            @out.string.should include("\e[31mF\e[0m")
          end
          
          it "should push a yellow P for a pending scenario" do
            @out.should_receive(:tty?).and_return(true)
            @options.should_receive(:colour).and_return(true)
            @formatter.scenario_pending('story', 'scenario', exception_from { raise RuntimeError, 'oops' })
            @out.string.should include("\e[33mP\e[0m")
          end
          
          it 'should summarize the number of pending scenarios when the run ends' do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_pending('story', 'scenario2', 'message')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_pending('story', 'scenario3', 'message')
            @formatter.run_ended
          
            # then
            @out.string.should include("3 scenarios: 1 succeeded, 0 failed, 2 pending")
          end
          
          it "should only count the first failure in one scenario" do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops' })
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops again' })
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario3', exception_from { raise RuntimeError, 'oops' })
            @formatter.run_ended
          
            # then
            @out.string.should include("3 scenarios: 1 succeeded, 2 failed")
          end
          
          it "should only count the first pending in one scenario" do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_pending('story', 'scenario2', 'because ...')
            @formatter.scenario_pending('story', 'scenario2', 'because ...')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_pending('story', 'scenario3', 'because ...')
            @formatter.run_ended
          
            # then
            @out.string.should include("3 scenarios: 1 succeeded, 0 failed, 2 pending")
          end
          
          it "should only count a failure before the first pending in one scenario" do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_pending('story', 'scenario2', exception_from { raise RuntimeError, 'oops' })
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops again' })
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario3', exception_from { raise RuntimeError, 'oops' })
            @formatter.run_ended
          
            # then
            @out.string.should include("3 scenarios: 1 succeeded, 1 failed, 1 pending")
          end
          
          it 'should produce details of the first failure each failed scenario when the run ends' do
            # when
            @formatter.run_started(3)
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_succeeded('story', 'scenario1')
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops2' })
            @formatter.scenario_failed('story', 'scenario2', exception_from { raise RuntimeError, 'oops2 - this one should not appear' })
            @formatter.scenario_started(nil, nil)
            @formatter.scenario_failed('story', 'scenario3', exception_from { raise RuntimeError, 'oops3' })
            @formatter.run_ended
          
            # then
            @out.string.should include("FAILURES:\n")
            @out.string.should include("1) story (scenario2) FAILED")
            @out.string.should include("RuntimeError: oops2")
            @out.string.should_not include("RuntimeError: oops2 - this one should not appear")
            @out.string.should include("2) story (scenario3) FAILED")
            @out.string.should include("RuntimeError: oops3")
          end
          
          it 'should produce details of each pending step when the run ends' do
            # when
            @formatter.run_started(2)
            @formatter.story_started('story 1', 'narrative')
            @formatter.scenario_started('story 1', 'scenario 1')
            @formatter.step_pending(:given, 'todo 1', [])
            @formatter.story_started('story 2', 'narrative')
            @formatter.scenario_started('story 2', 'scenario 2')
            @formatter.step_pending(:given, 'todo 2', [])
            @formatter.run_ended
          
            # then
            @out.string.should include("Pending Steps:\n")
            @out.string.should include("1) story 1 (scenario 1): todo 1")
            @out.string.should include("2) story 2 (scenario 2): todo 2")
          end
          
          it 'should not document a story title and narrative' do
            # when
            @formatter.story_started 'story', 'narrative'
          
            # then
            @out.string.should_not include("Story: story\n\n  narrative")
          end
          
          it 'should not document a scenario name' do
            # when
            @formatter.scenario_started 'story', 'scenario'
          
            # then
            @out.string.should_not include("\n\n  Scenario: scenario")
          end
          
          it 'should not document steps' do
            # when
            @formatter.step_succeeded :given, 'a context'
          
            # then
            @out.string.should_not include("Given a context")
          end

          it "should print nothing for collected_steps" do
            @formatter.collected_steps(['Given a $coloured $animal', 'Given a $n legged eel'])
            @out.string.should == ("")
          end
          
          it "should ignore messages it doesn't care about" do
            lambda {
              @formatter.this_method_does_not_exist
            }.should_not raise_error
          end
        end
      end
    end
  end
end
