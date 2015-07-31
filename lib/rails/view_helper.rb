module ActiveForm
  module ViewHelper
   
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

ActionView::Base.send(:include, ActiveForm::ViewHelper) if Object.const_defined?('ActionView')