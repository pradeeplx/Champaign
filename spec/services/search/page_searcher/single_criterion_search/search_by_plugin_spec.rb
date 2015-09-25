require 'rails_helper'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by plugin' do
        let!(:action_partial) { create(:liquid_partial, title: 'action') }
        let!(:thermometer_partial) { create(:liquid_partial, title: 'thermometer') }

        let!(:default_layout) { create(:liquid_layout, :default, title: 'contains action and thermometer plugin') }
        let!(:action_layout) { create(:liquid_layout, :action, title: 'contains action plugin') }

        let!(:action_page) { create(:campaign_page, liquid_layout: action_layout, title: 'action page - with action layout')}
        let!(:thermometer_page) {create(:campaign_page, liquid_layout: default_layout, title: 'thermometer page - with default layout, action toggled off')}
        let!(:default_page) {create(:campaign_page, liquid_layout: default_layout, title: 'default page - with active thermometer and action plugins')}

        let!(:thermometer_page_thermometer) { create(:plugins_thermometer, campaign_page: thermometer_page) }
        let!(:default_page_thermometer) { create(:plugins_thermometer, campaign_page: default_page) }
        let!(:action_page_thermometer) { create(:plugins_thermometer, campaign_page: action_page, active: false) }

        let!(:action_page_action) { create(:plugins_action, campaign_page: action_page, active: true) }
        let!(:default_page_action) { create(:plugins_action, campaign_page: default_page, active: true) }
        let!(:thermometer_page_action) { create(:plugins_action, campaign_page: thermometer_page, active: false) }

        describe 'returns all pages when searching' do
          it 'with an empty array' do
            expect(Search::PageSearcher.new({search: {plugin_type: []}}).search).to match_array(CampaignPage.all)
          end
          it 'with nil' do
            expect(Search::PageSearcher.new({search: {plugin_type: nil}}).search).to match_array(CampaignPage.all)
          end
          it 'with empty string' do
            expect(Search::PageSearcher.new({search: {plugin_type: ""}}).search).to match_array(CampaignPage.all)
          end
        end

        describe 'returns no pages when searching' do
          it 'with a plugin has been turned off on all of the pages' do
            expect(Search::PageSearcher.new({search: {plugin_type: ['Plugins::Thermometer']}}).search).to match_array([])
          end
          it 'with a plugin that does not exist' do
            expect(Search::PageSearcher.new({search: {plugin_type: ['Plugins::UnusedPlugin']}}).search).to match_array([])
          end
          it 'with several plugins where a page matches one but not the rest of them' do
            expect(Search::PageSearcher.new({search: {plugin_type: ['Plugins::Thermometer', 'Plugins::UnusedPlugin']}}).search).to match_array([])
          end

          it 'with several plugins where at least one page matches by criteria but at least one of the requested plugins is deactivated' do
            default_page_thermometer.update(active: false)
            expect(Search::PageSearcher.new({search: {plugin_type: ['Plugins::Action', 'Plugins::Thermometer']}}).search).to match_array([])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a plugin that is active on several pages' do
            expect(default_page_thermometer.campaign_page).to eq(default_page)

            default_page_thermometer.update(active: true)
            thermometer_page_thermometer.update(active:true)

            expect(default_page_thermometer.active).to eq(true)
            expect(thermometer_page_thermometer.active).to eq(true)
            expect(thermometer_page_thermometer.campaign_page).to eq(thermometer_page)
            expect((Search::PageSearcher.new({search: {plugin_type: ['Plugins::Thermometer']}})).search).to match_array([default_page, thermometer_page])
          end

          it 'with several plugins, if a page exists where all of them are active' do

            default_page_thermometer.update(active: true)
            default_page_action.update(active: true)

            action_page_action.update(active: true)
            thermometer_page_action.update(active: false)

            action_page_thermometer.update(active: false)
            thermometer_page_thermometer.update(active: true)

            expect(Search::PageSearcher.new({search: {plugin_type: ['Plugins::Action', 'Plugins::Thermometer']}}).search).to match_array([default_page])
          end
        end
      end
    end
  end
end