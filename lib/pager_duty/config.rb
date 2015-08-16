module PagerDuty
  module Config
    extend ActiveSupport::Concern

    class_methods do
      def domain
        ENV["PAGERDUTY_DOMAIN"]
      end

      def token
        ENV["PAGERDUTY_API"]
      end
    end
  end
end
