module Spec
  module Runner
    class Context
      def before_context_eval
        inherit Spec::RailsPlugin::SpecTestCase
      end
      module RailsPluginClassMethods
        def fixture_path
          @fixture_path ||= RAILS_ROOT + '/spec/fixtures'
        end
        attr_writer :fixture_path
      end
      extend RailsPluginClassMethods

      # entry point into rspec
      # Keep it sync'ed!
      super_run = instance_method(:run)
      define_method :run do |reporter, dry_run|
        controller_name = @context_eval_module.instance_eval {@controller_name}

        setup_method = proc do
          setup_with_controller(controller_name)
        end
        setup_parts.unshift setup_method

        teardown_method = proc do
          teardown_with_controller
        end
        teardown_parts.unshift teardown_method
        super_run.bind(self).call(reporter, dry_run)
      end

      def setup_parts
        @context_eval_module.send :setup_parts
      end

      def teardown_parts
        @context_eval_module.send :teardown_parts
      end

    end
  end
end
