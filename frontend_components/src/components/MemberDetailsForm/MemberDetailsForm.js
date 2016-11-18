// @flow
import React, { Component } from 'react';
import Select from 'react-select';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import sortBy from 'lodash/sortBy';
import mapValues from 'lodash/mapValues';
import countryData from 'country-data/data/countries.json';
import Button from '../Button/Button';
import SweetInput from '../SweetInput/SweetInput';
import { updateUser } from '../../state/fundraiser/actions';
// import isEmail from 'validator/lib/isEmail';

import './MemberDetailsForm.css';
import 'react-select/dist/react-select.css';

type ConnectedState = { user: FundraiserFormMember; formId: number; };
type ConnectedDispatch = { updateUser: (u: FundraiserFormMember) => void; };
type OwnProps = {
  buttonText?: React$Element<any> | string;
  proceed?: () => void;
};

const countries =
  sortBy(countryData
    .filter(c => c.status === 'assigned')
    .filter(c => c.ioc !== '')
    .map(c => ({ value: c.alpha2, label: c.name })), 'label');

export class MemberDetailsForm extends Component {
  props: OwnProps & ConnectedDispatch & ConnectedState;

  state: {
    countries: any;
    errors: any;
    loading: boolean;
  };

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      countries,
      errors: {},
      loading: false,
    };
  }

  isValid(): boolean {
    return !!(this.props.user.email && this.props.user.country);
  }

  getFieldError(field: string): FormattedMessage | void {
    const error = this.state.errors[field];
    if (!error) return null;
    return <FormattedMessage {...error} />;
  }

  buttonText() {
    if (this.state.loading) return 'loading...';
    if (this.props.buttonText) return this.props.buttonText;
    return <FormattedMessage id="submit" defaultMessage="submit" />;
  }

  handleSuccess() {
    this.setState({ errors: {} });
    if (this.props.proceed) {
      this.props.proceed();
    }
  }

  handleFailure(response: any) {
    const errors = mapValues(response.errors, ([message], field) => {
      return {
        id: 'field_error_message',
        defaultMessage: '{field} {message}',
        values: { field, message: message}
      };
    });

    this.setState({ errors });
  }

  submit(e: SyntheticEvent) {
    e.preventDefault();
    // HACKISH☠ ️
    //
    fetch('/api/pages/1/actions/validate', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({ ...this.props.user, form_id: this.props.formId }),
    }).then(response => {
      if (response.ok) {
        return response.json().then(this.handleSuccess.bind(this));
      }
      return response.json().then(this.handleFailure.bind(this));
    });
  }

  render() {
    const { user, updateUser } = this.props;
    const { loading } = this.state;

    return (
      <div className="MemberDetailsForm-root">
        <form onSubmit={this.submit.bind(this)}>
          <div className="MemberDetailsForm-field">
            <SweetInput
              name="email"
              type="email"
              value={user.email}
              errorMessage={this.getFieldError('email')}
              label={<FormattedMessage id="email" defaultMessage="Email" />}
              onChange={email => updateUser({ ...user, email })}
            />
          </div>

          <div className="MemberDetailsForm-field">
            <SweetInput
              name="name"
              value={user.name}
              errorMessage={this.getFieldError('name')}
              label={<FormattedMessage id="name" defaultMessage="Full name" />}
              onChange={name => updateUser({ ...user, name })}
            />
          </div>

          <div className="MemberDetailsForm-field">
            <Select
              style={{marginBottom: '10px'}}
              ref="countrySelect"
              name="country"
              placeholder={<FormattedMessage id="country" defaultMessage="Country" />}
              simpleValue
              clearable
              searchable
              value={user.country}
              options={this.state.countries}
              onChange={(country => updateUser({ ...user, country }))}
            />
          </div>

          <div className="MemberDetailsForm-field">
            <SweetInput
              name="postal"
              value={user.postal}
              errorMessage={this.getFieldError('postal')}
              label={<FormattedMessage id="postal" defaultMessage="Postal Code" />}
              onChange={postal => updateUser({ ...user, postal })}
            />
          </div>

          <Button
            type="submit"
            disabled={!this.isValid() || loading }
            onClick={this.submit.bind(this)}>
            {this.buttonText()}
          </Button>
        </form>
      </div>
    );
  }
}

const mapStateToProps = (state: AppState): ConnectedState => ({
  formId: state.fundraiser.formId,
  user: state.fundraiser.user,
});

const mapDispatchToProps = (dispatch: Dispatch): ConnectedDispatch => ({
  updateUser: (user: FundraiserFormMember) => dispatch(updateUser(user)),
});

export default connect(mapStateToProps, mapDispatchToProps)(MemberDetailsForm);
