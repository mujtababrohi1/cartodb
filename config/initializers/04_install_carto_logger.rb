Carto::Common::Logger.install

# Log more easily from all models
ActiveRecord::Base.class_eval do
  include ::LoggerHelper
  extend ::LoggerHelper
end

Sequel::Model.class_eval do
  include ::LoggerHelper
  extend ::LoggerHelper
end

require 'action_mailer/log_subscriber'

module Carto
  module Common
    class ActionMailerLogSubscriber < ActionMailer::LogSubscriber

      # Marks Rails received a request to send an email
      # The original payload of this event contains very little information
      def process(event)
        payload = event.payload

        info(
          message: 'Mail processed',
          mailer_class: payload[:mailer],
          mailer_action: payload[:action],
          duration_ms: event.duration.round(1)
        )
      end

      # Marks Rails tried to send the email. Does not imply user received it, as an error can still happen
      # while sending it.
      def deliver(event)
        payload = event.payload

        info(
          message: 'Mail sent',
          mailer_class: payload[:mailer],
          message_id: payload[:message_id],
          current_user: current_user(payload),
          email_subject: payload[:subject],
          email_to_hint: email_to_hint(payload),
          email_from: payload[:from],
          email_date: payload[:date]
        )
      end

      private

      def current_user(event_payload)
        user_klass = defined?(Carto::User) ? Carto::User : User
        user_klass.find_by(email: event_payload[:to])&.username
      end

      def email_to_hint(event_payload)
        email_to = event_payload[:to]

        if email_to.is_a?(Array)
          email_to.map { |address| email_address_hint(address) }
        else
          [email_address_hint(email_to)]
        end
      end

      def email_address_hint(address)
        return unless address.present?
        return '[ADDRESS]' unless address.include?('@') && address.length > 5

        address.split('@').map do |segment|
          segment[0] + '*' * (segment.length - 2) + segment[-1]
        end.join('@')
      end

    end
  end
end

Carto::Common::ActionMailerLogSubscriber.attach_to(:action_mailer)
