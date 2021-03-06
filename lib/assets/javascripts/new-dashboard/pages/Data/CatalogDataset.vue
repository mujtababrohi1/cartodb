<template>
  <Page class="page--data">
    <SecondaryNavigation>
      <a
        class="catalogDetail__back title is-small"
        :class="{ 'disabled': loading }"
        href="javascript:history.back()"
      >
        <img class="catalogDetail__back--icon" svg-inline src="../../assets/icons/common/back.svg"/>
        <span>{{ $t('Catalog.back') }}</span>
      </a>
    </SecondaryNavigation>

    <section class="catalogDetail container grid">
      <div class="grid-cell grid-cell--col12">
        <div v-if="loading" class="u-flex u-flex__align--center u-flex__direction--column u-mt--120">
          <span class="loading u-mr--12">
            <svg viewBox="0 0 38 38">
              <g transform="translate(1 1)" fill="none" fill-rule="evenodd">
                <circle stroke-opacity=".5" cx="18" cy="18" r="18"/>
                <path d="M36 18c0-9.94-8.06-18-18-18">
                  <animateTransform attributeName="transform" type="rotate" from="0 18 18" to="360 18 18" dur="1s" repeatCount="indefinite"/>
                </path>
              </g>
            </svg>
          </span>
          <span class="text is-txtSoftGrey is-caption u-mt--12">
            Loading {{ type }} details…
          </span>
        </div>
        <transition name="fade">
          <div v-if="!loading">
            <DatasetActionsBar
              v-if="subscription"
              :subscription="subscription"
              :slug="dataset.slug"
              class="u-mt--12"
            ></DatasetActionsBar>
            <DatasetHeader></DatasetHeader>
            <div class="grid grid-cell u-flex__justify--center">
              <NavigationTabs class="grid-cell--col12">
                <router-link :to="{ name: 'catalog-dataset-summary' }" replace>Summary</router-link>
                <router-link :to="{ name: 'catalog-dataset-data' }" replace>Data</router-link>
              </NavigationTabs>
            </div>
            <router-view></router-view>
            <GoUpButton></GoUpButton>
          </div>
        </transition>
      </div>
    </section>
  </Page>
</template>

<script>
import { mapState } from 'vuex';
import Page from 'new-dashboard/components/Page';
import SecondaryNavigation from 'new-dashboard/components/SecondaryNavigation';
import DatasetActionsBar from 'new-dashboard/components/Catalog/DatasetActionsBar';
import DatasetHeader from 'new-dashboard/components/Catalog/DatasetHeader';
import NavigationTabs from 'new-dashboard/components/Catalog/NavigationTabs';
import GoUpButton from 'new-dashboard/components/Catalog/GoUpButton';

export default {
  name: 'CatalogDataset',
  components: {
    Page,
    SecondaryNavigation,
    DatasetActionsBar,
    DatasetHeader,
    NavigationTabs,
    GoUpButton
  },
  data () {
    return {
      loading: false,
      id_interval: null
    };
  },
  computed: {
    ...mapState({
      dataset: state => state.catalog.dataset,
      type () {
        return this.$route.params.type;
      }
    }),
    subscription () {
      return this.$store.getters['catalog/getSubscriptionByDataset'](
        this.dataset.id
      );
    },
    isGeography () {
      return this.$route.params.type === 'geography';
    },
    isSubscriptionSyncing () {
      return this.subscription && this.subscription.sync_status === 'syncing';
    }
  },
  methods: {
    initializeDataset () {
      if (!this.dataset || this.dataset.slug !== this.$route.params.datasetId) {
        this.loading = true;
        Promise.all([
          this.$store.dispatch('catalog/fetchSubscriptionsList'),
          this.$store.dispatch('catalog/fetchDataset', {
            id: this.$route.params.datasetId,
            type: this.$route.params.type
          })
        ]).then(() => {
          this.loading = false;
          if (this.$route.params.datasetId !== this.dataset.slug) {
            this.$router.replace({
              params: { datasetId: this.dataset.slug }
            });
          }
        });
      }
    }
  },
  watch: {
    isSubscriptionSyncing: {
      immediate: true,
      handler () {
        clearInterval(this.id_interval);
        if (this.isSubscriptionSyncing) {
          this.id_interval = setInterval(() => {
            this.$store.dispatch('catalog/fetchSubscriptionsList');
          }, 1000);
        }
      }
    },
    type: {
      immediate: true,
      handler () {
        this.initializeDataset();
      }
    }
  },
  destroyed () {
    if (this.dataset.slug !== this.$route.params.datasetId) {
      this.$store.commit('catalog/resetDataset');
    }
    clearInterval(this.id_interval);
  }
};
</script>

<style lang="scss" scoped>
@import 'new-dashboard/styles/variables';

.catalogDetail {

  &__back {
    display: flex;
    align-items: center;
    padding: 24px 0;

    &--icon {
      width: 7px;
      height: 12px;
      margin-right: 8px;
    }
  }

  &__description {
    margin-bottom: 64px;
  }

  &__label {
    margin-bottom: 24px;
  }

  &__list {
    list-style-position: inside;
    list-style-type: disc;

    &--item {
      margin-bottom: 16px;
    }
  }
}

.catalog__icon {
  width: 24px;
  height: 24px;
  margin-right: 12px;
  background-size: contain;
}

.loading {
  svg {
    width: 40px;
    stroke: $blue--500;
    g {
      stroke-width: 2px;
      circle {
        stroke-opacity: 0.25;
      }
    }
  }
}

.go-up-button {
  position: fixed;
  z-index: 1;
  right: 24px;
  bottom: 64px;
}

a.disabled {
  cursor: default;
  pointer-events: none;
  text-decoration: none;
}

input::-ms-clear {
  display: none;
}
.fade-enter-active {
  transition: opacity .5s;
}
.fade-enter {
  opacity: 0;
}
</style>
