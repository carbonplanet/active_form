module ActiveForm
  module ControllerHelper
   
    def create_active_form(*args, &block)
      form = ActiveForm::compose(*args, &block)
      form.update_from_params(params)
      instance_variable_set("@#{form.name}", form)
    end
  
    def build_active_form(definition_name, *args, &block)
      form = ActiveForm::Definition::build(definition_name, *args, &block)
      form.update_from_params(params)
      instance_variable_set("@#{form.name}", form)
    end
   
  end
end

ActionController::Base.send(:include, ActiveForm::ControllerHelper) if Object.const_defined?('ActionController')