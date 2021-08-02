# Инструкция по созданию плагина

Данная инструкция поможет вам научиться создавать плагины в `Platrum`.

## Установка плагина в проект

Чтобы начать работу с плагинами вам необходимо установить модуль `plugins` в проект.
Для установки обратитесь в тех. поддержку через виджет помощи, который доступен на любой странице вашего проекта.

Управление плагинами осуществляется на странице настроек `/settings/page/plugins/list`.
Для доступа к этой странице в проекте вам необходимо обладать правами `Администрирование плагинов` (обратитесь к администратору проекта в случае отсутствия доступа).

@TODO rework

Во время разработки плагина для проверки промежуточного результата работы неудобно каждый раз обращаться к веб-интерфейсу для загрузки текущей версии плагина.
Вместо интерфейса вы можете воспользоваться скриптом загрузки `upload.sh`, который располагается в корне этого репозитория.
Для работы скрипта вам потребуется установить следующие переменные окружения:

* `PLATRUM_API_KEY` - апи ключ вашего проекта
* `PLATRUM_API_PROJECT` - хост вашего проекта

После установки переменных окружения, вы можете вызвать скрипт, передавая ему имя вашего плагина первым параметром:

```
./upload.sh example
```

## Общая структура плагина

Плагин имеет простую структуру: он состоит из файлов конфигурации и файлов фронтенда, которые находятся в корневых папках `config` и `frontend` соответственно.

### Файлы конфигурации

* `main.yml` - [базовый файл конфигурации](#базовая-конфигурация) (обязательный)
* `routes.yml` - [определение маршрутов](#добавление-маршрутов)
* `schema.yml` - [определение сущностей](#работа-с-данными)
* `access.yml` - [определение доступов](#добавление-доступов)
* `translations.yml` - [переводы](#)

### Frontend

* app.js - в этом файле вы
* pages.js - здесь экспортируются страницы приложения

### app.js


### pages.js

## Базовая конфигурация

Для того чтобы ваш плагин заработал, необходимо добавить базовый файл конфигурации `config/main.yml`.
В этом файле определяются системное и человекочитамое имена плагина, краткое описание функциональности, а так же перечисляются зависимости от модулей `Platurm`.

```yml
module: plugin-example
name: Пример плагина
description: Описание плагина
dependencies:
  - ui
  - ui-collection
  - ui-element
  - company
```

Где:

* `module` - системное название плагина (наличие `plugin-` префикса **обязательно**)
* `name` - человекочитаемое имя плагина
* `description` - краткое описание функциональности плагина
* `dependencies` - перечисление зависимостей плагина от системных модулей `Platrum`

## Маршрутизация

@TODO

## Работа с данными

Для работы с данными вам необходимо сущность, с которой вы собираетесь работать в файле `config/schema.yml`.
Для получения/сохранения/удаления сущностей платформа предоставляет `api`, который будет описан далее.

### Объявление сущности

Пример объявления сущности `example_item` с набором полей `fields`:

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

### Добавление доступов

Для создания доступа объявите доступ в файле конфигурации `config/access.yml`:

```yml
user_creation:
  name: Создание пользователей
```

После объявления доступа, он появится на странице доступов `/settings/page/common/access`.
[Подробнее](https://help.platrum.ru/article/45-article) о доступах.

## Добавление страницы

Для добавления страницы нужно:

* Создать `vue` компонент страницы
* Объявить `frontend` роут в файле `config/routes.yml`
* экспортировать компонент страницы в `frontend/pages.js`.

### Создание компонента

Версия vue - 2.5.16

Пример `vue` компонента страницы можно посмотреть в папке `frontend/pages/examplePage`.

### Добавление маршрутов

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

Для того, чтобы ваш плагин появился на странице модуля его

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

### Сохранение

Для сохранения одной или нескольких сущностей вы можете использовать методы `storeOne` или `storeMany` соответственно.

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

## Работа с правами пользователей

### Добавление доступа

Для создания доступа объявите доступ в файле конфигурации `config/access.yml`:

```yml
user_creation:
  name: Создание пользователей
```

После объявления доступа, он появится на странице доступов `/settings/page/common/access`.
[Подробнее](https://help.platrum.ru/article/45-article) о доступах.

### Проверка доступа

Пример функции проверки доступов:
```js
/**
 * @returns {bool}
 */
function hasCreationAccess() {
  return this.$platform.access.hasAccess('plugin-example.user_creation');
}
```

### Настройка доступов к сущностям

#### Общая структура доступа

```js
const permission = {
  action: 'view',
  block_id: 1,
  user_id: null,
  allow_nested: null,
  allow_everyone: null,
  allow_managers: null,
}
```
где:

* `action` - название действия (может быть любым)
* `block_id` - ID должности
* `user_id` - ID пользователя
* `allow_nested` - доступ для подчиненных
* `allow_everyone` - доступ для всех пользователей 
* `allow_managers` - доступ для руководителей

#### Примеры

* Доступ на чтение для пользователей с должностью c ID = `2`

```json
{
    "action": "read",
    "block_id": 2
}
```

* Доступ на редактирование пользователю с ID = `1a8642fa90a52d5103c114f5b1a30aae`

```json
{
  "action": "edit",
  "user_id": "1a8642fa90a52d5103c114f5b1a30aae"
}
```

* Доступ на чтение для всех пользователей

```json
{
  "action": "read",
  "allow_everyone": true
}
```

* Доступ на чтение для всех руководителей пользователя с ID = `1a8642fa90a52d5103c114f5b1a30aae`

```json
{
  "action": "read",
  "user_id": "1a8642fa90a52d5103c114f5b1a30aae",
  "allow_managers": true
}
```

* Доступ на редактирование для должности с ID = `2` и для всех подчиненных этой должности 

```json
{
  "action": "read",
  "block_id": 2,
  "allow_nested": true
}
```

## Работа с переводами

@TODO