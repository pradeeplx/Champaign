require 'champaign_queue'
require 'browser'

class CampaignPagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]

  def index
    # List campaign pages that match requested search parameters.
    # If there are no search parameters, return all campaign pages.
    @campaign_pages = Search::PageSearcher.new(params).search
  end

  def new
    @campaign_page = CampaignPage.new
  end

  def create
    @campaign_page = CampaignPage.create_with_plugins( permitted_params )

    if @campaign_page.valid?
      redirect_to edit_campaign_page_path(@campaign_page)
    else
      render :new
    end
  end

  def show
    # TODO
    # Set this in an initialiser
    #
    Liquid::Template.file_system = LiquidFileSystem.new


    markup = if @campaign_page.liquid_layout
               @campaign_page.liquid_layout.content
             else
                File.read("#{Rails.root}/app/views/plugins/templates/main.liquid")
             end

    @template = Liquid::Template.parse(markup)

    @data = Plugins.data_for_view(@campaign_page).
      merge( @campaign_page.attributes ).
      merge( 'images' => images )

    render :show, layout: false
  end

  #
  # NOTE
  # This is a hack. Plugin data will be dynamically built, according to what
  # plugins have been installed/enabled.
  #
  #
  def images
    @campaign_page.images.map do |img|
      { 'urls' => { 'large' => img.content.url(:medium_square), 'small' => img.content.url(:thumb) } }
    end
  end

  def data
    plugins_data = Plugin.registered.inject({}) do |memo, plugin|
      config = Plugins.const_get(plugin[:name].classify).new(@campaign_page)
      memo[plugin[:name]] = config.data_for_view
      memo
    end


    { 'plugins' => plugins_data }
  end

  def update
    respond_to do |format|
      if @campaign_page.update(permitted_params)
        format.html { redirect_to edit_campaign_page_path(@campaign_page), notice: 'Page was successfully updated.' }
        format.json { render json: @campaign_page, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @liquid_layout.errors, status: :unprocessable_entity }
      end
    end
  end

  def sign
    ChampaignQueue::SqsPusher.push(params.as_json)
  end

  private

  def get_campaign_page
    @campaign_page = CampaignPage.find(params[:id])
  end

  def permitted_params
    params.require(:campaign_page).
      permit( :id,
      :title,
      :slug,
      :active,
      :content,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tag_ids => []} )
  end
end
