class ControllerIsolationSpecController < ActionController::Base
  def some_action
    render :template => "/file/that/does/not/actually/exist"
  end
  
  def action_with_template
  end
  
  def action_with_specified_template
    render :template => "controller_isolation_spec/specified_template"
  end
  
  def action_with_errors_in_template
  end
end