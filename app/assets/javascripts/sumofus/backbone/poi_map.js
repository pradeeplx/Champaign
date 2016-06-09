const PoiMap = Backbone.View.extend({

  el: '.poi-map',

  initialize(options = {}) {
    console.log('asdfasfasf');
    this.addPoint({blurb: "The Snooper's Charter will not be passed.", country: 'Britain', x: 40, y: 15});
    this.addPoint({blurb: 'The Tanzanian president tweeted he will not permit hunting in the reserve.', country: 'Tanzania', x: 55, y: 55});
    this.addPoint({blurb: "Maxima's campaign against the Conga gold mine project has finally scuttled the project.", country: 'Peru', x: 16, y: 65});
  },

  addPoint(point) {
    this.$el.append(this.template(point.blurb, point.country, point.x, point.y));
    console.log('not cool', this.$el.children().last());
    this.$el.children().last().on('mouseenter touch', this.openBlurb.bind(this));
  },

  closeBlurbs() {
    this.$('.poi-map__point-highlight, .poi-map__blurb-container').addClass('poi-map--hidden')
  },

  openBlurb(e) {
    console.log('yo!');
    this.closeBlurbs();
    let $target = this.$(e.target);
    if(!$target.hasClass('poi-map__point')) {
      $target = $target.parents('.poi-map__point');
    }
    $target.find('.poi-map--hidden').removeClass('poi-map--hidden');
  },

  template(blurb, country, x, y) {
    // this doesn't deal with I18n for now, cause it depends where we want them to edit it
    return `<div class="poi-map__point" style="left: ${x}%; top: ${y}%;">
              <div class="poi-map__point-highlight poi-map--hidden"></div>
              <div class="poi-map__blurb-container poi-map--hidden">
                <div class="poi-map__country">${country}</div>
                <div class="poi-map__blurb">${blurb}</div>
              </div>
            </div>`
  },

});

module.exports = PoiMap;
