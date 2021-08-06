// custom-tab-Bar/index.js
Component({
  /**
   * 组件的属性列表
   */
  properties: {

  },

  /**
   * 组件的初始数据
   */
  data: {
    selected: '-1', // 当前选中菜单项，第一个是0
    list: [
      {
        'pagePath': '/pages/index/index',
        'text': '首页',
        'iconPath': '/pages/Resources/icon/home.png',
        'selectedIconPath': '/pages/Resources/icon/home-light.png',
      },
      {
        'pagePath': '/pages/personal/personal',
        'text': '个人中心',
        'iconPath': '/pages/Resources/icon/personal.png',
        'selectedIconPath': '/pages/Resources/icon/personal-light.png',
      },
    ],
  },

  /**
   * 组件的方法列表
   */
  methods: {
    _switchTab(e) {
      const _path = e.currentTarget.dataset.path
      wx.switchTab({ url: _path })
    },
  },

  pageLifetimes: {
    show: function() {

    },
    hide: function() {
      // 页面被隐藏
    },
    resize: function(size) {
      // 页面尺寸变化
    },
  },
})
