require 'rails_helper'

describe PagesController do
  let(:user) { instance_double('User', id: '1') }
  let(:page) { instance_double('Page', active?: true, featured?: true, id: '1') }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'GET #index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    let(:page) { instance_double(Page, valid?: true) }

    before do
      allow(PageBuilder).to receive(:create_with_plugins) { page }
      post :create, { page: { title: "Foo Bar" }}
    end

    it 'creates page' do
      expected_params = { title: "Foo Bar" }

      expect(PageBuilder).to have_received(:create_with_plugins).
        with(expected_params)
    end

    context "successfully created" do
      it 'redirects to edit_page' do
        expect(response).to redirect_to(edit_page_path(page))
      end
    end

    context "successfully created" do
      let(:page) { instance_double(Page, valid?: false) }

      it 'redirects to edit_page' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:page) { instance_double(Page) }

    before do
      allow(Page).to receive(:find){ page }
      allow(page).to receive(:update)
      put :update, id: '1', page: { title: 'bar' }
    end

    it 'finds the campaign page' do
      expect(Page).to have_received(:find).with('1')
    end

    it 'udpates the campaign page' do
      expect(page).to have_received(:update).with(title: 'bar')
    end
  end

  describe 'GET #show' do
    it 'finds campaign page'
    it 'collects markup data'
    it 'renders show template'
  end
end

