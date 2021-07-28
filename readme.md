# Инструкция по созданию плагина

## Базовая конфигурация

Для того чтобы ваш плагин заработал, необходимо объявить базовый `config/main.yml` файл конфигурации:

```yml
module: plugin-example
name: Пример плагина
description: Описание плагина
dependencies:
  - ui
  - company
```

Где:
* `module` - системное название плагина, наличие `plugin-` префикса обязательно
* `name` - человекочитаемое имя плагина
* `description` - краткое описание функциональности плагина
* `dependencies` - перечисление зависимостей плагина от системных модулей `Platrum`


## Добавление страницы

Для добавления страницы нужно:

* Создать `vue` компонент страницы
* Объявить `frontend` роут в файле `config/routes.yml`
* экспортировать компонент страницы в `frontend/pages.js`.

### Создание компонента 

Пример `vue` компонента страницы можно посмотреть в папке `frontend/pages/examplePage`.

### Объявление роута

Пример объявления роута `examplePage` с путем `/example` и заголовком `Example page`:
```yml
frontend:
  examplePage:
    pattern: /example
    title: Example page
```

### Экспорт страницы

Пример экспорта страницы `examplePage` в `frontend/pages.js`:
```js
import examplePage from './pages/examplePage';

export default {
  examplePage,
};
```

### Результат

После выполнения описанных выше шагов в проекте станет доступна страница по пути: `/plugin-example/example`.

## Добавление страницы в меню модуля

@TODO add description

```js
// frontend/app.js

export default {
  slots: {
    'company.header': [
      {
        name: 'Example page',
        route: 'plugin-example.examplePage',
      },
    ],
  },
};
```

## Роутинг

@TODO



## Работа с данными

Для начала работы с данными вам необходимо описать имя и поля сущности, с которой вы собираетесь работать в файле `config/schema.yml`.
Для получения/сохранения/удаления сущностей платформа предоставляет api, описанное ниже. 

### Объявление сущности

Пример объявления сущности `example_item` с набором полей:

```yml
# config/schema.yml

example_item:
  fields:
    user_id:
      type: string
    text:
      type: string
    date:
      type: date
    string_field:
      type: string
    bool_field:
      type: bool
    int_field:
      type: int
```

### Сохранение

Для сохранения одной или нескольких сущностей вы можете использовать методы `storeOne`, `storeMany` соответственно.

Примеры:

```js
/**
 * @param {object} item
 * @return {Promise<object>}
 */
async function storeItem(item) {
  return await this.$modules.plugins.api.storeOne('plugin-example.example_item', item);
}

/**
 * @param {object[]} items
 * @return {Promise<object[]>}
 */
async function storeItems(items) {
  return await this.$modules.plugins.api.storeMany('plugin-example.example_item', items);
}
```

### Загрузка

Для получения ранее сохраненных данных используйте метод `select`.
Пример:

```js
/**
 * @param {array} filter
 * @return {Promise<object[]>}
 */
async function loadItems(filter) {
  return await this.$modules.plugins.api.select('plugin-example.example_item', filter);
}
```

### Удаление

Для удаления данных вы можете использовать метод `delete`.
Пример:

```js
/**
 * @param {object} item
 * @return {Promise<void>}
 */
async function deleteItem(item) {
  await this.$modules.plugins.api.delete('plugin-example.example_item', [
    ['id', '=', item.id],
  ]);
}
```

### Фильтры

Методы `select` и `delete` поддерживают работу с фильтрами.
Фильтр это массив, состоящий из трех частей: имени поля, оператора и значения:
`['field_name', 'operator', 'value']`, где:
* `field_name` - имя поля, описанное в `config/schema.yml` в массиве `fields`
* `operator` - оператор, используемый при фильтрации. Поддерживаемые значения: `=`, `>`, `>=`, `<`, `<=`, `in`, `not_in`
* `value` - искомое значение поля

Фильтры могут объединяться в массив, образуя `and` условие:

```js
this.$modules.plugins.api.select('plugin-example.example_item', [
  ['user_id', 'in', ['userId1', 'userId2']],
  ['date', '>=', '2021-08-15T21:00:00Z'],
  ['date', '<=', '2021-08-16T20:59:59Z'],
  ['int_field', '=', 100],
]);
```

Если вам требуется найти данные, которые подходят хотя бы под один фильтр, вы можете воспользоваться `or` оператором:

```js
this.$modules.plugins.api.select('plugin-example.example_item', [
  {
      or: [
        ['user_id', 'in', ['userId1', 'userId2']],
        ['int_field', '=', 100],
      ],
  },
]);
```

## Проверка доступов

@TODO

# Установка плагина в проект

@TODO