import BaseGraphic from './BaseGraphic';

class Line extends BaseGraphic {
  static LOG_PREFIX = '[WB-Line]';

  constructor(ctx: any, config: Record<string, any>) {
    super(ctx, config);
    console.log(`${Line.LOG_PREFIX}.constructor`);
  }

  addPoint(x: number, y: number) {
    this.setEndPoint(x, y);
  }

  setEndPoint(x: number, y: number) {
    if (this.pointCoods && this.pointCoods[1]) {
      this.pointCoods[1] = { x, y };
    } else {
      this.pointCoods?.push({ x, y });
    }
  }

  draw(ctx: any) {
    if (this.pointCoods && this.pointCoods.length) {
      ctx.beginPath();
      ctx.moveTo(this.pointCoods[0].x, this.pointCoods[0].y);
      ctx.lineTo(this.pointCoods[1].x, this.pointCoods[1].y);
      ctx.stroke();
    }
  }

  setShadowColor(color: string) {
    this.config.shadowColor = color;
  }

  drawShadow(ctx: any, config: Record<string, any>) {
    console.log(`${Line.LOG_PREFIX}.drawShadow config:`, config, ' ctx ', ctx);
    if (this.pointCoods && this.pointCoods.length && ctx) {
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(this.pointCoods[0].x, this.pointCoods[0].y);
      ctx.lineTo(this.pointCoods[1].x, this.pointCoods[1].y);
      ctx.strokeStyle = this.config.shadowColor;
      ctx.stroke();
    }
  }
}

export default Line;
