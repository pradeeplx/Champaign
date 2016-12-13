/* @flow */
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';

const reducers = {
  member,
  fundraiser,
  paymentMethods,
};

export default combineReducers(reducers);

// import types
import type { Member } from './member/reducer';
import type { FundraiserState } from './fundraiser/reducer';
import type { PaymentMethod } from './paymentMethods/reducer';

export type AppState = {
  member: Member;
  fundraiser: FundraiserState;
  paymentMethods: PaymentMethod[];
};


type ChampaignPaymentMethod = any;

type ChampaignMember = {
  id: number;
  email: string;
  country: string;
  name: string;
  first_name: string;
  last_name: string;
  full_name: string;
  welcome_name: string;
  postal: string;
  actionkit_user_id: ?string;
  donor_status: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  created_at: string;
  updated_at: string;
};

declare type ChampaignLocation = {
  country: string;
  country_code: string;
  country_name: string;
  currency: string;
  ip: string;
  latitude: string;
  longitude: string;
};

declare type ChampaignPersonalizationData = {
  fundraiser: Object;
  locale: string;
  location: ChampaignLocation;
  member: ?ChampaignMember;
  paymentMethods: ChampaignPaymentMethod[];
  showDirectDebit: boolean;
  urlParams: { [key: string]: string };
};

export type InitialAction = {
  type: 'parse_champaign_data';
  payload: ChampaignPersonalizationData;
};

