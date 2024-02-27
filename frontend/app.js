import _ from 'underscore';

export default {
  slots: {
    'page.layout.navbar.company': [
      {
        name: 'Пример страницы',
        route: 'plugin-example.examplePage',
      },
    ],
  },
  modules: {
    menu: {
      items: [{
        id: 'plugin-example',
        title: window.t('plugin-example|Пример плагина'),
        icon: 'ghost',
        url: {
          route: 'plugin-example.examplePage',
        },
        order: 100,
      }],
    },
  },
  initHook() {
    console.log('grouped routes', _.groupBy(__CONTEXT__.routes, r => r.module));
  },
};
