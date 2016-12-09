# frozen_string_literal: true

class PledgeHandler
  attr_reader :member

  def initialize(member, opts)
    @opts = opts
    @member = member
  end

  def pledge
    if opts.payment_method_token
      # + check payment method token belongs to member (compare to cookies)
      # + create transaction using token
    else
      customer = Payment::Braintree::Customer.create_or_return_for(member)
      payment_method = Payment::Braintree::PaymentMethod.create_for(customer, params[:payment_method_nonce])

      # Will need to worry about setting store_in_vault next (for members who want to resuse 
      # create transaction
      #

      transaction = Payment::Braintree::Transaction.create(
        pledged: true,
        payment_method: payment_method,
        amount: params[:amount].to_f,
        curreny: params[:currency],
        page: page
      )
    end
  end

  def pledge
    if new_payment_method?
      method = create_payment_method_on_braintree
      store_payment_method_locally(method)
    end

    create_action
    create_transaction
    emit_transaction_created_event
  end

  def create_payment_method_on_braintree
    opts = {
      payment_method_nonce: @nonce,
      customer_id: existing_customer.customer_id,
      billing_address: billing_options,
      options: {
        verify_card: true
      },
      device_data: @device_data
    }

    Braintree::PaymentMethod.create(opts)
  end

  def store_payment_method_locally(method)
  end

  def create_action
  end

  def create_transaction
  end

  def emit_transaction_created_event
  end

end

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def pledge
  end

  def webhook
    if client::WebhookHandler.handle(params[:bt_signature], params[:bt_payload])
      head :ok
    else
      head :not_found
    end
  end

  def link_payment
    pmid = current_member.customer.payment_methods.first.id

    opts = ActionController::Parameters.new(
      payment: {
        payment_method_id: pmid,
        currency: params[:currency],
        amount: params[:amount]
      },
      user: {
        email: current_member.email
      },
      page_id: params[:page_id]
    )

    client::OneClick.new(opts).run

    render text: page.title
  end

  def one_click
    @result = client::OneClick.new(params).run
    render status: :unprocessable_entity unless @result.success?
  end

  private

  def payment_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user].merge(mobile_value),
      currency: params[:currency],
      page: page,
      store_in_vault: store_in_vault?
    }
  end

  def client
    PaymentProcessor::Braintree
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:recurring])
  end
end
