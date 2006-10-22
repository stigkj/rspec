require File.dirname(__FILE__) + '/../../../spec_helper.rb'

context "should_be_an_instance_of" do
  specify "should fail when target is not specified class" do
    lambda do
      5.should_be_an_instance_of(Integer)
    end.should_fail
  end

  specify "should pass when target is specified class" do
    lambda do
      5.should_be_an_instance_of(Fixnum)
    end.should_pass
  end
end