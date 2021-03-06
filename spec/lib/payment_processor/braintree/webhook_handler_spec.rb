# frozen_string_literal: true
require 'rails_helper'

describe PaymentProcessor::Braintree::WebhookHandler do
  def notification_faker(type, object_id)
    Braintree::WebhookTesting.sample_notification(
      type,
      object_id
    )
  end

  let(:member)       { create(:member) }
  let(:action)       { create(:action, member: member, form_data: { subscription_id: 'foo' }) }
  let!(:customer)    { create(:payment_braintree_customer, member: member) }
  let(:subscription) { create(:payment_braintree_subscription, action: action, subscription_id: 'subscription_id') }

  subject do
    PaymentProcessor::Braintree::WebhookHandler
      .handle(notification[:bt_signature], notification[:bt_payload])
  end

  describe 'subscription charged event' do
    context 'when subscription is found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          subscription.subscription_id
        )
      end

      it 'returns true' do
        expect(subject).to be true
      end

      it 'writes transaction' do
        expect { subject }
          .to change { subscription.transactions.count }
          .from(0).to(1)
      end

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
      end

      it 'posts a successful subscription payment event to the queue' do
        Timecop.freeze do
          expected_payload = {
            type: 'subscription-payment',
            params: {
              # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
              created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
              recurring_id: 'foo',
              success: 1,
              status: 'completed'
            }
          }

          expect(ChampaignQueue).to receive(:push)
            .with(expected_payload, delay: 120)

          subject
        end
      end
    end

    context 'when subscription is not found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          'invalid_subscription_id'
        )
      end

      it 'does not write transaction' do
        expect { subject }
          .not_to change { subscription.transactions.count }
      end

      # We're failing silently if the subscription isn't persisted locally because we get a lot of webhooks
      # for subscriptions that were created on our legacy platform.
      it 'fails silently' do
        expect(Rails.logger).to_not receive(:error)
      end

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
      end
    end
  end

  describe 'subscription cancelled event' do
    context 'when subscription is found' do
      let(:notification) do
        notification_faker(
          Braintree::WebhookNotification::Kind::SubscriptionCanceled,
          subscription.subscription_id
        )
      end

      it 'updates subscription' do
        expect { subject }.to change { subscription.reload.cancelled_at }
          .from(nil)
          .to(instance_of(ActiveSupport::TimeWithZone))
      end

      it 'writes notification' do
        subject

        record = Payment::Braintree::Notification.first

        expect(record.attributes).to include(
          'signature' => notification[:bt_signature],
          'payload'   => notification[:bt_payload]
        )
      end

      it 'pushes an event to the queue' do
        expect(ChampaignQueue).to receive(:push).with(type: 'cancel_subscription',
                                                      params: {
                                                        recurring_id: 'subscription_id',
                                                        canceled_by: 'processor'
                                                      })
        subject
      end
    end
  end

  describe 'failed subscription charge' do
    let(:notification) do
      notification_faker(
        Braintree::WebhookNotification::Kind::SubscriptionChargedUnsuccessfully,
        subscription.subscription_id
      )
    end

    it 'creates a failed transaction locally' do
      expect { subject }
        .to change { subscription.transactions.count }
        .from(0).to(1)
      expect(subscription.transactions.first.status).to eq('failure')
    end

    it 'pushes a failed subscription charge event to the queue' do
      Timecop.freeze do
        expected_payload = {
          type: 'subscription-payment',
          params: {
            # Matches the only string format AK accepts, e.g. "2016-12-22 17:47:42"
            created_at: /\A\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}\z/,
            recurring_id: 'foo',
            success: 0,
            status: 'failed'
          }
        }
        expect(ChampaignQueue).to receive(:push).with(expected_payload, delay: 120)
        subject
      end
    end
  end
end
