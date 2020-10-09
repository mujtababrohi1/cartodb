require 'spec_helper'

describe 'Carto::Common::ActionMailerLogSubscriber' do
  subject { Carto::Common::ActionMailerLogSubscriber.new }

  context '#process' do
    let(:event) do
      OpenStruct.new(
        payload: { mailer: 'MyMailer', action: 'my_method' },
        duration: 123.456
      )
    end

    it 'logs email processing' do
      subject.expects(:info).with(
        message: 'Mail processed',
        mailer_class: 'MyMailer',
        mailer_action: 'my_method',
        duration_ms: 123.5
      )

      subject.process(event)
    end
  end

  context '#deliver' do
    let(:event) do
      OpenStruct.new(
        payload: {
          mailer: 'MyMailer',
          message_id: 123,
          subject: 'Email subject',
          from: ['pepito@carto.com'],
          to: ['pepito@carto.com']
        }
      )
    end

    it 'logs email delivery' do
      subject.expects(:info).with(
        message: 'Mail sent',
        mailer_class: 'MyMailer',
        message_id: 123,
        current_user: 'FIXME PLEASE',
        email_subject: 'Email subject',
        email_to_hint: ['p****o@c*******m'],
        email_from: ['pepito@carto.com'],
        email_date: nil
      )

      subject.deliver(event)
    end
  end
end
