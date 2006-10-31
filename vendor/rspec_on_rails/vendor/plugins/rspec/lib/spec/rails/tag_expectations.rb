module Spec
  module Rails
    module TagExpectations
      def should_have_tag(*opts)
        raise_rspec_error(" should include ", opts.inspect) if find_tag(*opts).nil?
      end

      def should_not_have_tag(*opts)
        raise_rspec_error(" should not include ", opts.inspect) unless find_tag(*opts).nil?
      end

      private 

      def raise_rspec_error(message, *opts)
        Kernel::raise(Spec::Expectations::ExpectationNotMetError.new(self + message + opts.inspect))
      end

      def find_tag(*opts)
        opts = OptsMerger.new(opts).merge(:tag)
        unless opts[:tag] =~ /^\w+$/
          message = %-

SyntaxError in should_have_tag(tag, *opts)
* tag should be the name of the tag (like 'div', or 'select' without '<' or '>')
* opts should be a Hash of key value pairs

-
          raise SyntaxError.new(message)
        end
          
        HTML::Document.new(self).find(opts)
      end
    end
  end
end