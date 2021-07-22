<template>
  <ui-sidebar
    v-model="isSidebarVisible"
    title="Добавить сущность"
    class="sidebar"
    @hide="resetState"
  >
    <el-form class="content" ref="form" :model="item" label-width="150px">
      <el-form-item
        label="Пользователь"
        prop="user_id"
        :rules="[{ required: true, message: 'Выберите пользователя'}]"
      >
        <orgschema-user-selector
          v-model="item.user_id"
          :font-size="14"
        />
      </el-form-item>

      <el-form-item
        prop="creation_date"
        label="Дата создания"
        :rules="[{ required: true, message: 'Заполните дату'}]"
      >
        <ui-element-date-picker
          v-model="item.creation_date"
          placeholder="Выберите дату создания"
          size="small"
          style="width: 100%"
        />
      </el-form-item>
      <el-form-item>
        <el-button
          type="primary"
          size="small"
          @click="submit"
        >
          <span>Сохранить</span>
        </el-button>
      </el-form-item>
    </el-form>
  </ui-sidebar>
</template>

<script>

export default {
  data() {
    return {
      isSidebarVisible: false,
      item: {
        creation_date: null,
        user_id: null,
      },
    };
  },
  methods: {
    open() {
      this.isSidebarVisible = true;
    },
    async submit() {
      try {
        await this.$refs.form.validate();
      } catch (e) {
        this.$uiNotify.error('Заполните необходимые поля');
        return;
      }
      this.$emit('submit', this.item);
      this.resetState();
    },
    resetState() {
      this.item = {
        creation_date: null,
        user_id: null,
      };
      this.isSidebarVisible = false;
    },
  },
};
</script>

<style lang="less" scoped>
.sidebar {
  top: 0 !important;
  width: 550px;
  background: white;

  .content {
    padding-right: 30px;
  }
}
</style>
