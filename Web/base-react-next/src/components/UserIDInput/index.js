/*
 * @Description: 用户ID输入框
 * @Date: 2021-12-03 11:46:22
 * @LastEditTime: 2021-12-06 16:51:40
 */
import React, { useEffect, useState } from 'react';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core/styles';
import PropTypes from 'prop-types';
import { getUrlParam } from '@utils/utils';

const useStyles = makeStyles(theme => ({
  input: {
    width: 'calc(100%)',
    marginBottom: theme.spacing(2),
  },
}));

function getDefaultText(defaultValue, label) {
  if (defaultValue) {
    return defaultValue;
  }
  return getUrlParam(label)
    ? getUrlParam(label)
    : `user_${parseInt(Math.random() * 100000000, 10)}`;;
}

export default function Input({ label = 'userId', defaultValue, onChange, disabled }) {
  const classes = useStyles();
  const inputLabel = 'UserID';
  const [defaultText, setDefaultText] = useState('');

  useEffect(() => {
    const defaultText = getDefaultText(defaultValue, label);
    setDefaultText(defaultText);
    onChange && onChange(defaultText);
  }, []);

  const handleChange = (event) => {
    onChange && onChange(event.target.value);
  };

  return (
    defaultText && <TextField
      disabled={disabled}
      className={classes.input}
      id={inputLabel}
      label={inputLabel}
      defaultValue={defaultText}
      onChange={handleChange}
    />
  );
}

Input.propTypes = {
  defaultValue: PropTypes.string,
  onChange: PropTypes.func,
};
