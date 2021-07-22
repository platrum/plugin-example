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
        <orgschema-user-selector v-model="item.user_id" :font-size="14" />
      </el-form-item>

      <el-form-item label="Текстовое поле" prop="text">
        <ui-text-editor v-model="item.text" class="text-editor" bordered />
      </el-form-item>

      <el-form-item
        prop="date"
        label="Дата"
        :rules="[{ required: true, message: 'Заполните дату'}]"
      >
        <el-date-picker
          v-model="item.date"
          type="date"
          placeholder="Заполните дату"
          size="small"
        />
      </el-form-item>

      <el-form-item label="Строковое поле" prop="string_field">
        <el-input v-model="item.string_field" size="small" />
      </el-form-item>

      <el-form-item label="Булево поле" prop="bool_field">
        <el-checkbox v-model="item.bool_field" />
      </el-form-item>

      <el-form-item label="Числовое поле" prop="int_field">
        <el-input-number v-model="item.int_field" size="small" />
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
  props: {
    value: Object,
  },
  data() {
    return {
      isSidebarVisible: false,
      item: {
        creation_date: null,
        user_id: null,
      },
    };
  },
  watch: {
    value: {
      immediate: true,
      handler(val) {
        this.item = $utils.object.clone(val);
      },
    },
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
      this.$emit('input', this.item);
      this.resetState();
    },
    resetState() {
      this.isSidebarVisible = false;
      this.$emit('hide');
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

    .text-editor {
      line-height: 20px;
    }
  }
}
</style>
