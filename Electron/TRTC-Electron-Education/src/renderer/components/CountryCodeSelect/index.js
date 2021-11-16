import a18n from 'a18n';
/* eslint-disable no-use-before-define */
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import Autocomplete, {
  createFilterOptions,
} from '@material-ui/lab/Autocomplete';
import InputAdornment from '@material-ui/core/InputAdornment';
import Input from '@material-ui/core/Input';
import { COUNTRIES } from '../../utils/login-sdk/constants';
import styles from './index.scss';

// ISO 3166-1 alpha-2
// ⚠️ No support for IE 11
function countryToFlag(isoCode) {
  if (isoCode === 'TW') {
    return 'CN'
      .toUpperCase()
      .replace(/./g, (char) =>
        String.fromCodePoint(char.charCodeAt(0) + 127397)
      );
  }
  return typeof String.fromCodePoint !== 'undefined'
    ? isoCode
        .toUpperCase()
        .replace(/./g, (char) =>
          String.fromCodePoint(char.charCodeAt(0) + 127397)
        )
    : isoCode;
}

export default function CountryCodeSelect(props) {
  const [defaultValue] = useState(() =>
    props.defaultValue ? props.defaultValue : 46
  );

  const handleChange = (event, newValue, reason) => {
    console.log('CountryCodeSelect handleChange', event, newValue, reason);
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    props.onChange && props.onChange(newValue);
    // newValue && setInputValue(newValue.phone);
  };
  const filterOptions = createFilterOptions({
    stringify: (option) => option.label + option.code + option.phone,
  });
  return (
    // eslint-disable-next-line react/jsx-filename-extension
    <div className={styles['country-code-select']}>
      <Autocomplete
        id="country-select"
        options={COUNTRIES}
        defaultValue={COUNTRIES[defaultValue]}
        onChange={handleChange}
        classes={{
          root: styles.root,
          popper: styles['country-code-select-popper'],
          option: styles.option,
          input: styles.input,
        }}
        autoHighlight
        getOptionLabel={(option) => option.phone}
        filterOptions={filterOptions}
        renderOption={(option) => (
          <>
            <span>{countryToFlag(option.code)}</span>
            {option.label} ({option.code}) +{option.phone}
          </>
        )}
        renderInput={(params) => (
          <div ref={params.InputProps.ref}>
            <Input
              type="text"
              placeholder={a18n('区号')}
              startAdornment={
                <InputAdornment position="start">+</InputAdornment>
              }
              // eslint-disable-next-line react/jsx-props-no-spreading
              {...params.inputProps}
            />
          </div>
        )}
      />
    </div>
  );
}

CountryCodeSelect.propTypes = {
  // eslint-disable-next-line react/require-default-props
  defaultValue: PropTypes.string,
  // eslint-disable-next-line react/require-default-props
  onChange: PropTypes.func,
};
