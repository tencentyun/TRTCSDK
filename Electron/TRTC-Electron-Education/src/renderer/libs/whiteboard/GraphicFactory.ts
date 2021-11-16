import { WhiteboardGraphicType } from './types.d';
import BaseGraphic from './BaseGraphic';
import Line from './Line';
import RandomLine from './RandomLine';
// import Rect from './Rect';
// import Circle from './Circle';
// import Text from './Text';

const GraphicFactory = {
  logPrefix: '[WB-GraphicFactory]',
  createGraphic(ctx: any, config: Record<string, any>) {
    console.log(`${this.logPrefix}.createGraphic:`, ctx, config);
    let graphic: BaseGraphic | null = null;
    switch (config.type) {
      case WhiteboardGraphicType.Line:
        graphic = new Line(ctx, config);
        break;
      case WhiteboardGraphicType.Curve:
        graphic = new RandomLine(ctx, config);
        break;
      // case WhiteboardGraphicType.Rect:
      //   graphic = new Rect(ctx, config);
      //   break;
      // case WhiteboardGraphicType.Circle:
      //   graphic = new Circle(ctx, config);
      //   break;
      // case WhiteboardGraphicType.Text:
      //   graphic = new Text(ctx, config);
      //   break;
      default:
        console.error(`${this.logPrefix}.createGraphic unknown graphic type`);
        break;
    }

    return graphic;
  },
};

export default GraphicFactory;
