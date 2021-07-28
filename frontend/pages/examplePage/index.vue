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
      clickable
      empty-text="Пусто!"
      selectable
      show-actions
      @row-click="openSidebar"
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

    <sidebar
      ref="sidebar"
      v-model="selectedItem"
      @input="storeItem"
      @hide="handleSidebarHide"
    />
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
      selectedItem: this.createDefaultItem(),
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
          type: '~=',
          label: 'Текстовое поле',
          name: 'text',
        },
        {
          type: '~=',
          label: 'Строковое поле',
          name: 'string_field',
        },
        {
          type: 'date',
          label: 'Дата',
          name: 'date',
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
          id: 'text',
          name: 'Текст',
          format: 'text',
          is_hidden_by_default: true,
        },
        {
          component: 'ui-readable-date-time',
          name: 'Дата',
          id: 'date',
          sortable: true,
          sortType: 'date',
          getComponentAttrs: row => ({ date: row.date, capitalizeFirstLetter: true }),
        },
        {
          id: 'string_field',
          name: 'Строковое поле',
          sortable: true,
        },
        {
          id: 'bool_field',
          name: 'Булево поле',
          width: '100px',
          format: 'bool',
          align: 'right',
          sortable: true,
        },
        {
          id: 'int_field',
          name: 'Числовое поле',
          width: '100px',
          format: 'number',
          sortType: 'number',
          align: 'center',
          sortable: true,
        },
      ],
    };
  },
  computed: {
    hasCreationAccess() {
      return this.$platform.access.hasAccess('plugin-example.user_creation');
    },
    currentUserId() {
      return this.$modules.user.profile.getCurrent().user_id;
    },
  },
  watch: {
    itemId: {
      immediate: true,
      async handler(val) {
        if (!val) {
          return;
        }
        const itemId = Number(val);
        let entity = this.entities.find(entity => entity.id === itemId);
        if (!entity) {
          [entity] = await this.$modules.plugins.api.select(entityName, [
            ['id', '=', itemId],
          ]);
        }
        this.selectedItem = entity;
        this.$refs.sidebar.open();
      },
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
      try {
        const itemWithAccessRules = this.setItemAccessRules(item);
        const storedItem = await this.$modules.plugins.api.storeOne(entityName, itemWithAccessRules);
        this.entities.push(storedItem);
      } catch (e) {
        this.$uiNotify.error('Ошибка при сохранении');
        throw e;
      }
    },
    setItemAccessRules(item) {
      return {
        ...item,
        access_rules: [
          {
            action: 'view',
            allow_everyone: true,
          },
          {
            action: 'edit',
            user_id: this.currentUserId,
          },
        ],
      };
    },
    async remove(row) {
      await this.$modules.plugins.api.delete(entityName, [
        ['id', '=', row.id],
      ]);
      $utils.array.removeFirst(this.entities, { id: row.id });
      this.$uiNotify.success('Сущность удалена');
    },
    openSidebar(item) {
      this.$platform.router.redirect('plugin-example.examplePage', { itemId: item.id });
    },
    handleSidebarHide() {
      this.selectedItem = this.createDefaultItem();
      this.$platform.router.redirect('plugin-example.examplePage');
    },
    createDefaultItem() {
      return {
        user_id: null,
        text: null,
        date: null,
        string_field: null,
        bool_field: null,
        int_field: null,
      };
    },
  },
};
</script>

<style lang="less" scoped>
.remove-btn {
  color: red;
}
</style>
