##
# Stub controller for testing helpers.

class HelperTestCaseController < ApplicationController

  attr_accessor :request, :url

  ##
  # Re-raise errors

  def rescue_action(e)
    raise e
  end

end

##
# HelperTestCase allows helpers to be easily tested.
#
# Original concept by Ryan Davis, original implementation by Geoff Grosenbach.

class Spec::Rails::HelperTestCase < Spec::Rails::FunctionalTestCase

  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::PrototypeHelper rescue nil # Rails 1.0 only

  ##
  # Automatically includes the helper module into the test sublcass.

  def setup
    @controller_class_name = 'HelperTestCaseController'
    super
    @controller.request = @request
    @controller.url = ActionController::UrlRewriter.new @request, {} # url_for
    
    ActionView::Helpers::AssetTagHelper::reset_javascript_include_default
  end

end


