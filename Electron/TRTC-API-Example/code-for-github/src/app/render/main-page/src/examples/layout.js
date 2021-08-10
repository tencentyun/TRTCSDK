import a18n from 'a18n'
import React, { useEffect, useState, useCallback } from 'react';
import CodeMirror from '@uiw/react-codemirror';
import 'codemirror/theme/monokai.css';
import clsx from 'clsx';
import Button from '@material-ui/core/Button';
import ProfileMenu from '../components/ProfileMenu';
import { getExampleCode } from '../utils/code-blocks';
import InitConfig from '../components/InitConfig';

import './layout.scss';

function Layout(props) {
  let [isPreviewing, setIsPreviewing] = useState(false);
  let previewRef = React.createRef();
  let codeMirrorRef = React.createRef();
  let [code, setCode] = useState('');

  function execDemo() {
    setIsPreviewing(true);
    window.ipcRenderer.send('start-example', {
      code: codeMirrorRef.current.editor.getValue(),
      type: props.type
    });
  }

  const stopDemo = useCallback(() => {
    window.ipcRenderer.send('stop-example', {
      type: props.type
    });
    setIsPreviewing(false);
  }, [props.type]);

  useEffect(() => {
    setCode(getExampleCode(props.codePath));
    return () => {
      stopDemo();
    }
  }, [props.codePath, stopDemo]);

  useEffect(() => {
    const beforeUnloadHandler = (event) => {
      if (isPreviewing) {
        stopDemo();

        event.preventDefault();
        setTimeout(() => {
          // window.location.reload(); // NOTICE: this way of "reload" is not save as Electron WindowBrowser.reload()
          window.ipcRenderer.send('reload');
        }, 1000)
        return event.returnValue = 'Are you sure to leave or quit?';
      }
    }
    window.addEventListener('beforeunload', beforeUnloadHandler, {capture: true});
    return () => {
      window.removeEventListener('beforeunload', beforeUnloadHandler, {capture: true});
    }
  }, [isPreviewing, stopDemo])

  return (
    <div className={clsx({'example-item': true, [props.type]: true})}>
      <ProfileMenu />
      <h1 className="example-title">
        {props.title}
      </h1>
      {
        props.renderDesc
        ? (<div className="example-desc">{props.renderDesc()}</div>)
        : (<p className="example-desc">{props.desc}</p>)
      }
      <InitConfig />
      <div className="example-button-bar">
        <Button variant="contained" onClick={execDemo} color="primary" disabled={isPreviewing}>{a18n('运行')}</Button>
        <Button variant="contained" onClick={stopDemo}>{a18n('停止')}</Button>
      </div>
      {isPreviewing && (
        <div ref={previewRef} className="preview-section" id="preview-wrapper">
          {React.Children.map(props.children, child => {
            // checking isValidElement is the safe way and avoids a typescript error too
            if (React.isValidElement(child)) {
              return React.cloneElement(child);
            }
            return child;
          })}
        </div>
      )}
      {
        code && <CodeMirror ref={codeMirrorRef}
          value={code}
          options={{
            theme: 'monokai',
            tabSize: 2,
            mode: 'javascript',
            // scrollbarStyle: null
          }}
        />
      }
    </div>
  );
}

export default Layout;
