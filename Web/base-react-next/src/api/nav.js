import config from '@config/nav';

const navConfig = [];
const idObj = {};
const titleObj = {};
Object.values(config).forEach((item, index) => {
  const itemConfig = {};
  itemConfig.id = index + 1;
  itemConfig.title = item.name['zh-CN'];
  if (item.content && item.content.length > 0) {
    itemConfig.type = 'group';
    itemConfig.content = item.content.map((contentItem, index) => {
      const newItem = {
        id: (itemConfig.id * 100) + index,
        title: contentItem.name['zh-CN'],
        path: contentItem.path,
      };
      idObj[newItem.path] = newItem.id;
      titleObj[newItem.path] = newItem.title;
      return newItem;
    });
  } else {
    itemConfig.type = 'item';
  }
  if (item.path) {
    itemConfig.path = item.path;
    idObj[item.path] = itemConfig.id;
    titleObj[item.path] = itemConfig.title;
  }
  if (item.enPath) {
    itemConfig.enPath = item.enPath;
  }
  navConfig.push(itemConfig);
});

export function getNavConfig(pageName) {
  return {
    activeId: idObj[pageName],
    activeTitle: titleObj[pageName],
    navConfig,
  };
}
