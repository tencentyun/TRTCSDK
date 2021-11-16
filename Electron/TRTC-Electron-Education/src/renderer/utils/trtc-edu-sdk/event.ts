/* eslint-disable no-plusplus */
// 事件发布订阅，收归trtc、im的事件
export default class Event {
  stores: any;

  on(event: string | number, fn: any, ctx: any) {
    if (typeof fn !== 'function') {
      console.error('listener must be a function');
      return;
    }

    // eslint-disable-next-line no-underscore-dangle
    this.stores = this.stores || {};
    // eslint-disable-next-line no-underscore-dangle
    (this.stores[event] = this.stores[event] || []).push({ cb: fn, ctx });
  }

  emit(event: string | number, data: any) {
    this.stores = this.stores || {};
    let store = this.stores[event];
    const args: any[] = [];

    if (store) {
      store = store.slice(0);
      // args = [].slice.call(arguments, 1),
      args[0] = {
        eventCode: event,
        data,
      };
      // eslint-disable-next-line no-plusplus
      for (let i = 0, len = store.length; i < len; i++) {
        store[i].cb.apply(store[i].ctx, args);
      }
    }
  }

  off(event: string | number, fn: any) {
    this.stores = this.stores || {};

    // all
    if (!event) {
      this.stores = {};
      return;
    }

    // specific event
    const store = this.stores[event];
    if (!store) return;

    // remove all handlers
    if (!fn) {
      delete this.stores[event];
      return;
    }

    // remove specific handler
    let cb;
    for (let i = 0, len = store.length; i < len; i++) {
      cb = store[i].cb;
      if (cb === fn) {
        store.splice(i, 1);
        break;
      }
    }
  }
}
