import { WhiteboardToolType, WhiteboardGraphicType } from './types.d';
import GraphicFactory from './GraphicFactory';
import BaseGraphic from './BaseGraphic';

const CANVAS_WIDTH = 1600;
const CANVAS_HEIGHT = 900;

interface WhiteboardTool {
  toolType: WhiteboardToolType;
  graphicType?: WhiteboardGraphicType;
}

enum ActionType {
  Draw = 1,
  Delete = 2,
}

interface ActionMemento {
  action: ActionType;
  index: number;
}

class Whiteboard {
  static LOG_PREFIX = '[WB-Whiteboard]';

  private canvas: HTMLCanvasElement | null;

  private shadowCanvas: HTMLCanvasElement | null;

  private config: WhiteboardTool = {
    toolType: WhiteboardToolType.Graphic,
    graphicType: WhiteboardGraphicType.Curve,
  };

  private currentTool: WhiteboardToolType;

  private currentGraphicType: WhiteboardGraphicType;

  private currentGraphic: BaseGraphic | null;

  private graphicQueue: Array<BaseGraphic>;

  private graphicShadowMap: Map<
    string,
    { graphic: BaseGraphic; index: number }
  >;

  private actionMemeQueue: Array<ActionMemento> = [];

  private currentActionMemeIndex: number = -1;

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    this.shadowCanvas = document.createElement('canvas'); // 注意：目前测试发现，不加入 DOM 树也能正常使用
    this.shadowCanvas.width = CANVAS_WIDTH;
    this.shadowCanvas.height = CANVAS_HEIGHT;
    // this.shadowCanvas = new (window as any).OffscreenCanvas(CANVAS_WIDTH, CANVAS_HEIGHT);
    // To-do: shadowCanvas 使用 OffscreenCanvas 是不是效率更高？？？
    this.currentTool = WhiteboardToolType.Graphic;
    this.currentGraphicType = WhiteboardGraphicType.Curve;
    this.currentGraphic = null;
    this.graphicQueue = [];
    this.graphicShadowMap = new Map();

