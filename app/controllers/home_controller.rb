class HomeController < ApplicationController

  def index
    # left blank on purpose
  end

  def health_check
    render plain: health_check_haiku, status: 200
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{Settings.robots}.txt")
    render plain: robots
  end

  def homepage
    @case_studies = case_studies
    render 'homepage', layout: 'homepage'
  end

  private

  def health_check_haiku
    "Health check is passing,\n"\
    "don't terminate the instance.\n"\
    "Response: 200."
  end

  def case_studies
    [
      {
        lead: "Leading the fight against bad trade deals and corporate mergers",
        details: "SumOfUs exists to keep corporations playing fair. So when they lobby governments to change the rules of the game to their advantage, we're there to fight them. We've taken leadership mobilizing public opinion against bad trade deals like TTIP and TPP, and we've stopped catastrophic mega-corporation mergers, like Comcast with Time Warner.",
        image: 'sumofus/campaigns/ttip'
      },
      {
        lead: "Keeping natural resources in the hands of local communities",
        details: "Around the world, powerful corporations are attempting to exploit natural resources at the expense of those who live near them. SumOfUs empowers communities to fight back. Recently, we've helped towns in the USA and Canada reject Nestlé's attempts to bottle and sell their aquifers, and we've helped Maxima Acuña stop the disastrous Conga mine in the Peruvian Andes.",
        image: 'sumofus/campaigns/maxima'
      },
      {
        lead: "Fighting for workers rights, safety, and compensation",
        details: "Workers deserve conditions safe from hazards and sexual harassment, and deserve to be paid for their work. When employers can't seem to understand that, SumOfUs is there to help. We've supported workers in fights against bad bosses across industries - in retail, manufacturing, restaurants, airlines, farming - and they've won.",
        image: 'sumofus/campaigns/workers'
      },
      {
        lead: "Forcing global food brands to use conflict-free palm oil",
        details: "Palm oil is an important ingredient in many packaged foods, from Nutella to Big Macs. However, it's production often leads to the destruction of rainforests and flagrant abuses of workers' rights. We've successfully lobbied global food brands including McDonalds, Starbucks, and PepsiCo, to purchase only palm oil produced free of conflict or deforestation.",
        image: 'sumofus/campaigns/palm'
      },
      {
        lead: "Saving bee populations from toxic pesticides",
        details: "Global honeybee populations have been in decline for years, threatening both the global food supply and ecosystems around the world. SumOfUs has been a leader in the fight to save the bees, whether funding research or demanding policy change. Recently, we helped get France to ban neonics, the class of pesticides linked to colony deaths, and got Lowe's to take neonics off their shelves.",
        image: 'sumofus/campaigns/bee'
      },
      {
        lead: "Protecting animals from inhumane treatment",
        details: "Corporations don't just abuse human rights - they abuse animal rights too. Whether we're stopping the sale of angora rabbit fur, forcing SeaWorld to stop breeding orcas, or convincing every major airline to prohibit the transport of hunting trophy carcasses, we always take animal rights seriously.",
        image: 'sumofus/campaigns/animals'
      },
    ].map do |case_study|
      case_study[:image] = ActionController::Base.helpers.asset_path(case_study[:image], type: :image)
      case_study
    end
  end
end
