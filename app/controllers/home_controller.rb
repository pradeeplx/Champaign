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
    @press_hits = press_hits
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

  def press_hits
    [
      {
        quote: '‘There’s overwhelming evidence that CEO pay isn’t linked to performance,’ Lisa Lindsley, a shareholder advocate with SumOfUs, told The Post.',
        logo: "sumofus/press/ny-post",
        logo_aspect: :tall,
        link: 'http://nypost.com/2016/05/20/lloyd-blankfein-gets-23m-for-being-mediocre/'
      },
      {
        quote: 'About 400 protesters blew conch shells on a Hawaii beach to demonstrate against a trade agreement being negotiated by ministers from 12 Pacific Rim nations.',
        logo: "sumofus/press/seattle-times",
        logo_aspect: :long,
        link: 'http://www.seattletimes.com/nation-world/environmentalists-unions-protest-pacific-trade-pact-in-maui/'
      },
      {
        quote: 'Pullman added she believes it’s important for her organization to continue putting pressure on WestJet, because other companies are watching. ‘It sends a message to the entire corporate sector,’ she said.',
        logo: "sumofus/press/calgary-herald",
        logo_aspect: :tall,
        link: 'http://calgaryherald.com/business/local-business/westjet-ceo-pledges-to-make-results-of-harassment-audit-public'
      },
      {
        quote: 'Disgusted consumers called for a boycott of the stores still selling the fibre, while a petition led by SumOfUs asked Zara to stop the sale of items made with angora fur. The petition attracted more than 295,000 signatures.',
        logo: "sumofus/press/daily-mail",
        logo_aspect: :tall,
        link: 'http://www.dailymail.co.uk/femail/article-2529849/Zara-Gap-finally-ban-angora-shoppers-horrified-plight-rabbits-plucked-alive-threaten-boycott-shops.html'
      },
      {
        quote: '‘There definitely is a piece around educating people that they can have a say that way,’ said Liz McDowell, campaign director at SumOfUs. ‘I was surprised at the amount of momentum behind this petition.’',
        logo: "sumofus/press/bloomberg",
        logo_aspect: :tall,
        link: 'http://www.bloomberg.com/news/articles/2016-05-20/a-millionaire-is-telling-blackrock-to-say-no-to-big-ceo-pay'
      },
      {
        quote: 'At 2.30pm, women frontline workers and campaign group SumOfUs, will hand in a 200,000 signature petition to 10 Downing Street, calling on the Government to rethink its Trade Union Bill.',
        logo: "sumofus/press/mirror",
        logo_aspect: :tall,
        link: 'http://www.mirror.co.uk/news/uk-news/real-work-unions-makes-services-7311706'
      },
      {
        quote: 'A group of airlines including Air France, KLM, Iberia, IAG Cargo, Singapore Airlines and Qantas signaled last week they would ban the transport of trophy-hunting kills, according to Paul Ferris, the campaign director at SumOfUs',
        logo: "sumofus/press/ny-times",
        logo_aspect: :long,
        link: 'http://www.nytimes.com/2015/08/03/travel/cecil-lion-poaching-hunting-delta-airlines.html?_r=1'
      },
      {
        quote: "Mothers whose children were shot in mass shootings delivered to the Walmart store a petition with more than 291,000 signatures demanding an end to the company's national sales of assault weapons and munitions.",
        logo: "sumofus/press/usa-today",
        logo_aspect: :tall,
        link: 'http://www.usatoday.com/story/news/nation/2013/01/15/newtown-school-shooting-walmart/1836261/'
      },
    ].map do |press_hit|
      press_hit[:logo] = ActionController::Base.helpers.asset_path(press_hit[:logo], type: :image)
      press_hit
    end
  end
end
