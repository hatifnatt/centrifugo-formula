<!-- omit in toc -->
# centrifugo formula

Формуля для установки и настройки Centrifugo

* [Использование](#использование)
* [Доступные стейты](#доступные-стейты)
  * [centrifugo](#centrifugo)
  * [centrifugo.repo](#centrifugorepo)
  * [centrifugo.repo.install](#centrifugorepoinstall)
  * [centrifugo.repo.clean](#centrifugorepoclean)
  * [centrifugo.install](#centrifugoinstall)
  * [centrifugo.binary.install](#centrifugobinaryinstall)
  * [centrifugo.binary.clean](#centrifugobinaryclean)
  * [centrifugo.package.install](#centrifugopackageinstall)
  * [centrifugo.package.clean](#centrifugopackageclean)
  * [centrifugo.config](#centrifugoconfig)
  * [centrifugo.config.clean](#centrifugoconfigclean)
  * [centrifugo.service](#centrifugoservice)
  * [centrifugo.service.install](#centrifugoserviceinstall)
  * [centrifugo.service.clean](#centrifugoserviceclean)

## Использование

* Создаем pillar с данными, см. `pillar.example` для качестве примера, привязываем его к хосту в pillar top.sls.
* Применяем стейт на целевой хост `salt 'centrifugo-01*' state.sls centrifugo saltenv=base pillarenv=base`.
* Применить формулу к хосту в state top.sls, для выполнения оной при запуске `state.highstate`.

## Доступные стейты

### centrifugo

Мета стейт, выполняет все необходимое для настройки сервиса на отдельном хосте.

### centrifugo.repo

Вызывает [centrifugo.repo.install](#centrifugorepoinstall)

### centrifugo.repo.install

Стейт для настройки официального репозитория <https://packagecloud.io/FZambia/centrifugo/install#manual-deb>

### centrifugo.repo.clean

Стейт для удаления репозитория.

### centrifugo.install

Вызывает стейт для установки Centrifugo в зависимости от значения пиллара `use_upstream`:

* `binary` или `archive`: установка из архива `centrifugo.binary.install`
* `package` или `repo`: установка из пакетов `centrifugo.package.install`

### centrifugo.binary.install

Установка Centrifugo из архива

### centrifugo.binary.clean

Удаление Centrifugo установленного из архива

### centrifugo.package.install

Установка Centrifugo из пакетов

### centrifugo.package.clean

Удаление Centrifugo установленного из пакетов

### centrifugo.config

Создает конфигурационные файлы. Запускает сервис.

### centrifugo.config.clean

Удаляет конфигурационные файлы. НЕ вызывается при запуске `centrifugo.clean`, единственный вариант запуска данного стейта - ручной вызов.

```bash
salt minion_id state.sls centrifugo.config.clean
```

### centrifugo.service

Управляет состоянием сервиса centrifugo, в зависимости от значений пилларов `centrifugo.service.status`, `centrifugo.service.on_boot_state`.

### centrifugo.service.install

Устанавливает файл сервиса Centrifugo, на данный момент поддерживается только одна система инициализации - `systemd`.

### centrifugo.service.clean

Останавливает сервис, выключает запуск сервиса при старте ОС, удаляет юнит файл `systemd`.
