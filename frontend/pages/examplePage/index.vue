<template>
  <company-layout>
    <div slot="toolbar">
      <el-button
        v-if="$platform.access.hasAccess('plugin-example.user_creation')"
        type="primary"
        size="mini"
        icon="el-icon-plus"
        @click="openSidebar"
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
      without-settings
      show-actions
    >
      <div class="actions" slot="actions" slot-scope="{ row }">
        <el-button type="danger" icon="el-icon-delete" size="mini" circle @click="deleteItem(row)" />
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

export default {
  components: {
    Sidebar,
  },
  async created() {
    await this.loadItems({});
  },
  data() {
    return {
      isLoading: false,
      filter: {},
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
      entities: [],
      selectedItem: this.createDefaultItem(),
    };
  },
  methods: {
    openSidebar() {
      this.$refs.sidebar.open();
    },
    handleSidebarHide() {
      this.selectedItem = this.createDefaultItem();
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
    setItemAccessRules(item) {
      return {
        ...item,
        access_rules: [
          { action: 'view', allow_everyone: true },
          { action: 'edit', user_id: this.$modules.user.profile.getCurrent().user_id },
        ],
      };
    },
    async storeItem(item) {
      try {
        const itemWithAccessRules = this.setItemAccessRules(item);
        const storedItem = await this.$modules.plugins.api.storeOne('plugin-example.example_item', itemWithAccessRules);
        this.entities.push(storedItem);
      } catch (e) {
        this.$uiNotify.error('Ошибка при сохранении');
        throw e;
      }
    },
    async loadItems({ dbFormatFilter = [] }) {
      this.isLoading = true;
      this.entities = await this.$modules.plugins.api.select('plugin-example.example_item', dbFormatFilter);
      this.isLoading = false;
    },
    async deleteItem(row) {
      await this.$modules.plugins.api.delete('plugin-example.example_item', [
        ['id', '=', row.id],
      ]);
      this.entities = this.entities.filter(entity => entity.id !== row.id);
      this.$uiNotify.success('Сущность удалена');
    },
  },
};
</script>
