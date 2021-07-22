<template>
  <company-layout>
    <div slot="toolbar" class="toolbar-controls">
      <el-button
        v-if="hasCreationAccess"
        type="primary"
        size="mini"
        icon="el-icon-plus"
        @click="createItem"
      />
    </div>

    <ui-collection-panel-filter
      slot="sidebar"
      v-model="filter"
      :settings="filterSettings"
      @submit="loadItems"
    />

    <ui-collection-panel-table
      v-loading="isLoading"
      :columns="columns"
      :rows="entities"
      show-actions
      empty-text="Пусто!"
      @show-row-info="openSidebar"
    >
      <div class="actions" slot="actions" slot-scope="{ row }">
        <ui-button
          class="remove-btn"
          size="small"
          icon="trash"
          type="clear"
          @click="remove(row)"
        />
      </div>
    </ui-collection-panel-table>

    <sidebar ref="sidebar" @submit="storeItem" />
  </company-layout>
</template>

<script>
import Sidebar from './Sidebar';

const entityName = 'plugin-example.example_item';

export default {
  components: {
    Sidebar,
  },
  props: {
    itemId: String,
  },
  async created() {
    await this.loadItems({});
  },
  data() {
    return {
      isLoading: true,
      filter: {},
      entities: [],
      filterSettings: [
        {
          type: 'in',
          component: 'orgschema-user-selector',
          label: 'Пользователь',
          name: 'user_id',
          props: {
            multiple: true,
            'show-deleted': true,
          },
        },
        {
          type: 'dateRange',
          label: 'Дата создания',
          name: 'creation_date',
          format: 'date',
        },
      ],
      columns: [
        {
          name: '#',
          id: 'id',
          width: '50px',
          format: 'id',
          sortable: true,
          clickable: true,
          sortType: 'number',
        },
        {
          id: 'user_id',
          width: '250px',
          name: 'Пользователь',
          format: 'user',
          sortable: true,
        },
        {
          component: 'ui-readable-date-time',
          name: 'Дата создания',
          id: 'creation_date',
          sortable: true,
          sortType: 'date',
          getComponentAttrs(row) {
            return { date: row.creation_date, capitalizeFirstLetter: true };
          },
        },
      ],
    };
  },
  computed: {
    hasCreationAccess() {
      // @TODO implement
      return true;
    },
    currentUserId() {
      return this.$modules.user.profile.getCurrent().user_id;
    },
  },
  methods: {
    async loadItems({ dbFormatFilter = [] }) {
      this.isLoading = true;
      this.entities = await this.$modules.plugins.api.select(entityName, dbFormatFilter);
      this.isLoading = false;
    },
    createItem() {
      this.$refs.sidebar.open();
    },
    async storeItem(item) {
      // @TODO add access set
      const storedItem = await this.$modules.plugins.api.storeOne(entityName, item);
      this.entities.push(storedItem);
    },
    async remove(row) {
      await this.$modules.plugins.api.delete(entityName, [
        ['id', '=', row.id],
      ]);
      $utils.array.removeFirst(this.entities, { id: row.id });
      this.$uiNotify.success('Сущность удалена');
    },
    openSidebar() {
      // @TODO implement
    },
  },
};
</script>

<style lang="less" scoped>
.remove-btn {
  color: red;
}
</style>
