// @flow
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import StepContent from '../../components/Stepper/StepContent';
import StepWrapper from '../../components/Stepper/StepWrapper';
import AmountSelection from '../../components/AmountSelection/AmountSelection';
import MemberDetailsForm from '../../components/MemberDetailsForm/MemberDetailsForm';
import Payment from '../../components/Payment/Payment';
import {
  changeAmount,
  changeCurrency,
  changeStep,
} from '../../state/fundraiser/actions';

import type { Dispatch } from 'redux';
import type { AppState } from '../../state';

type OwnProps = {
  currentStep: number;
  formValues: any;
  member: any;
  currency: string;
  donationBands: {[id:string]: number[]};
  donationFeaturedAmount: ?number;
  donationAmount: ?number;
  changeStep: (step: number) => void;
  selectAmount: (amount: ?number) => void;
  selectCurrency: (currency: string) => void;
  fields: any[];
  outstandingFields: string[];
  formId: number;
};

export class FundraiserView extends Component {
  props: OwnProps & mapStateToProps;

  static defaultProps = {
    currentStep: 0,
    member: null,
    currency: 'USD',
    donationBands: { 'USD': [2, 5, 10, 25, 50],
                     'GBP': [1, 2, 3, 4, 5]
    }
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);
  }

  proceed() {
    this.props.changeStep(this.props.fundraiser.currentStep + 1);
  }

  render() {
    const {
      member,
      fundraiser: {
        formId,
        fields,
        formValues,
        donationBands,
        donationAmount,
        donationFeaturedAmount,
        currency,
        currencies,
        currentStep,
        outstandingFields,
      }
    }  = this.props;

    return (
      <div id="fundraiser-view" className="FundraiserView-container form--big">
        <StepWrapper title={this.props.fundraiser.title} currentStep={currentStep} changeStep={this.props.changeStep}>
          <StepContent title={AmountSelection.title(donationAmount, currency)}>
            <AmountSelection
              donationAmount={donationAmount}
              currency={currency}
              donationBands={donationBands}
              donationFeaturedAmount={donationFeaturedAmount}
              currencies={currencies}
              nextStepTitle={ formValues ? 'payment' : MemberDetailsForm.title }
              changeCurrency={this.props.selectCurrency.bind(this)}
              selectAmount={amount => this.selectAmount(amount)}
              proceed={this.proceed.bind(this)}
            />
          </StepContent>

          { outstandingFields.length !== 0 &&
            <StepContent title="details">
              <MemberDetailsForm
                buttonText={<FormattedMessage id="fundraiser.proceed_to_payment" defaultMessage="Proceed to payment" />}
                fields={fields}
                outstandingFields={outstandingFields}
                prefillValues={formValues}
                formId={formId}
                proceed={this.proceed.bind(this)}
              />
            </StepContent> }

          <StepContent title="payment">
            <Payment />
          </StepContent>
        </StepWrapper>
      </div>
    );
  }
}

export const mapStateToProps = (state: AppState) => ({
  fundraiser: state.fundraiser,
  member: state.member,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeStep: (step: number) => dispatch(changeStep(step)),
  selectAmount: (amount: ?number) => dispatch(changeAmount(amount)),
  selectCurrency: (currency: string) => dispatch(changeCurrency(currency)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FundraiserView);