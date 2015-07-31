module ActiveForm
  module MerbControllerHelper
   
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

Merb::Controller.send(:include, ActiveForm::MerbControllerHelper)

module ActiveForm
  module MerbViewHelper
   
    def active_form(*args, &block)
      form = args.first.instance_of?(ActiveForm::Definition) ? args.shift : ActiveForm::Definition.build(*args)   
      if block_given?    
        if form.kind_of?(ActiveForm::Definition)
          concat(form.header, block.binding)
          yield(form)
          concat(form.footer, block.binding)
        end
      else
        form.to_html
      end
    end
   
  end
end

Merb::GlobalHelpers.send(:include, ActiveForm::MerbViewHelper)