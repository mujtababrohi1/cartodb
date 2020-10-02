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
          email_date: payload[:date],
          email_body_hint: email_body_hint(payload)
        )
      end

      def process(event)
        payload = event.payload

        info(
          message: 'Mail processed',
          mailer_class: payload[:mailer],
          mailer_action: payload[:action],
          duration_ms: event.duration.round(1)
        )
      end

      private

      def current_user(event_payload)
        user_klass = defined?(Carto::User) ? Carto::User : User
        user_klass.find_by(email: event_payload[:to])&.username
      end

      def email_to(event_payload)
        receiver_address = event_payload[:to]
        return unless receiver_address.present? && receiver_address.include?('@') && receiver_address.length > 5

        receiver_address.split('@').map do |segment|
          segment[0] + '*' * (segment.length - 2) + segment[-1]
        end.join('@')
      end

      def email_body_hint(event_payload)
        event_payload[:mail].first(30) if event_payload[:mail].present?
      end

    end
  end
end

Carto::Common::ActionMailerLogSubscriber.attach_to(:action_mailer)
