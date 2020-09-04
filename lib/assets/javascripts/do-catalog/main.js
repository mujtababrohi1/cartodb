// import Vue from 'vue';

// import App from './App';

// Vue.config.productionTip = false;

// /* eslint-disable no-new */
// new Vue({
//   el: '#do-catalog',
//   components: { App },
//   template: '<App/>'
// });

import Vue from 'vue';
import App from './App.vue';
import wrap from '@vue/web-component-wrapper';
import NameBlock from './NameBlock.vue';

import Router from 'vue-router';

Vue.use(Router);

const CustomElement = wrap(Vue, NameBlock);

Vue.config.productionTip = false;

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/test',
      name: 'test',
      component: NameBlock,
      meta: {
        title: () => 'TEST'
      }
    }
  ]
});

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')

// https://cli.vuejs.org/guide/build-targets.html#app