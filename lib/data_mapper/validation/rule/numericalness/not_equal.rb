# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/numericalness'

module DataMapper
  module Validation
    class Rule
      module Numericalness

        class NotEqual < Rule

          include Numericalness

          def valid_numericalness?(value)
            value != expected
          rescue ArgumentError
            # TODO: figure out better solution for: can't compare String with Integer
            true
          end

          def violation_type(resource)
            :not_equal_to
          end

          def violation_data(resource)
            [ [ :not_expected, expected ] ]
          end

        end # class NotEqual

      end # module Numericalness
    end # class Rule
  end # module Validation
end # module DataMapper
