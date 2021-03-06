# frozen_string_literal: true
require 'rails_helper'

describe Api::PagesController do
  let(:page) { instance_double('Page', id: 1, to_param: '1', to_json: '') }
  let(:page_updater) { double(update: true, refresh?: true) }

  before do
    allow(Page).to receive(:find) { page }
  end

  describe 'GET index' do
    before do
      allow(PageService).to receive(:list)
      get :index, language: 'en', format: :json
    end

    it 'gets list of pages' do
      expect(PageService).to have_received(:list).with(hash_including(language: 'en'))
    end

    it 'responds with json' do
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET featured' do
    before do
      allow(PageService).to receive(:list_featured)
      get :featured, language: 'en', format: :json
    end

    it 'gets list of pages' do
      expect(PageService).to have_received(:list_featured).with(hash_including(language: 'en'))
    end

    it 'responds with json' do
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'PUT update' do
    before do
      allow(PageUpdater).to receive(:new) { page_updater }
      put :update, id: 1
    end

    it 'finds page' do
      expect(Page).to have_received(:find).with('1')
    end

    context 'PageUpdater' do
      it 'is instantiated' do
        expect(PageUpdater).to have_received(:new).with(page, 'http://test.host/pages/1')
      end

      it 'calls update with params' do
        expect(page_updater).to have_received(:update).with({})
      end
    end
  end

  describe 'GET show' do
    context 'for existing page' do
      before { get :show, id: '2', format: 'json' }

      it 'finds page' do
        expect(Page).to have_received(:find).with('2')
      end

      it 'renders json' do
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'record not found' do
      before do
        allow(Page).to receive(:find) { raise ActiveRecord::RecordNotFound }
        get :show, id: '2'
      end

      it 'renders json' do
        expect(response.body).to match(/No record was found/)
      end
    end
  end
end
