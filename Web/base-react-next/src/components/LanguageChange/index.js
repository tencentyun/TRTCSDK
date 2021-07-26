import { Tooltip, Select, MenuItem } from '@material-ui/core';
import a18n from 'a18n';
import React, { useState, useEffect, useContext } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { MyContext } from '@utils/context-manager';
import { getLanguage } from '@utils/common';

const useStyles = makeStyles(props => ({
  'language-select': {
    minWidth: 70,
    color: (props && props.color) || '#00A4FF',
    fontSize: 14,
  },
}));

export default function LanguageChange(props) {
  const classes = useStyles(props);
  const { toolTipsVisible = true } = props;
  const [language, setLanguage] = useState('');
  const { changeLanguage } = useContext(MyContext);

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setLanguage(language);
  }, []);

  const languageChange = (event) => {
    const language = event.target.value;
    setLanguage(language);
    changeLanguage(language);
  };

  const selectComponent = () => <Select value={language} className={classes['language-select']} onChange={languageChange}>
    {/* // @a18n-ignore */}
    <MenuItem value='zh-CN'>中文</MenuItem>
    <MenuItem value='en'>English</MenuItem>
  </Select>;

  return toolTipsVisible
    ? <Tooltip title={a18n('语言切换')} placement="right-end">{selectComponent()}</Tooltip>
    : selectComponent();
}
