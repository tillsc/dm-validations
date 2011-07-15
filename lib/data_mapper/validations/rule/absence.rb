# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Validator

      class Absence < Validator

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          DataMapper::Ext.blank?(value)
        end

        def violation_type(resource)
          :absent
        end

      end # class Absence

    end # class Validator
  end # module Validations
end # module DataMapper