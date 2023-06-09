# frozen_string_literal: true

module DeprecationsCollector
  module ActiveSupport
    module DeprecationDecorator
      def warn(message = nil, callstack = caller)
        DeprecationsCollector::Main.add_deprecation(message, caller)

        return if DeprecationsCollector::Main.suppress_deprecations

        super(message, callstack)
      end

      ::ActiveSupport::Deprecation.prepend(self)
    end
  end
end
