require File.dirname(__FILE__) + '/../lib/spec'

class BddFramework
  def intuitive?
    true
  end
  
  def adopted_quickly?
    true
  end
end

context "BDD framework" do

  setup do
    @bdd_framework = BddFramework.new
  end

  specify "should be adopted quickly" do
    #this will fail because it reallly SHOULD be adopted quickly
    @bdd_framework.should_not_be_adopted_quickly
  end
  
  specify "should be intuitive" do
    @bdd_framework.should_be_intuitive
  end

end