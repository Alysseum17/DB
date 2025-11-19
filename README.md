# Звіт з нормалізації бази даних (Lab 5)

## 1\. Аналіз функціональних залежностей (FD)

Для підтвердження коректності структури бази даних було визначено функціональні залежності для основних сутностей.
Позначення: $X \rightarrow Y$ (X однозначно визначає Y).

**1. Таблиця `users`**
* **PK:** `user_id`
* **FD:** `user_id` $\rightarrow$ `username`, `email`, `avatar_url`, `created_at`, `is_active`

**2. Таблиця `quizes`**
* **PK:** `quiz_id`
* **FD:** `quiz_id` $\rightarrow$ `author_id`, `title`, `description`, `time_limit`, `attempts_limit`, `difficulty`, `created_at`, `updated_at`, `is_active`
* *Примітка:* `author_id` визначає автора, але не навпаки (автор може мати багато квізів), тому залежність йде від `quiz_id`.

**3. Таблиця `questions`**
* **PK:** `question_id`
* **FD:** `question_id` $\rightarrow$ `quiz_id`, `question_text`, `question_type`, `points`, `is_active`

**4. Таблиця `answer_options`**
* **PK:** `answer_option_id`
* **FD:** `answer_option_id` $\rightarrow$ `question_id`, `option_text`, `is_correct`

**5. Таблиця `reviews`**
* **PK:** `review_id`
* **FD:** `review_id` $\rightarrow$ `user_id`, `quiz_id`, `rating`, `review_text`, `created_at`, `updated_at`
* *Примітка:* Рейтинг залежить від конкретного відгуку (`review_id`), а не просто від пари "користувач-квіз" (якщо дозволено кілька відгуків, хоча за логікою частіше один, але технічно PK тут `review_id`).

**6. Таблиця `quiz_attempts`**
* **PK:** `attempt_id`
* **FD:** `attempt_id` $\rightarrow$ `user_id`, `quiz_id`, `started_at`, `finished_at`, `score`

**7. Таблиця `question_responses`**
* **PK:** `question_response_id`
* **FD:** `question_response_id` $\rightarrow$ `attempt_id`, `question_id`, `free_text_answer`, `earned_points`

**8. Таблиця `selected_answers`**
* **PK:** `(question_response_id, answer_option_id)` (Складений ключ)
* **FD:** Тривіальна залежність. Весь рядок ідентифікується повним ключем. Неключових атрибутів немає.

-----

## 2\. Перевірка нормальних форм

### Перша нормальна форма (1NF)

 **Вимога:** Атомарність атрибутів, відсутність повторюваних груп 

  * **Перевірка:** У початковій схемі відсутні списки значень (наприклад, варіанти відповідей не записані в одну клітинку через кому, як "A, B, C"). Вони винесені в окрему таблицю `answer_options`.
  * **Статус:** Схема відповідає 1NF.

### Друга нормальна форма (2NF)

 **Вимога:** Відсутність часткових залежностей (неключові атрибути залежать від усього складеного ключа) 

  * **Перевірка:**
      * Більшість таблиць мають простий ключ (`id`).
      * Таблиця `selected_answers` має складений ключ (`question_response_id`, `answer_option_id`), але вона слугує лише для зв'язку (link table) і не має додаткових атрибутів, що залежали б від частини ключа.
  * **Статус:** Схема відповідає 2NF.

### Третя нормальна форма (3NF)

 **Вимога:** Відсутність транзитивних залежностей (неключовий атрибут залежить від іншого неключового атрибута) 

  * **Перевірка:** У таблиці `reviews` є `user_id` та `quiz_id`. Текст відгуку залежить від ID відгуку (`review_id`), а не від користувача чи вікторини окремо. Ми не зберігаємо `author_name` у таблиці `quizes`, що усуває транзитивну залежність (ID $\rightarrow$ AuthorID $\rightarrow$ AuthorName).
  * **Статус:** Основні таблиці відповідають 3NF.

-----

## 3\. Виявлення надлишковості та аномалій

 В ході аналізу було виявлено таблицю, яка **порушує принципи нормалізації** через зберігання похідних даних 

**Проблемна таблиця:** `user_quiz_stats`

```sql
CREATE TABLE user_quiz_stats (
    user_id INTEGER,
    quiz_id INTEGER,
    best_score SMALLINT, -- Дублювання! Можна обчислити як MAX(score)
    attempts SMALLINT,   -- Дублювання! Можна обчислити як COUNT(*)
    last_score SMALLINT, -- Дублювання! Останній запис по даті
    PRIMARY KEY (user_id, quiz_id)
);
```

**Виявлені аномалії:**

1.  **Аномалія оновлення:** Якщо адміністратор видалить запис про спробу проходження тесту з таблиці `quiz_attempts`, значення `attempts` та `best_score` у таблиці `user_quiz_stats` стануть некоректними. Це вимагає складних тригерів для синхронізації.
2.  **Надлишковість даних:** Ми витрачаємо пам'ять на зберігання даних, які вже існують у системі, просто в іншому вигляді (у таблиці `quiz_attempts`).

-----

## 4\. Застосування нормалізації (Fix)

Щоб привести схему до чистої архітектури та уникнути аномалій, ми замінимо фізичну таблицю на **SQL View (Представлення)**. Це гарантує, що дані завжди актуальні та не дублюються.

### Крок 1: Видалення надлишкової таблиці

```sql
DROP TABLE IF EXISTS user_quiz_stats;
```

### Крок 2: Створення віртуального представлення (View)

Замість зберігання статичних даних, ми створюємо динамічний запит, який обчислює статистику "на льоту" на основі нормалізованої таблиці `quiz_attempts`.

```sql
CREATE OR REPLACE VIEW user_quiz_stats_view AS
SELECT 
    qa.user_id,
    qa.quiz_id,
    COUNT(qa.attempt_id) AS total_attempts,
    MAX(qa.score) AS best_score,
    -- Підзапит для отримання балу за останню спробу
    (SELECT score 
     FROM quiz_attempts qa2 
     WHERE qa2.user_id = qa.user_id 
       AND qa2.quiz_id = qa.quiz_id 
     ORDER BY started_at DESC 
     LIMIT 1) AS last_score,
    MAX(qa.finished_at) AS last_attempt_date
FROM quiz_attempts qa
GROUP BY qa.user_id, qa.quiz_id;
```

### Результат

Після цієї зміни:

1.  **Усунено надлишковість:** Дані про бали зберігаються лише в `quiz_attempts`.
2.  **Усунено аномалії оновлення:** При додаванні/видаленні спроби статистика оновлюється автоматично.
3.  Схема повністю відповідає вимогам **3NF**.
