# frozen_string_literal: true
require 'rails_helper'

describe EmailConfirmationController do
  describe 'verify' do
    include AuthToken

    let(:member) { create(:member) }
    let(:authentication) { create(:member_authentication, member: member) }

    it 'sets cookie' do
      post :verify, token: authentication.token, email: member.email

      payload = decode_jwt(cookies.signed['authentication_id'])
      expect(payload['email']).to eq(member.email)
    end
  end
end
