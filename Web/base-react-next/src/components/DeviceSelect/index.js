import React, { useState, useEffect } from 'react';
import dynamic from 'next/dynamic';
import PropTypes from 'prop-types';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import { makeStyles } from '@material-ui/core/styles';
import { upperFirstLetter } from '@utils/utils';

const DynamicDeviceData = dynamic(import('@components/DeviceSelect/DeviceData'), { ssr: false });

const useStyles = makeStyles(theme => ({
  'form-control-menu': {
    marginBottom: theme.spacing(2),
    minWidth: 120,
    width: 'calc(100%)',
  },
  'form-control-option': {
    width: 250,
  },
  'select-empty': {
    marginTop: theme.spacing(2),
  },
}));

DeviceSelect.propTypes = {
  deviceType: PropTypes.string.isRequired,
  onChange: PropTypes.func,
};

export default function DeviceSelect({ deviceType, onChange }) {
  const classes = useStyles();
  const [deviceList, setDeviceList] = useState([]);
  const [activeDevice, setActiveDevice] = useState({});
  const [activeDeviceId, setActiveDeviceId] = useState('');

  const updateDeviceList = (list = []) => {
    setDeviceList((prevList) => {
      if (prevList.length === 0) {
        list[0] && setActiveDevice(list[0]);
        list[0] && list[0].deviceId && setActiveDeviceId(list[0].deviceId);
      }
      return list;
    });
  };

  useEffect(() => {
    if (activeDevice && JSON.stringify(activeDevice) !== '{}') {
      onChange && onChange(activeDevice.deviceId);
    }
  }, [activeDevice]);

  const handleChange = (event) => {
    const deviceID = event.target.value;
    const activeDevice = deviceList.find(item => item.deviceId === deviceID);
    setActiveDevice(activeDevice);
    setActiveDeviceId(deviceID);
  };

  return (
    <div>
      <DynamicDeviceData
        deviceType={deviceType}
        updateDeviceList={updateDeviceList}></DynamicDeviceData>
      {
        <FormControl className={classes['form-control-menu']}>
          <InputLabel id={`${deviceType}-input-label`}>{`${upperFirstLetter(deviceType)} Select`}</InputLabel>
          <Select
            labelId={`${deviceType}-input-label`}
            id={`${deviceType}-select`}
            value={activeDeviceId}
            onChange={handleChange}
            label={`${deviceType} Select`}
            className={classes.select}
          >
            {
              deviceList.map((item, index) => <MenuItem value={item.deviceId} key={index}>{item.label}</MenuItem>)
            }
          </Select>
        </FormControl>
      }
    </div>
  );
}
