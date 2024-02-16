## Описание класса `MlpClientSDK`

Класс `MlpClientSDK` представляет собой клиентский SDK для взаимодействия с сервисом MLP (Machine Learning Platform). Он обеспечивает удобный интерфейс для отправки запросов к сервису, обработку ответов, управление подключением и обработку ошибок.

### Поля класса

- `config`: Конфигурация клиента MLP.
- `connectionToken`: Токен для аутентификации при подключении к сервису.
- `billingToken`: Токен для выставления счетов за использование сервиса.
- `channel`: Атомарная ссылка на управляемый канал gRPC для взаимодействия с сервером.
- `stub`: Стаб для асинхронных gRPC вызовов.
- `apiClient`: Клиент для взаимодействия с API сервиса MLP.
- `backoffJob`: Задание для периодической проверки готовности канала и переподключения в случае необходимости.

### Методы класса

- `init`: Инициализация клиента, подключение к серверу и настройка обработки переподключения.
- `reconnect`: Переподключение к серверу в случае разрыва соединения.
- `connect`: Подключение к серверу MLP через gRPC.
- `isConnected`: Проверка текущего состояния подключения.
- `awaitConnection`: Ожидание готовности подключения.
- `predictBlocking`: Блокирующий вызов для отправки запроса на предсказание.
- `predict`: Асинхронный вызов для отправки запроса на предсказание.
- `extBlocking`: Блокирующий вызов для отправки расширенного запроса.
- `ext`: Асинхронный вызов для отправки расширенного запроса.
- `sendRequestPayload`: Отправка запроса с данными и ожидание ответа.
- `sendRequest`: Отправка запроса и ожидание ответа.
- `executePredictRequest`: Выполнение запроса на предсказание.
- `withRetry`: Повторное выполнение запроса с обработкой ошибок и переподключением.
- `processResultFailure`: Обработка ошибок в результате выполнения запроса.
- `shutdown`: Завершение работы клиента, закрытие соединения.
- `launchBackoffJob`: Запуск задания для периодической проверки готовности канала и переподключения.
- `buildPredictRequest`: Построение запроса на предсказание.
- `buildExtRequest`: Построение расширенного запроса.

Этот класс обеспечивает удобное взаимодействие с сервисом MLP, обеспечивая асинхронные и блокирующие методы отправки запросов, обработку ошибок и автоматическое переподключение в случае разрыва соединения.