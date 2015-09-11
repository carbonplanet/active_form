module ActiveForm::Mixins::ContainerMethods

  def self.included(base)
    base.send(:include, ActiveForm::Mixins::LoaderMethods)
    base.send(:include, Enumerable)
    base.send(:include, ElementMethods)
    base.send(:extend,  ClassMethods)
  end

  def validated?
    submitted? && validate
  end

  def submitted?
    not get_elements_of_type(:submit).all?(&:blank?)
  end
  alias :sent? :submitted?

  def get_bound_value(name)
    self.element_value.bound_value(name) rescue nil
  end

  def set_bound_value(name, value)
    self.element_value.bound_value(name, value) rescue nil
  end

  def bound_value?(name)
    self.element_value.bound_value?(name)
  end

  def export_value(values = ActiveForm::Values.new)
    elements.inject(values) do |vals, elem|
      if elem.group.blank?
        vals[elem.name] = elem.export_value
      else
        if elem.element_type == :radio
          vals[elem.group] ||= nil
          vals[elem.group] = elem.export_value unless elem.blank?
        else
          vals[elem.group] ||= []
          vals[elem.group] << elem.export_value unless elem.blank?
        end
      end
      vals
    end
  end
  alias :export_values :export_value

  def update_value(value, force = false)
    if self.contained?
      self.element_value = value
    else
      if value.respond_to?(:key?) && !value.empty?
        elements.each do |e|
          e.update_value(value[e.name] || e.default_value) if force || value.key?(e.name) || e.respond_to?(:checked?)
        end
      else
        self.element_value = default_value
      end
      self.element_value
    end
  end
  alias :update_values :update_value

  def update_from_params(params, force = false)
    if params.respond_to?(:key?) && !params.empty?
      value = ActiveForm::Values.new(params) rescue default_value
      value = (value[self.name] || value[self.name.to_s] || default_value) unless self.contained?
      elements.each do |e|
        e.update_from_params(value[e.name] || e.default_value) if force || value.key?(e.name) || e.respond_to?(:checked?)
      end
    else
      self.element_value = default_value
    end
    self.element_value
  end
  alias :update_values_from_params :update_from_params
  alias :params= :update_from_params

  def label
    return (localize(nil, 'label') || @label) if localized?
    @label
  end

  def title
    return (localize(nil, 'title') || attributes[:title]) if localized?
    attributes[:title]
  end

  def description
    return (localize(nil, 'description') || @description) if localized?
    @description
  end

  def define_localizer(prc = nil, &block)
    @localizer = (block_given? ? block : prc)
  end
  alias :localizer= :define_localizer

  def localize(*args)
    @localizer.call(identifier, *args) if localized?
  end

  def localized?
    (@localizer ||= nil).kind_of?(Proc)
  end

  def localizer
    localized? ? @localizer : nil
  end

  module ElementMethods

    def each(&block)
      elements.each(&block)
    end

    def recurse(&block)
      elements.each do |elem|
        block.call(elem)
        elem.recurse(&block) if elem.container? && elem.elements?
      end
    end

    def append_sections(*defnames)
      index = defnames.last.kind_of?(Integer) ? defnames.pop : -1
      sections = defnames.inject([]) do |ary, name|
        args = name.kind_of?(Array) ? name : [name]
        section = ActiveForm::Element::Section::build(*args)
        ary << section unless section.nil?
        ary
      end
      insert_elements(sections, index)
    end
    alias :append_section :append_sections

    def define_form(*args, &block)
      args.unshift(self)
      form = ActiveForm::compose(*args, &block)
      insert_element(form, false) && form
    end

    def define_section(*args, &block)
      define_element(:section, *args, &block)
    end
    alias :section :define_section

    def define_builder(*args, &block)
      define_element(:builder, *args, &block)
    end
    alias :builder :define_builder
    alias :html :define_builder

    def define_widget(type, *args, &block)
      args.unshift(self)
      element = ActiveForm::Widget::build(type, *args, &block)
      insert_element(element, false) && element unless element.nil?
      element
    end

    def define_element(type, *args, &block)
      args.unshift(self)
      element = ActiveForm::Element::build(type, *args, &block)
      insert_element(element, false) && element unless element.nil?
      element
    end
    alias :define_element_at_bottom :define_element

    def define_element_at(index, type, *args, &block)
      args.unshift(self)
      element = ActiveForm::Element::build(type, *args, &block)
      insert_element(element, index, false) && element unless element.nil?
      element
    end

    def define_element_at_top(type, *args, &block)
      args.unshift(self)
      element = ActiveForm::Element::build(type, *args, &block)
      insert_element(element, 0, false) && element unless element.nil?
      element
    end

    def insert_element(*elem)
      insert_elements(*elem).last
    end

    def insert_elements(*elems)
      elems.flatten!
      do_registration = elems.last === false ? elems.pop : true
      index = elems.last.kind_of?(Integer) ? elems.pop : -1
      first_index = index < 0 ? elements.length + 1 + index : index
      first_index = 0 if first_index < 0
      elems.each_with_index do |elem, i|
        if elem.kind_of?(Symbol)
          elem = ActiveForm::Element::Section::build(elem)
        elsif elem.kind_of?(String)
          elem = ActiveForm::Element::build(:builder, :html => elem)
        end
        if ActiveForm::Element::element?(elem)
          elem.register_container(self) if do_registration
          elements.insert(first_index + i, elem)
        end
      end
      reindex_name_to_index_lookup!
      elements
    end
    alias :append_form :insert_elements
    alias :<< :insert_elements

    def insert_element_at_top(*elems)
      insert_elements(*(elems << 0)).last
    end

    def insert_elements_at_top(*elems)
      insert_elements(*(elems << 0))
    end

    def update_elements(*args)
      attrs = args.last.kind_of?(Hash) ? args.pop : {}
      elem_names = args.length > 0 ? args.flatten : self.element_names
      elem_names.each do |elem_name|
        name = ActiveForm::symbolize_name(elem_name)
        if element_exists?(name)
          if self[name].respond_to?(:update_elements)
            self[name].update_elements(attrs.dup)
          else
            self[name].update(attrs.dup)
          end
        end
      end
    end

    def elements
      @elements ||= []
      @elements
    end

    def elements=(*elems)
      reset_elements!
      insert_elements(*elems)
    end

    def elements?
      !elements.empty?
    end

    def get_and_render_to_html(name, builder = create_builder)
      elem = get_element(name)
      elem ? elem.to_html(builder) : nil
    end

    def get_and_render_label(name, builder = create_builder)
      elem = get_element(name)
      elem ? elem.render_label(builder) : nil
    end

    def get_element(name)
      name = ActiveForm::symbolize_name(name)
      if index = index_of_element(name)
        return elements[index]
      end
      return nil
    end
    alias :[] :get_element

    def get_elements_of_type(*types)
      types.flatten.inject([]) do |elems, type|
        self.recurse { |e| elems << e if type == e.element_type }
        elems
      end
    end

    def set_element(name, elem)
      name = ActiveForm::symbolize_name(name)
      raise ActiveForm::Element::MismatchException unless name == elem.name
      raise ActiveForm::Element::NoElemException unless is_element?(elem)
      if index = index_of_element(name)
        elem.register_container(self)
        return elements[index] = elem
      end
      return nil
    end
    alias :[]= :set_element
    alias :replace :set_element

    def remove_elements(*names)
      names.flatten.each { |name| elements.delete_at(index_of_element(name)); reindex_name_to_index_lookup! }
    end
    alias :remove_element :remove_elements

    def remove_elements_at(*indices)
      remove_elements(element_names_from_indices(indices))
    end
    alias :remove_element_at :remove_elements_at

    def remove_elements_of_type(*types)
      types.flatten.each do |type|
        self.recurse { |e| e.container.remove_element(e.name) if e.contained? && type == e.element_type }
      end
    end

    def element_exists?(name)
      name = ActiveForm::symbolize_name(name)
      name_to_index_lookup.include?(name)
    end

    def index_of_element(name)
      name = ActiveForm::symbolize_name(name)
      return nil unless element_exists?(name)
      name_to_index_lookup[name]
    end
    alias :index_of :index_of_element

    def get_element_by_index(index)
      self.elements[index]
    end
    alias :element_at :get_element_by_index

    def element_names_from_indices(*indices)
      indices.flatten.collect { |idx| get_element_by_index(idx) }.compact.collect(&:name)
    end

    def element_names
      elements.collect(&:name)
    end

    def reset_elements!
      elements.clear
      reindex_name_to_index_lookup!
    end

    def rebuild!
      reset_elements!
      after_initialize
    end

    def name_to_index_lookup
      @name_to_index_lookup ||= {}
      @name_to_index_lookup
    end

    def default_value
      ActiveForm::Values.new
    end

    private

    def name_to_index_lookup=(lookup) # prevent access
    end

    def reindex_name_to_index_lookup!
      name_to_index_lookup.clear
      elements.each_with_index { |elem, index| name_to_index_lookup[elem.name] = index }
    end

    def method_missing(method, *args, &block)
      if (match = /^html_for_(.*)$/.match(method.to_s))
        get_and_render_to_html(match.captures[0], *args)
      elsif (match = /^label_for_(.*)$/.match(method.to_s))
        get_and_render_label(match.captures[0], *args)
      elsif (match = /^(.*)_element$/.match(method.to_s)) && ActiveForm::Element::exists?(match.captures[0])
        define_element(match.captures[0], *args, &block)
      elsif (match = /^(.*)_widget$/.match(method.to_s)) && ActiveForm::Widget::exists?(match.captures[0])
        define_widget(match.captures[0], *args, &block)
      elsif (match = /^validates_(with_|as_|within_)?(.*)$/.match(method.to_s)) && ActiveForm::Validator::exists?(match.captures[1])
        define_validator(match.captures[1], *args, &block)
      elsif (match = /^select_from_(.*)$/.match(method.to_s))
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.push(options.merge(:model => match.captures[0], :to_dropdown => true))
        define_element(:select_from_model, *args, &block)
      else
        super
      end
    end

  end

  module ClassMethods

    def load_paths
      @@load_paths ||= []
    end

    def create(definition_name, prc = nil, &block)
      class_name = type_classname(definition_name)
      if !ActiveForm.const_defined?(class_name, false)
        ActiveForm.const_set(class_name, Class.new(self))
        if klass = ActiveForm.const_get(class_name, false)
          klass.setup_proc = (block_given? ? block : prc)
          return klass
        end
      end
      nil
    end

    def instance(definition_name, klass, *args, &block)
      args.unshift(definition_name) if args.empty? || args.first.kind_of?(Hash)
      item = klass.new(*args)
      item.instance_eval(&block) if block_given?
      item
    end

    def get(type, &block)
      load(type) rescue nil unless loaded?(type)
      klass = ActiveForm.const_get(type_classname(type), false) rescue nil
      klass.module_eval(&block) if klass && block_given?
      klass
    end
    alias :modify :get

    def type_classname(definition_name)
      "#{definition_name}_#{element_type}".classify
    end

  end

end