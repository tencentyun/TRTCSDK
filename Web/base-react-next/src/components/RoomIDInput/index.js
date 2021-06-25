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

function getDefaultText(defaultValue, useStringRoomID) {
  if (defaultValue) {
    return defaultValue;
  }
  let defaultText = '';
  if (useStringRoomID) {
    defaultText = getUrlParam('roomID') ? getUrlParam('roomID') : 'string-room';
  } else {
    defaultText = getUrlParam('roomID') ? parseInt(getUrlParam('roomID'), 10) : parseInt(Math.random() * 100000, 10);
  }
  return defaultText;
};

export default function Input({ defaultValue, onChange, disabled }) {
  const classes = useStyles();
  const [useStringRoomID, setUserStringRoomID] = useState(false);
  const [inputLabel, setInputLabel] = useState('RoomID');
  const [defaultText, setDefaultText] = useState('');


  useEffect(() => {
    const useStringRoomID = getUrlParam('useStringRoomID') === 'true';
    setUserStringRoomID(useStringRoomID);
    setInputLabel(useStringRoomID ? 'String RoomID' : 'RoomID');

    const defaultText = getDefaultText(defaultValue, useStringRoomID);
    setDefaultText(defaultText);

    onChange && onChange(defaultText);
  }, []);

  const handleChange = (event) => {
    if (!onChange) {
      return;
    }
    useStringRoomID ? onChange(event.target.value) :  onChange(parseInt(event.target.value, 10));
  };

  return (
    defaultText && <TextField
      disabled={disabled}
      className={classes.input}
      id={inputLabel}
      label={inputLabel}
      type={`${useStringRoomID ? '' : 'number'}`}
      defaultValue={defaultText}
      onChange={handleChange}
    />
  );
}

Input.propTypes = {
  defaultValue: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  useStringRoomID: PropTypes.bool,
  onChange: PropTypes.func,
};
