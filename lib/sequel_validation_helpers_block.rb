module Sequel
  module Plugins
    # The ValidationHelpersBlock plugin allows easy determination of which
    # validation rules apply to a given column, by grouping validations
    # by column instead of by validation type.  It is significantly more
    # verbose than the default validation_helpers plugin, but provides
    # a nicer DSL, for example:
    #
    #   class Item < Sequel::Model
    #     plugin :validation_helpers_block
    #
    #     def validate
    #       validates do
    #         name do
    #           presence
    #           max_length 10
    #         end
    #         date do
    #           format %r{\d\d/\d\d/\d\d\d\d}
    #         end
    #         number do
    #           presence
    #           integer
    #         end
    #       end
    #     end
    #   end
    module ValidationHelpersBlock
      # Require the validation_helpers plugin
      def self.apply(model)
        model.plugin(:validation_helpers)
      end
      
      # DSL class used directly inside the validates block.
      # Methods without an explicit receiver that are called
      # inside the block are assumed to be attributes of the
      # object that need to be validated.
      class ValidationHelpersAttributesBlock < BasicObject
        # Set the object being validated and instance_eval the block.
        def initialize(obj, &block)
          @obj = obj
          instance_eval(&block)
        end
        
        # Create a new ValidationHelpersValidationsBlock object
        # using the stored object and given attribute name.
        def method_missing(m, &block)
          ValidationHelpersValidationsBlock.new(@obj, m, &block)
        end
      end
      
      # DSL class used inside attribute blocks.
      # The only methods allowed inside the block are those supported
      # by validation_helpers, and they specify the validations to
      # run for the related attribute on the related object.
      class ValidationHelpersValidationsBlock < BasicObject
        # validation_helpers methods that do not require a leading argument.
        VALIDATION_HELPERS_NO_ARG_METHODS = [:integer, :not_string, :numeric, :presence, :unique].freeze
        
        # validation_helpers methods that require a leading argument
        VALIDATION_HELPERS_1_ARG_METHODS = [:exact_length, :format, :includes, :length_range, :max_length, :min_length].freeze
        
        # Store the object and attribute and instance_eval the block.
        def initialize(obj, attr, &block)
          @obj = obj
          @attr = attr
          instance_eval(&block)
        end
        
        VALIDATION_HELPERS_NO_ARG_METHODS.each do |m|
          class_eval("def #{m}(opts={}); @obj.validates_#{m}(@attr, opts); end", __FILE__, __LINE__)
        end
        
        VALIDATION_HELPERS_1_ARG_METHODS.each do |m|
          class_eval("def #{m}(arg, opts={}); @obj.validates_#{m}(arg, @attr, opts); end", __FILE__, __LINE__)
        end
      end
      
      module InstanceMethods
        private
        
        # Start a new validation_helpers_block DSL for the given object
        def validates(&block)
          ValidationHelpersAttributesBlock.new(self, &block)
        end
      end
    end
  end
end
