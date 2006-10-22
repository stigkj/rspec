module Spec
  module Expectations
    module ObjectExpectations
      def should
        Should::Should.new self
      end
    end
  end
end

class Object
  include Spec::Expectations::ObjectExpectations
  include Spec::Expectations::UnderscoreSugar
end

Object.handle_underscores_for_rspec!