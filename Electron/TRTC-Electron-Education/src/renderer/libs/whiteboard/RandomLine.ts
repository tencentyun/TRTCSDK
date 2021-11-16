import BaseGraphic from './BaseGraphic';

class RandomLine extends BaseGraphic {
  static LOG_PREFIX = '[WB-RandomLine]';

  constructor(ctx: any, config: Record<string, any>) {
    super(ctx, config);
    console.log(`${RandomLine.LOG_PREFIX}.constructor`);
  }

  setStartPoint(x: number, y: number) {
    this.pointCoods?.push({ x, y });
  }

  addPoint(x: number, y: number) {
    this.pointCoods?.push({ x, y });
  }

  setEndPoint(x: number, y: number) {
    this.pointCoods?.push({ x, y });
  }

  draw(ctx: any) {
    if (this.pointCoods && this.pointCoods.length) {
      ctx.beginPath();
      this.pointCoods.forEach((point, index) => {
        if (index !== 0) {
          ctx.lineTo(point.x, point.y);
        } else {
          ctx.moveTo(point.x, point.y);
        }
      });
      ctx.stroke();
    }
  }

  setShadowColor(color: string) {
    this.config.shadowColor = color;
  }

  drawShadow(ctx: any, config: Record<string, any>) {
    console.log(
      `${RandomLine.LOG_PREFIX}.drawShadow config:`,
      config,
      ' ctx ',
      ctx
    );
    if (this.pointCoods && this.pointCoods.length) {
      ctx.lineWidth = 5;
      ctx.beginPath();
      this.pointCoods.forEach((point, index) => {
        if (index !== 0) {
          ctx.lineTo(point.x, point.y);
        } else {
          ctx.moveTo(point.x, point.y);
        }
      });
      ctx.strokeStyle = this.config.shadowColor;
      ctx.stroke();
    }
  }
}

export default RandomLine;
