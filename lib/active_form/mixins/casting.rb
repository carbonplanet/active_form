module ActiveForm
  
  module Mixins
    module Casting

      def self.included(base)
        base.send(:extend, ClassMethods)
        base.send(:attr_reader, :type_cast)
      end

      def cast_value(value)
        if self.respond_to?(:casting_filter)
          self.casting_filter(value)
        elsif self.class.respond_to?(:casting_filter)
          self.class.casting_filter(value)
        else
          value
        end
      end

      def type_cast=(type = :string)
        if self.respond_to?("casting_for_#{type}")
          @type_cast = type.to_sym
          cast, intern = self.send("casting_for_#{type}")
          define_casting_filter(cast) if cast
          define_formatting_filter(intern) if intern
        end
      end

      def casting_for_string
        [lambda { |value| value.is_a?(String) ? value : value.to_s }, nil]
      end
      alias :casting_for_text :casting_for_string

      def casting_for_integer
        [lambda { |value| value.is_a?(Integer) ? value : value.to_i rescue value ? 1 : 0 }, nil]
      end

      def casting_for_yaml
        [self.class.method_to_proc(:yaml_to_data), self.class.method_to_proc(:data_to_yaml)]
      end

      def casting_for_float
        [lambda { |value| value.is_a?(Float) ? value : value.to_f rescue 0 }, nil]
      end

      def casting_for_array
        [lambda { |value| value.is_a?(Array) ? value : [*value] }, lambda { |value| [*value].join(', ') }]
      end

      def casting_for_datetime
        [self.class.method_to_proc(:string_to_time), self.class.method_to_proc(:time_to_string)]
      end
      alias :casting_for_timestamp :casting_for_datetime

      def casting_for_time
        [self.class.method_to_proc(:string_to_dummy_time), self.class.method_to_proc(:time_to_string)]
      end

      def casting_for_date
        [self.class.method_to_proc(:string_to_date), self.class.method_to_proc(:date_to_string)]
      end

      def casting_for_boolean
        [self.class.method_to_proc(:value_to_boolean), self.class.method_to_proc(:boolean_to_value)]
      end

      def define_casting_filter(prc = nil, &block)
        define_singleton_method(:casting_filter, &(block_given? ? block : prc))
      end
      alias :casting_filter= :define_casting_filter

      def reset_casting_filter
        define_singleton_method(:casting_filter) rescue nil
      end

      module ClassMethods

        def define_casting_filter(prc = nil, &block)
          define_singleton_method(:casting_filter, &(block_given? ? block : prc))
        end
        alias :casting_filter= :define_casting_filter

        def reset_casting_filter
          define_singleton_method(:casting_filter) rescue nil
        end

        # type casting methods

        def binary_to_string(value)
          value
        end

        def data_to_yaml(value)
          value.to_yaml
        end

        def yaml_to_data(value)
          return value unless value.is_a?(String)
          YAML::load(value) rescue nil
        end

        def string_to_date(string)
          return string unless string.is_a?(String)
          date_array = Date.parse(string)
          # treat 0000-00-00 as nil
          Date.new(date_array[0], date_array[1], date_array[2]) rescue nil
        end

        def date_to_string(date)
          date.respond_to?(:to_formatted_s) ? date.to_formatted_s(:long) : date.to_s
        end

        def string_to_time(string)
          return string unless string.is_a?(String)
          if string.strip.match(/^(\d{1,2})[:\.](\d{1,2})([:\.](\d{1,2}))?$/)
            current_time = Time.now
            string = "#{current_time.year}-#{current_time.month}-#{current_time.day} #{string}"
          end
          # treat 0000-00-00 00:00:00 as nil
          time_array = Time.parse(string)[0..5]
          Time.send(ActiveForm::Element::Base.default_timezone, *time_array) rescue nil
        end

        def time_to_string(time)
          time.respond_to?(:to_formatted_s) ? time.to_formatted_s(:long) : time.to_s
        end

        def string_to_dummy_time(string)
          return string unless string.is_a?(String)
          time_array = Time.parse(string)
          # pad the resulting array with dummy date information
          time_array[0] = 2000; time_array[1] = 1; time_array[2] = 1;
          Time.send(ActiveForm::Element::Base.default_timezone, *time_array) rescue nil
        end

        def value_to_boolean(value)
          return value if value==true || value==false
          case value.to_s.downcase
          when "true", "t", "1" then true
          else false
          end
        end

        def boolean_to_value(boolean)
          boolean ? "true" : "false"
        end

      end

    end
  end
end
