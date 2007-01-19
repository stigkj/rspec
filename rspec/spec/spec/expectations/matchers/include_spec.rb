require File.dirname(__FILE__) + '/../../../spec_helper.rb'

context "target.should include(expected)" do
  specify "should pass if target includes expected" do
    [1,2,3].should include(3)
  end

  specify "should fail if target does not include expected" do
    lambda {
      [1,2,3].should include(4)
    }.should_fail_with "expected [1, 2, 3] to include 4"
  end
end

context "target.should_not include(expected)" do
  specify "should pass if target does not include expected" do
    [1,2,3].should_not include(4)
  end

  specify "should fail if target includes expected" do
    lambda {
      [1,2,3].should_not include(3)
    }.should_fail_with "expected [1, 2, 3] to not include 3"
  end
end