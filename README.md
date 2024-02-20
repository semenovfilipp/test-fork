# Yandex ML Service

## Оглавление:
- [Введение](#Введение)
- [Создание сервиса в Caila.io](#Создание сервиса в Caila.io)
- [Создание проекта](#создание-проекта)
- [Создаем точку старта нашего приложения](#создаем-точку-старта-нашего-приложения)
- [Соединяем IDE с сервисом Caila.io](#Соединяем IDE с сервисом Caila.io)
- [Подготовка к запуску приложения](#подготовка-к-запуску-приложения)
- [Получаем данные для коммуникации с YandexGPT](#Получаем данные для коммуникации с YandexGPT)
- [Создаем сервисный класс](#создаем-сервисный-класс)
- [Наполнение сервиса](#наполнение-сервиса)
- [Обновление InitConfig](#Обновление InitConfig)
- [Отправление полученных данных в Caila](#Отправление полученных данных в Caila)



## Введение
В данном руководстве представлены шаги по созданию и настройке сервиса для взаимодействия с платформой Caila.io и использования модели YandexGPT для генерации текста.


### Данный сервис позволяет:
- Отправить запрос из платформы Caila.io в наше приложение.
- Передавать запрос из приложения в YandexGPT чат.
- Получать ответ из YandexGPT чата в наше приложение.
- Отправить ответ в Caila.io из нашего приложения.


##  Создание сервиса в Caila.io
    - Зарегистрируйтесь/войдите в аккаунт на сервисе Caila.io.
    - Перейдите в раздел "Мое пространство" в правом верхнем углу.
    - Нажмите "Создать сервис".
    - В качестве образа выберите "fit-action-example-image".
    - Дайте имя сервису и нажмите "Создать".
    - Далее нажмите на только что созданный сервис.
    - В разделе "Настройки" выберите "Хостинг" -> "Отладочное подключение" -> "Активировать".
    - Перед вами появится графа "env-переменные". Нажмите на нее и сохраните эти переменные в текстовом редакторе. Чуть позже мы рассмотрим их подробнее.



---

##  Создание проекта

- Создайте проект в вашей IDE. В качестве сборщика можно выбрать Gradle или Maven.

### Пример шаблона проекта на Maven
[Ссылка](https://github.com/just-ai/mlp-java-service-template) на шаблон проекта

(Вы также можете найти пример по истории коммитов и на Gradle)

- Подключите зависимость.

#### Для Maven

```xml
<dependency>
    <groupId>com.mlp</groupId>
    <artifactId>mlp-java-sdk</artifactId>
    <version>release-SNAPSHOT</version>
</dependency>
```

#### Для Gradle

```kotlin
dependencies {
    implementation 'com.mlp:mlp-java-sdk:release-SNAPSHOT'
}
```

Чтобы зависимость скачалась, необходимо добавить репозиторий для скачивания этой зависимости.

#### Для Maven

```xml
<repositories>
    <repository>
        <id>nexus-public</id>
        <url>https://nexus-open.just-ai.com/repository/maven-public/</url>
    </repository>
</repositories>
```

#### Для Gradle

```kotlin
repositories {
    maven {
        url 'https://nexus-open.just-ai.com/repository/maven-public/'
    }
}
```


---

##  Создаем точку старта нашего приложения

- Создайте класс `Main.kt`.

В этом классе мы будем наследоваться от класса из `mlp-sdk` `MlpPredictServiceBase`.

```kotlin
class Main : MlpPredictServiceBase<ChatCompletionRequest, ChatCompletionResult>()
```

Это нужно нам для того, чтобы иметь доступ к методу `predict`.

```kotlin
 override fun predict(req: ChatCompletionRequest): ChatCompletionResult 
```

Метод `predict` будет получать объект `ChatCompletionRequest` и возвращать `ChatCompletionResult`.

**ChatCompletionRequest** - объект, который будет приходить к нам в приложение при помощи `Mlp SDK`. В этом объекте нас интересуют поля:

**ChatCompletionResult** - объект, в который мы будем перекладывать полученные данные из JSON от `YandexGPT`. Чуть позже мы рассмотрим, какие поля мы будем передавать.


**ChatCompletionRequest** состоит из:
1. `messages` типа `ChatMessage`.
2. `ChatMessage` состоит из:
    - `content` - текст, который мы получаем из сервиса `caila.io`, и который мы передадим в `YandexGPT` для обработки.
    - `role` - это поле имеет два значения в `YandexGPT`:
        1. `"system"` - ключевая тема нашего сообщения.
        2. `"user"` - сам текст.

3. `temperature` - поле, которое отвечает за настроение и эмоциональную окраску ответа `YandexGPT`. Оно содержится в формате `Double` от `0.1` до `1.0`.
4. `maxTokens` - поле, которое определяет максимальное количество токенов.
5. `stream` - поле, которое определяет, будет ли ответ подаваться построчно или в один момент. У нас значение будет `false`, т.к. мы будем передавать единоразово сообщение.

Пример JSON запроса для `YandexGPT`:

```
{
  "modelUri": "gpt://<folder_ID>/yandexgpt-lite",
  "completionOptions": {
    "stream": false,
    "temperature": 0.6,
    "maxTokens": "2000"
  },
  "messages": [
    {
      "role": "system",
      "text": "Find errors in the text and fix them"
    },
    {
      "role": "user",
      "text": "Laminate flooring is sutiable for instalation in the kitchen or in a child's room. It withsatnds moisturre and mechanical dammage thanks to a proctive layer of melamine films 0.2 mm thick and a wax-treated interlocking systme."
    }
  ]
}
```

`modelUri` — идентификатор модели, которая будет использоваться для генерации ответа. Параметр содержит идентификатор каталога Yandex Cloud или идентификатор дообученной в DataSphere модели.

`completionOptions` — параметры конфигурации запроса:

- `stream` — включает потоковую передачу частично сгенерированного текста. Принимает значения `true` или `false`.
- `temperature` — чем выше значение этого параметра, тем более креативными и случайными будут ответы модели. Принимает значения от `0` (включительно) до `1` (включительно). Значение по умолчанию: `0.6`.
- `maxTokens` — устанавливает ограничение на выход модели в токенах. Максимальное число токенов генерации зависит от модели.

`messages` — список сообщений, которые задают контекст для модели:

- `role` — роль отправителя сообщения:
    - `user` — предназначена для отправки пользовательских сообщений к модели.
    - `system` — позволяет задать контекст запроса и определить поведение модели.
    - `assistant` — используется для ответов, которые генерирует модель. При работе в режиме чата ответы модели, помеченные с ролью `assistant`, включаются в состав сообщения для сохранения контекста беседы. Не передавайте сообщения пользователя с этой ролью.
- `text` — текстовое содержимое сообщения.

Документация - [YandexGPT API](https://cloud.yandex.com/en/docs/yandexgpt/quickstart#api_1)




---

##  Соединяем IDE с сервисом Caila.io

Для того чтобы наш сервис в Caila.io имел соединение с нашей средой разработки (IDE), нам нужно добавить в наше окружение (контекст) переменные окружения, которые мы брали ранее на этапе "Создание сервиса в Caila.io".

1. В IntelliJ IDEA (или другом продукте JetBrains) сверху рядом с кнопками "Run", "Debug", "Stop" нажмите на кнопку Main.kt (название вашего класса). Если такого класса нет, то запустите проект.
2. Далее нажмите на "Edit Configurations" и в классе Main в разделе "Environment variables" вставьте полученные ранее из Caila.io переменные окружения.

   Переменные должны быть разделены знаком ';'.

   **Пример:**
   Было:
   ```
   MLP_ACCOUNT_ID=234567
   MLP_MODEL_ID=3456
   MLP_INSTANCE_ID=9898
   ```
   Стало:
   ```kotlin
   MLP_ACCOUNT_ID=234567;
   MLP_MODEL_ID=3456;
   MLP_INSTANCE_ID=9898;
   ```

3. Далее укажем в нашем приложении, что мы будем брать эти переменные (env) из окружения IDE (контекста).

   Это делается следующим образом:

```kotlin
class Main(
    override val context: MlpExecutionContext
) : MlpPredictServiceBase<ChatCompletionRequest, ChatCompletionResult>() 
```

Здесь мы присваиваем переменной `context` типа `MlpExecutionContext` значения из окружения при помощи поля `systemContext` (будет далее), то есть значения, которые мы берем из контекста нашей IDE.



---

##  Подготовка к запуску приложения

Для запуска нашего приложения мы должны создать функцию `main`, которая будет являться точкой входа в наше приложение. В этой функции мы создаем экземпляр класса `MlpServiceSDK`.

Вызываем методы:
- `start()` для запуска приложения
- `blockUntilShutdown()` для ожидания завершения приложения

```kotlin
fun main() {
    // Здесь мы передаем лямбда выражение
    val actionSDK = MlpServiceSDK({ Main(MlpExecutionContext.systemContext) })

    actionSDK.start()
    actionSDK.blockUntilShutdown()
}
```

Для того чтобы удовлетворить конструктор `MlpPredictServiceBase` в классе `Main`, мы создадим объекты `ChatCompletionRequest` и `ChatCompletionResult`.

```kotlin
class Main(
    override val context: MlpExecutionContext
) : MlpPredictServiceBase<ChatCompletionRequest, ChatCompletionResult>(REQUEST_EXAMPLE, RESPONSE_EXAMPLE) {

    companion object {
        val REQUEST_EXAMPLE = ChatCompletionRequest(
            model = null,
            messages = emptyList(),
            temperature = null,
            topP = null,
            n = null,
            stream = null,
            stop = emptyList(),
            maxTokens = null,
            presencePenalty = null,
            frequencyPenalty = null,
            logitBias = null,
            user = null
        )
        val RESPONSE_EXAMPLE = ChatCompletionResult(
            null,
            "message",
            created = System.currentTimeMillis(),
            "",
            emptyList(),
            null
        )
    }
}
```

---

##  Получаем данные для коммуникации с YandexGPT

Для начала работы нам нужен интерфейс YandexCloud. Установите его, следуя этой инструкции: [Установка Yandex Cloud CLI](https://cloud.yandex.com/ru/docs/cli/quickstart#install).

Для коммуникации с YandexGPT нам нужно получить следующие данные:

1. **OAuth token** - токен авторизации. Получить его можно здесь в разделе "API", пункт 2: [Создание OAuth токена](https://cloud.yandex.com/ru/docs/iam/operations/iam-token/create#api_1).

2. **IAM Token** - токен сессии (время жизни 12 часов). Получить его можно здесь в разделе "API", пункт 3: [Создание IAM токена](https://cloud.yandex.com/ru/docs/iam/operations/iam-token/create#api_1).

3. **Идентификатор каталога** - пространство, в котором создаются и группируются ресурсы Yandex. Получить его можно [здесь](https://cloud.yandex.com/ru/docs/resource-manager/operations/folder/get-id) в разделе "CLI" или выполнить следующую команду в терминале:

   ```bash
   yc resource-manager folder list
   ```

**Важно:** У вашего аккаунта должна быть роль `ai.languageModels.user` или выше на каталоге, который вы будете использовать.
Назначить роль можно [здесь](https://console.cloud.yandex.ru/folders):

1. Выберите ваше облако.
2. Каталог -> ... -> Права доступа -> Выберите аккаунт из списка -> ... -> Изменить роли -> 'ai.languageModels.user'.

---

Вот текст для README в формате Markdown:

---

###  Создаем сервисный класс

В нашем примере создаем класс `YandexChatService`, который будет содержать методы для работы с Yandex.

Для работы нам понадобятся несколько `data class`:

- `InitConfig` - класс содержащий сервисные конфигурации для доступа к YandexGPT. Сами конфигурации мы установим в переменные окружения, но будем обращаться к ним через поля этого класса.

```kotlin
data class InitConfig(var iAmToken: String, val xFolderId: String, val modelUri: String, val oauthToken: String)
```

Где:
- `iAmToken` - токен для доступа к Yandex.
- `xFolderId` - наш каталог.
- `modelUri` - URI модели.

- `PredictConfig` - класс содержащий конфигурации для отправки запроса на Yandex. Это опциональные конфигурации, которые будут использованны по умолчанию если из сервиса Caila не пришло таких параметров. Эти параметры нужны для YandexGPT, так как он требует их в своем JSON запросе.

```kotlin
data class PredictConfig(
   val maxTokens: String = "2000", val temperature: Double = 0.6, val stream: Boolean = false
)
```

Также `data class` для принятия JSON от YandexGPT:

```kotlin
data class ResultResponse(val result: Result)
data class Result(val alternatives: List<Alternatives>, val usage: Usage, val modelVersion: String)
data class Message(val role: String, val text: String)
data class Alternatives(val message: Message, val status: String)
data class Usage(val inputTextTokens: String?, val completionTokens: String?, val totalTokens: String?)
```

Классы соответствуют получаемому JSON ответу от YandexGPT.

Константы, необходимые для работы с YandexGPT:

```kotlin
private const val URL_YANDEX_COMPLETION = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"
private val MEDIA_TYPE_JSON = "application/json".toMediaType()
private const val TOKEN_EXPIRATION_DURATION = 12 * 60 * 60 * 1000
```

Эти константы используются в классе для отправки запросов к Yandex API.

1. `URL_YANDEX_COMPLETION`: Это URL-адрес, по которому отправляются запросы на завершение текста в Yandex API.

2. `MEDIA_TYPE_JSON`: Тип контента для JSON данных.

3. `TOKEN_EXPIRATION_DURATION`: Длительность жизни токена аутентификации в миллисекундах.

---
##  Наполнение сервиса

Для успешной работы приложения необходимы следующие методы и объекты:

### Методы:
1. **createRequestBody(req: ChatCompletionRequest)**:
   - Создает JSON-тело запроса на основе объекта `ChatCompletionRequest`, содержащего данные для отправки запроса на сервер Yandex.

2. **sendMessageToYandex(req: ChatCompletionRequest)**:
   - Отправляет запрос на сервер Yandex для обработки текста с помощью модели YandexGPT.

3. **updateIamToken()**:
   - Обновляет IAM токен, необходимый для аутентификации при отправке запросов на сервер Yandex.

4. **getNewIamToken(oauthToken: String)**:
   - Получает новый IAM токен, используя OAuth токен.

5. **parseNewToken(responseData: String?)**:
   - Парсит полученный новый IAM токен из ответа сервера Yandex.

### Объекты:
1. **YandexRequestBuilder**:
   - Предназначен для построения HTTP-запросов к серверу YandexGPT.

2. **YandexResponseParser**:
   - Отвечает за парсинг JSON-ответа от сервера YandexGPT.

Эти методы и объекты необходимы для взаимодействия с сервером YandexGPT: `YandexRequestBuilder` используется для отправки запросов, а `YandexResponseParser` для обработки ответов и извлечения нужной информации.

Реализация данных методов и объектов доступна по [ссылке](https://github.com/semenovfilipp/yandex-ml-service/tree/master/src/main/kotlin/io/caila/yandex_ml_service).

##  Обновление InitConfig

После получения необходимых данных, таких как IAM Token, идентификатор каталога (xFolderId), ModelUri и OAuthToken, мы можем обновить нашу переменную среды (env переменную) и обращаться к ней через поля класса InitConfig.

#### Было:

```plaintext
MLP_ACCOUNT_ID=345678;
MLP_MODEL_ID=456789;
MLP_INSTANCE_ID=989889;
MLP_MODEL_NAME=yandex-ml-service;
MLP_SERVICE_TOKEN=1000130747.58700.3456789876543456789;
MLP_REST_URL=app.caila.io;
MLP_GRPC_HOST=gate.caila.io:443;
MLP_GRPC_SECURE=true;
SERVICE_CONFIG={}
```

#### Стало:

```plaintext
MLP_ACCOUNT_ID=345678;
MLP_MODEL_ID=456789;
MLP_INSTANCE_ID=989889;
MLP_MODEL_NAME=yandex-ml-service;
MLP_SERVICE_TOKEN=1000130747.58700.3456789876543456789;
MLP_REST_URL=app.caila.io;
MLP_GRPC_HOST=gate.caila.io:443;
MLP_GRPC_SECURE=true;
SERVICE_CONFIG={
  "iAmToken":"",
  "xFolderId":"5678909090",
  "modelUri":"gpt://5678909090/yandexgpt-lite",
  "oauthToken":"y0_A567890707976fAATuwQAAAAD7BME3AADWJfItliJJFrhlNCcuFlgwILxxCg"
}
```

- **iAmToken**: Наш токен сессии. Поле должно быть пустым, так как мы автоматически его обновляем.
- **xFolderId**: Наш идентификатор каталога на YandexCloud.
- **modelUri**: URI модели, к которой мы обращаемся, вместе с нашим каталогом.
- **oauthToken**: Токен для запроса нового IAM Token.

Теперь мы можем обращаться к этим полям следующим образом:

```kotlin
private val initConfig = JSON.parse(System.getenv().get("SERVICE_CONFIG") ?: "{}", InitConfig::class.java)
```

Это обновление позволяет нам легко управлять необходимыми данными и обновлять их в переменной среды для дальнейшего использования в нашем приложении.

Реализация доступна здесь: [ссылка на репозиторий](https://github.com/semenovfilipp/yandex-ml-service)

## Отправление полученных данных в Caila

После получения ответа от сервера YandexGPT, данные отправляются в Caila.io для дальнейшей обработки. Вот как это происходит:

1. **Отправление запроса на сервер YandexGPT**: Метод `sendMessageToYandex(req)` отправляет запрос на сервер YandexGPT с объектом `ChatCompletionRequest`, содержащим данные для предсказания текста.

2. **Обработка ответа от YandexGPT**: Результат запроса сохраняется в переменной `resultResponse`. Затем из ответа извлекаются альтернативы завершения текста и информация о использовании токенов.

3. **Формирование запроса для Caila**: Полученные данные используются для создания запроса в формате, ожидаемом Caila. В запросе указываются сообщения пользователя и альтернативы, сформированные на основе ответа от YandexGPT.

4. **Отправка запроса в Caila**: Созданный запрос отправляется в Caila.io для дальнейшей обработки и генерации ответа.

Пример запроса, отправляемого в Caila.io, содержит сообщения пользователя:

```kotlin
{
  "messages": [
    {
      "role": "user",
      "content": "Привет, как дела?"
    }
  ],
 "stream": false
}
```

Пример ответа от YandexGPT, отправляемого в Caila.io, содержит альтернативы завершения текста и информацию о использовании токенов:

```kotlin
{
  "created": 1708423746523,
  "model": "18.01.2024",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Здравствуйте! И я приветствую вас в ответ. Спасибо за ваш вопрос. Дела идут [так, как идут], а как ваши? 😊"
      }
    }
  ],
  "usage": {
    "prompt_tokens": 19,
    "completion_tokens": 27,
    "total_tokens": 46
  }
}
```

