import React, { useEffect, useRef } from 'react';
import WhiteBoardDrawToolbar from './sections/white-board-draw-toolbar';
import Whiteboard, { WhiteboardToolType, WhiteboardGraphicType } from '../../libs/whiteboard/index';
import './index.scss';

let wb: Whiteboard | null = null;

function ClassBoard(props: Record<string, any>) {
  const logPrefix = '[WhiteBoard]';
  const { onUpdateBounds } = props;
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    console.info(
      `${logPrefix}.useEffect init white-board bounds:`,
      ref,
      onUpdateBounds
    );
    if (ref && ref.current) {
      if (onUpdateBounds) {
        onUpdateBounds(ref.current.getBoundingClientRect());
      }
    }
  }, []);

  const onWindowResize = () => {
    console.info(`${logPrefix}.onWindowResize`);
    // To-do: resize 白板
    if (onUpdateBounds && ref?.current) {
      onUpdateBounds(ref.current.getBoundingClientRect());
    }
  };

  // 处理resize事件
  useEffect(() => {
    window.addEventListener('resize', onWindowResize, false);

    return () => {
      window.removeEventListener('resize', onWindowResize, false);
    };
  }, []);

  // 初始化白板，只需要执行一次
  useEffect(() => {
    console.log(`${logPrefix}.useEffect init whiteboard`);
    const canvasEl = document.getElementById('wb-canvas') as HTMLCanvasElement;
    wb = new Whiteboard(canvasEl);
    // eslint-disable-next-line no-underscore-dangle
    (window as any).__wb = wb; // To-do： 待删除，目前为了方便测试

    return () => {
      if (wb) {
        wb.destroy();
      }
    };
  }, []); // 无依赖，只创建一次

  const onChooseMouse = () => {
    if (wb) {
      wb.chooseTool({ toolType: WhiteboardToolType.Mouse });
    }
  }

  const onChooseLine = () => {
    wb?.chooseTool({ toolType: WhiteboardToolType.Graphic, graphicType: WhiteboardGraphicType.Line });
  }

  const onChooseRandomLine = () => {
    wb?.chooseTool({ toolType: WhiteboardToolType.Graphic, graphicType: WhiteboardGraphicType.Curve});
  }

  const onChooseErase = () => {
    wb?.chooseTool({ toolType: WhiteboardToolType.Erase});
  }

  const onUndo = () => {
    wb?.undo();
  }

  const onRedo = () => {
    wb?.redo();
  }

  return (
    <div className="white-board-panel">
      <div id="white-board" ref={ref}>
        <canvas id="wb-canvas" width="1600" height="900" />
      </div>
      <WhiteBoardDrawToolbar
        onChooseMouse={onChooseMouse}
        onChooseLine={onChooseLine}
        onChooseRandomLine={onChooseRandomLine}
        onChooseErase={onChooseErase}
        onUndo={onUndo}
        onRedo={onRedo}
      />
    </div>
  );
}

export default ClassBoard;
