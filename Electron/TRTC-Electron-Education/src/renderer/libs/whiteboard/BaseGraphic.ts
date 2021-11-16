class BaseGraphic {
  static LOG_PREFIX = '[WB-BasicGraphic]';

  protected ctx: any;

  protected config: Record<string, any>;

  protected pointCoods: Array<Record<string, number>> | null;

  protected deleteFlag = false;

  constructor(ctx: any, config: Record<string, any>) {
    this.ctx = ctx;
    this.config = config;
    this.pointCoods = [];
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

  // eslint-disable-next-line class-methods-use-this
  setShadowColor(color: string) {}

  // eslint-disable-next-line class-methods-use-this
  draw(ctx: any) {
    console.log(`${BaseGraphic.LOG_PREFIX}.draw ctx:`, ctx);
  }

  // eslint-disable-next-line class-methods-use-this
  drawShadow(ctx: any, config: Record<string, any>) {
    console.log(`${BaseGraphic.LOG_PREFIX}.drawShadow ctx:`, ctx);
  }

  setDeleteFlag(flag: boolean) {
    this.deleteFlag = flag;
  }

  getDeleteFlag() {
    return this.deleteFlag;
  }

  // To-do: 待开发接口
  // serialize() {}
  // deserialize() {}
}

export default BaseGraphic;