    this.onMouseDownHandler = this.onMouseDownHandler.bind(this);
    this.onMouseMoveHandler = this.onMouseMoveHandler.bind(this);
    this.onMouseUpHandler = this.onMouseUpHandler.bind(this);
    this.onClickCanvasHandler = this.onClickCanvasHandler.bind(this);
    this.registerEventListener();
  }

  setToolConfig(config: WhiteboardTool) {
    this.config = Object.assign(this.config, config);
  }

  // 选择工具
  chooseTool(config: WhiteboardTool) {
    this.currentTool = config.toolType;
    switch (config.toolType) {
      case WhiteboardToolType.Mouse:
        break;
      case WhiteboardToolType.Graphic:
        break;
      case WhiteboardToolType.Erase:
        break;
      default:
        console.log(
          `${Whiteboard.LOG_PREFIX}.chooseTool unknown tool type:`,
          config.toolType
        );
    }
    this.setToolConfig(config);
  }

  // 选择图形
  chooseGraphic(config: WhiteboardTool) {
    console.log(`${Whiteboard.LOG_PREFIX}.chooseGraphic config:`, config);
    if (config.graphicType) {
      this.currentGraphicType = config.graphicType;
    }
    this.currentGraphic = GraphicFactory.createGraphic(
      this.canvas?.getContext('2d'),
      {
        type: this.currentGraphicType,
      }
    );
  }

  registerEventListener() {
    console.log(`${Whiteboard.LOG_PREFIX}.registerEventListener`);
    document.addEventListener('mousedown', this.onMouseDownHandler, false);
    if (this.canvas) {
      this.canvas.addEventListener('click', this.onClickCanvasHandler, false);
    }
  }

  unregisterEventListener() {
    console.log(`${Whiteboard.LOG_PREFIX}.unregisterEventListener`);
    document.removeEventListener('mousedown', this.onMouseDownHandler, false);
    if (this.canvas) {
      this.canvas.removeEventListener(
        'click',
        this.onClickCanvasHandler,
        false
      );
    }
  }

  addAction(action: ActionMemento) {
    this.actionMemeQueue[++this.currentActionMemeIndex] = action;

    // undo 操作之后，this.currentActionMemeIndex 会小于 this.actionMemeQueue.length，
    // 此时，新增 Action 后，删除当前位置后的 Action 记录，不再支持这些 Action 的 redo 操作
    if (this.currentActionMemeIndex + 1 !== this.actionMemeQueue.length) {
      this.actionMemeQueue.splice(this.currentActionMemeIndex + 1, this.actionMemeQueue.length - this.currentActionMemeIndex - 1);
    }
  }

  domCoordsToCanvasCoords(clientX: number, clientY: number) {
    if (this.canvas) {
      const canvasBounds = this.canvas.getBoundingClientRect();
      // canvasBounds 可以替换为 offsetLeft, offsetTop, offsetWidth, offsetHeight

      // To-do: canvas 尺寸暂时固定为 CANVAS_WIDTH * CANVAS_HEIGHT
      return {
        canvasX: Math.floor(
          (CANVAS_WIDTH * (clientX - canvasBounds.left)) / canvasBounds.width
        ),
        canvasY: Math.floor(
          (CANVAS_HEIGHT * (clientY - canvasBounds.top)) / canvasBounds.height
        ),
      };
    }
    return {};
  }

  // To-do： 画图的 mousedown mousemove mouseup 事件是不是移动到 BaseGraphic 中更好？Whiteboard 作为一个 Facade 或者 Controller
  // To-do： 支持 touch 事件？？？
  onMouseDownHandler(event: MouseEvent) {
    console.log(
      `${Whiteboard.LOG_PREFIX}.onMouseDownHandler`,
      this.currentGraphic,
      this.canvas
    );
    if (this.currentTool === WhiteboardToolType.Graphic && this.canvas) {
      this.chooseGraphic(this.config);
      const { clientX, clientY } = event;
      const targetEl = document.elementFromPoint(clientX, clientY);
      if (targetEl !== this.canvas) {
        return;
      }

      const { canvasX, canvasY } = this.domCoordsToCanvasCoords(
        clientX,
        clientY
      );
      if (canvasX && canvasY) {
        if (this.currentGraphic) {
          this.currentGraphic.setStartPoint(canvasX, canvasY);
        }
      } else {
        const error = JSON.stringify({
          errorCode: 1001,
          errorMessage: 'canvas坐标计算错误',
        });
        throw Error(error);
      }

      document.addEventListener('mousemove', this.onMouseMoveHandler, false);
      document.addEventListener('mouseup', this.onMouseUpHandler, false);
    }
  }

  onMouseMoveHandler(event: MouseEvent) {
    console.log(`${Whiteboard.LOG_PREFIX}.onMouseMoveHandler`);
    if (this.currentGraphic) {
      const { clientX, clientY } = event;
      const { canvasX, canvasY } = this.domCoordsToCanvasCoords(
        clientX,
        clientY
      );
      if (canvasX && canvasY) {
        this.currentGraphic.addPoint(canvasX, canvasY);

        this.draw();
      } else {
        const error = JSON.stringify({
          errorCode: 1001,
          errorMessage: 'canvas坐标计算错误',
        });
        throw Error(error);
      }
    }
  }

  onMouseUpHandler(event: MouseEvent) {
    console.log(`${Whiteboard.LOG_PREFIX}.onMouseUpHandler`);
    if (this.currentGraphic) {
      const { clientX, clientY } = event;
      const { canvasX, canvasY } = this.domCoordsToCanvasCoords(
        clientX,
        clientY
      );
      if (canvasX && canvasY) {
        this.currentGraphic.setEndPoint(canvasX, canvasY);

        const newRandomColor = this.generateRandomColor();
        this.graphicShadowMap.set(newRandomColor, {
          graphic: this.currentGraphic,
          index: this.graphicQueue.length,
        });
        this.currentGraphic.setShadowColor(newRandomColor);
        this.graphicQueue.push(this.currentGraphic);
        this.currentGraphic = null;

        this.addAction({
          action: ActionType.Draw,
          index: this.graphicQueue.length - 1,
        });

        this.draw();
        this.drawShadow();
      } else {
        const error = JSON.stringify({
          errorCode: 1001,
          errorMessage: 'canvas坐标计算错误',
        });
        throw Error(error);
      }
    }

    document.removeEventListener('mousemove', this.onMouseMoveHandler, false);
    document.removeEventListener('mouseup', this.onMouseUpHandler, false);
  }

  draw() {
    console.log(
      `${Whiteboard.LOG_PREFIX}.draw canvas:`,
      this.canvas,
      this.graphicQueue
    );
    if (this.canvas) {
      const ctx = this.canvas.getContext('2d');
      ctx?.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
      this.graphicQueue.forEach(
        (item) => !item.getDeleteFlag() && item.draw(ctx)
      );

      if (this.currentGraphic) {
        this.currentGraphic.draw(ctx);
      }
    }
  }

  generateRandomColor(): string {
    const red = Math.round(Math.random() * 255);
    const green = Math.round(Math.random() * 255);
    const blue = Math.round(Math.random() * 255);
    const color = `rgb(${red},${green},${blue})`;
    if (this.graphicShadowMap.has(color)) {
      return this.generateRandomColor();
    }
    return color;
  }

  drawShadow() {
    console.log(
      `${Whiteboard.LOG_PREFIX}.drawShadow shadowCanvas:`,
      this.shadowCanvas,
      this.graphicQueue,
      this.graphicShadowMap
    );
    if (this.shadowCanvas) {
      const ctx = this.shadowCanvas.getContext('2d');
      ctx?.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
      this.graphicQueue.forEach(
        (item) => !item.getDeleteFlag() && item.drawShadow(ctx, {})
      );
    }
  }

  onClickCanvasHandler(event: MouseEvent) {
    if (this.currentTool !== WhiteboardToolType.Graphic) {
      console.log(`${Whiteboard.LOG_PREFIX}.onClickCanvasHandler`);
      const { clientX, clientY } = event;
      const { canvasX, canvasY } = this.domCoordsToCanvasCoords(
        clientX,
        clientY
      );
      if (canvasX && canvasY && this.shadowCanvas) {
        const shadowCtx = this.shadowCanvas.getContext('2d');
        if (shadowCtx) {
          const pixel = shadowCtx.getImageData(canvasX, canvasY, 1, 1).data;
          const color = `rgb(${pixel[0]},${pixel[1]},${pixel[2]})`;
          if (this.graphicShadowMap.has(color)) {
            const targetGraphic = this.graphicShadowMap.get(color);
            console.log(
              `${Whiteboard.LOG_PREFIX}.onClickCanvasHandler 找到有效图形：`,
              targetGraphic,
              this.graphicQueue
            );
            if (
              this.currentTool === WhiteboardToolType.Erase &&
              targetGraphic
            ) {
              this.eraseGraphic(targetGraphic);
            }
          } else {
            console.error(
              `${Whiteboard.LOG_PREFIX}.onClickCanvasHandler`,
              '点击位置不存在有效图形，color:',
              color,
              this.graphicShadowMap,
              this.graphicQueue
            );
          }
        }
      }
    }
  }

  eraseGraphic(graphicTarget: { graphic: BaseGraphic; index: number }) {
    console.log(
      `${Whiteboard.LOG_PREFIX}.eraseGraphic args:`,
      graphicTarget,
      this.graphicQueue
    );
    const { graphic, index } = graphicTarget;
    graphic.setDeleteFlag(true);

    this.addAction({
      action: ActionType.Delete,
      index: index,
    });

    this.draw();
    this.drawShadow();
  }

  /**
   * 多次 undo 操作之后，如果进行一次绘图或者删除操作，则通过 undo 操作回退的操作丢失（即不能再通过 redo 找回）。
   *
   * 说明示例: D 表示绘图操作（也可以时删除图形操作）；方括号，表示可以 redo 找回的操作。
   *  操作：D1
   *  队列：D1
   *
   *  操作：D1 -> D2
   *  队列：D1, D2
   *
   *  操作：D1 -> D2 -> D3
   *  队列：D1, D2, D3
   *
   *  操作：D1 -> D2 -> D3 -> undo
   *  队列：D1, D2, [D3]                    // 方括号中，表示可以 redo 找回的操作
   *
   *  操作：D1 -> D2 -> D3 -> undo -> undo
   *  队列：D1, [D2, D3]                    // 方括号中，表示可以 redo 找回的操作
   *
   *  操作：D1 -> D2 -> D3 -> undo -> undo -> D4
   *  队列：D1, D4                          // 此时没有可以支持 redo 的操作
   */
  undo() {
    if (this.currentActionMemeIndex >= 0) {
      const actionMeme = this.actionMemeQueue[this.currentActionMemeIndex];
      const { action, index } = actionMeme;
      switch(action) {
        case ActionType.Draw:
          this.graphicQueue[index].setDeleteFlag(true);
          this.currentActionMemeIndex--;
          this.draw();
          this.drawShadow();
          break;
        case ActionType.Delete:
          this.graphicQueue[index].setDeleteFlag(false);
          this.currentActionMemeIndex--;
          this.draw();
          this.drawShadow();
          break;
        default:
          console.log(`${Whiteboard.LOG_PREFIX}.undo unknown action`);
      }
    }
  }

  redo() {
    const actionMeme = this.actionMemeQueue[this.currentActionMemeIndex + 1];
    if (actionMeme) {
      const { action, index } = actionMeme;
      switch (action) {
        case ActionType.Draw:
          this.graphicQueue[index].setDeleteFlag(false);
          this.currentActionMemeIndex++;
          this.draw();
          this.drawShadow();
          break;
        case ActionType.Delete:
          this.graphicQueue[index].setDeleteFlag(true);
          this.currentActionMemeIndex++;
          this.draw();
          this.drawShadow();
          break;
        default:
          console.log(`${Whiteboard.LOG_PREFIX}.redo unknown action`);
      }
    }
  }

  // To-do: 待开发接口
  // serialize() {}
  // deserialize() {}

  destroy() {
    this.unregisterEventListener();
    this.canvas = null;
    this.shadowCanvas = null;
    this.graphicQueue = [];
    this.graphicShadowMap?.clear();
  }

  downloadImage() {
    if (this.canvas && this.shadowCanvas) {
      const dataUrl = this.canvas.toDataURL();
      const shadowDataUrl = this.shadowCanvas.toDataURL();
      const random = Math.floor(Math.random() * 10000);

      const a = document.createElement('a');
      a.style.display = 'none';
      a.setAttribute('href', dataUrl);
      a.setAttribute('download', `origin-${random}`);
      document.body.appendChild(a);
      a.click();

      const sa = document.createElement('a');
      sa.style.display = 'none';
      sa.setAttribute('href', shadowDataUrl);
      sa.setAttribute('download', `shadow-${random}`);
      document.body.appendChild(sa);
      sa.click();

      setTimeout(() => {
        document.body.removeChild(a);
        document.body.removeChild(sa);
      }, 0);
    }
  }
}

export default Whiteboard;
