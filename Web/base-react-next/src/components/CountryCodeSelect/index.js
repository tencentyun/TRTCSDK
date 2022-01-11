import a18n from 'a18n';
/* eslint-disable no-use-before-define */
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import styles from './index.module.scss';
import Autocomplete, { createFilterOptions } from '@material-ui/lab/Autocomplete';
import InputAdornment from '@material-ui/core/InputAdornment';
import Input from '@material-ui/core/Input';
import { COUNTRIES } from '../../utils/constants';
import { getLanguage } from '@utils/common';

// ISO 3166-1 alpha-2
// ⚠️ No support for IE 11
function countryToFlag(isoCode) {
  if (isoCode === 'TW') {
    return 'CN'
      .toUpperCase()
      .replace(/./g, char => String.fromCodePoint(char.charCodeAt(0) + 127397));
  }
  return typeof String.fromCodePoint !== 'undefined'
    ? isoCode
      .toUpperCase()
      .replace(/./g, char => String.fromCodePoint(char.charCodeAt(0) + 127397))
    : isoCode;
}

export default function CountryCodeSelect(props) {
  const [defaultValue] = useState(() => (props.defaultValue ? props.defaultValue : 46));
  const [mountFlag, setMountFlag] = useState(false);

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setMountFlag(true);
  }, []);

  const handleChange = (event, newValue, reason) => {
    console.log('CountryCodeSelect handleChange', event, newValue, reason);
    props.onChange && props.onChange(newValue);
    // newValue && setInputValue(newValue.phone);
  };
  const filterOptions = createFilterOptions({
    stringify: option => option.label + option.code + option.phone,
  });
  return (
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
        getOptionLabel= {option => option.phone}
        filterOptions= {filterOptions}
        renderOption= {option => (
          <React.Fragment>
            <span>{countryToFlag(option.code)}</span>
            {option.label} ({option.code}) +{option.phone}
          </React.Fragment>
        )}
        renderInput={params => (<div ref= {params.InputProps.ref}>
              { mountFlag && <Input
                  type= "text"
                  placeholder={a18n('区号')}
                  startAdornment= {
                    <InputAdornment position="start">+</InputAdornment>
                  }
                  {...params.inputProps}
                />
              }
            </div>
        )}
      />
    </div>
  );
}

CountryCodeSelect.propTypes = {
  defaultValue: PropTypes.string,
  onChange: PropTypes.func,
};
