import config from '@config/nav';

function getPageUrl(page) {
  return `/home/${page}`;
}

const navConfig = [];
const idObj = {};
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
        url: getPageUrl(contentItem.path),
        pageContent: contentItem.pageContent
      };
      idObj[newItem.path] = newItem.id;
      return newItem;
    });
  } else {
    itemConfig.type = 'item';
  }
  if (item.path) {
    itemConfig.url = getPageUrl(item.path);
    idObj[item.path] = itemConfig.id;
  }
  if (item.pageContent) {
    itemConfig.pageContent = item.pageContent;
  }
  navConfig.push(itemConfig);
});

export function getNavConfig(pageName) {
  return {
    activeId: idObj[pageName],
    navConfig,
  };
}
