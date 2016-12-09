require 'rails_helper'

module Payment::Braintree::ResponseWrappers
  class PaymentMethod
    CREDIT_CARD_ATTRIBUTES = %w(token card_type customer_id last_4 expiration_date bin)
    PAYPAL_ATTRIBUTES = %w(token email)

    def initialize(resp)
      @resp = resp
    end

    def attributes
      keys.inject({}) do |memo, att|
        memo[att] = @resp.payment_method.send(att)
        memo
      end.merge(
        'instrument_type' => instrument_type
      )
    end

    private

    def keys
      case @resp.payment_method
      when Braintree::CreditCard
        CREDIT_CARD_ATTRIBUTES
      when Braintree::PayPalAccount
        PAYPAL_ATTRIBUTES
      end
    end

    def instrument_type
      case @resp.payment_method
      when Braintree::CreditCard
        'credit_card'
      when Braintree::PayPalAccount
        'paypal_account'
      end
    end
  end

  describe PaymentMethod do
    subject { Payment::Braintree::ResponseWrappers::PaymentMethod.new(@braintree_payment_method_response) }

    context 'for credit card' do
      before do
        VCR.use_cassette('braintree_payment_method_credit_card') do
          customer_resp = ::Braintree::Customer.create
          @braintree_payment_method_response =
            ::Braintree::PaymentMethod.create(customer_id: customer_resp.customer.id, payment_method_nonce: 'fake-valid-nonce')
        end
      end

      it 'returns attributes' do
        expected_attributes = {
          card_type: 'Visa',
          customer_id: /\d*/,
          last_4: /\d{4}/,
          expiration_date: %r(\d{2}/\d{4}),
          token: /\w{6}/,
          bin: /\d{6}/,
          instrument_type: 'credit_card'
        }.stringify_keys

        expect(subject.attributes).to match(hash_including(expected_attributes))
      end
    end

    context 'for paypal' do
      before do
        VCR.use_cassette('braintree_payment_method_paypal') do
          customer_resp = ::Braintree::Customer.create
          @braintree_payment_method_response =
            ::Braintree::PaymentMethod.create(customer_id: customer_resp.customer.id, payment_method_nonce: 'fake-paypal-future-nonce')
        end
      end

      it 'returns attributes' do
        expected_attributes = {
          email: 'jane.doe@example.com',
          token: /\w{6}/,
          instrument_type: 'paypal_account'
        }.stringify_keys

        expect(subject.attributes).to match(hash_including(expected_attributes))
      end
    end
  end
end
