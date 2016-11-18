/* @flow */
import React from 'react';
import classnames from 'classnames';

type Props = {
  type?: string;
  disabled?: boolean;
  className?: string;
  onClick?: (e: SyntheticEvent) => any;
  children?: React$Element<any>;
};

const Button = (props: Props) => {
  const className = classnames(
    'Button-root',
    (props.disabled ? 'disabled' : ''),
    (props.className ? props.className : ''),
  );
  return (
    <button
      disabled={props.disabled}
      type={props.type}
      className={className}
      onClick={props.disabled ? null : props.onClick}>
      {props.children}
    </button>
  );
};

export default Button;
