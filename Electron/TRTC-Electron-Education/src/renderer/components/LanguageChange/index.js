import { Tooltip, Select, MenuItem } from '@material-ui/core';
import a18n from 'a18n';
import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { getLocale, setLocale } from '../../initA18n';

const useStyles = makeStyles((props) => ({
  'language-select': {
    minWidth: 70,
    color: (props && props.color) || '#00A4FF',
    fontSize: 14,
  },
}));

export default function LanguageChange(props) {
  const classes = useStyles(props);
  // eslint-disable-next-line react/prop-types
  const { toolTipsVisible = true } = props;
  const [language, setLanguage] = useState('');

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-shadow
    const language = getLocale();
    setLanguage(language);
  }, []);

  const languageChange = (event) => {
    // eslint-disable-next-line @typescript-eslint/no-shadow
    const language = event.target.value;
    setLanguage(language);
    setLocale(language);
  };

  const selectComponent = () => (
    // eslint-disable-next-line react/jsx-filename-extension
    <Select
      value={language}
      className={classes['language-select']}
      onChange={languageChange}
    >
      {/* // @a18n-ignore */}
      <MenuItem value="zh-CN">中文</MenuItem>
      <MenuItem value="en-US">English</MenuItem>
    </Select>
  );

  return toolTipsVisible ? (
    <Tooltip title={a18n('语言切换')} placement="right-end">
      {selectComponent()}
    </Tooltip>
  ) : (
    selectComponent()
  );
}
