# WeatherBot

Пример бота на языке elixir, который показывает погоду по переданному адресу

Для запуска:
  
  * Переименуйте `.env.dist` в `.env` и заполните
    - `NADIA_KEY=key` #ключ бота от @botFather
    - `ANALITIC_KEY=key` #ключ апи от chatbase
    - `YANDEX_KEY=key` #ключ погодного апи от яндекса
  * `mix deps.get && mix deps.compile && mix phx.server`

