var flux   = require('flux/main');
var mixins = require('flux/mixins');
var Widgets = require('components/widgets/widgets');

var WidgetsEditor = React.createClass({
  mixins: [mixins.FluxMixin, mixins.StoreWatchMixin("WidgetStore")],

  getInitialState() {
    return { widgets: [] };
  },

  getDefaultProps() {
    return { flux: flux };
  },

  getStateFromFlux() {
    var store = flux.store("WidgetStore");

    return {
      data: store.widgets
    };
  },

  componentDidMount() {
    flux.actions.loadWidgets();
  },

  handleWidgetSubmit(data) {
    flux.actions.updateWidget(data);
  },

  render() {
    return (
      <div className='widgets'>
        <Widgets widgets={this.state.data} campaign_page_id={ this.props.id } />
      </div>
    )
  }
})

module.exports = WidgetsEditor;

