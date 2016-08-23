class CampaignCreator
  def self.run(params)
    new(params).run
  end

  def initialize(params)
    @params = params
  end

  def run
    @campaign = Campaign.create(@params)
    if @campaign.persisted?
      publish_event
    end
    @campaign
  end

  private

  def publish_event
    ChampaignQueue.push(      type: 'create_campaign',
                              name: @campaign.name,
                              campaign_id: @campaign.id)
  end
end
