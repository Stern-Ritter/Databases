# Добавляем в модель данных дополнительные индексы и ограничения

![Модель](https://github.com/Stern-Ritter/Databases/blob/homework-2/Model.jpg?raw=true)

###### Самые нагруженные таблицы: 'articles', 'comments', 'article_likes', 'comments_likes'.

###### Помимо индексов по первичным ключам (PK) которые будут созданы автоматически.

1. Таблица 'users' (Пользователи):
   1. поле 'username' - индекс на это поле необходим для работы unique constraint, чтобы было невозможно создать несколько пользователей с одинаковым 'username'.
1. Таблица 'following_users' (Подписки пользователей на других пользователей):
   1. поля 'user_id' и 'following_user_id' помимо того, что данные поля являются первичным ключом, они также являются внешними ключами на поле 'id' таблицы 'users', что обеспечивает то, что в эту таблицу можно в качестве значений вставить только id существующих пользователей, также наличие этих индексов позволит быстро определять других пользователей на которых подписан пользователь и загружать статьи других пользователей, на которых подписан пользователь.
1. Таблица 'invites_codes' (Коды приглашений для регистрации):
   1. поля 'issuer_id' и 'use_id' являются внешними ключами на поле 'id' таблицы 'users', что обеспечивает то, что в эту таблицу можно в качестве значений вставить только id существующих пользователей.
1. Таблица 'roles_users' (Связь ролей и пользователей):
   1. поля 'user_id' и 'role_id' являются внешними ключами на поле 'id' таблицы 'users' и поле 'id' таблицы 'roles', что обеспечивает присвоение только существующих ролей только существующим пользователям.
1. Таблица 'comments' (Комментарии пользователей к статьям):
   1. поле 'author_id' является внешним ключом на поле 'id' таблицы 'users', что помимо обеспечения целостности: автором комментария может быть только существующий пользователь, позволит быстро подтянуть данные автора комментария для отображения информации о нем.
   2. поле 'article_id' является внешним ключом на поле 'id' таблицы 'articles', что помимо обеспечения целостности: комментарий может относится только к существующей статье, позволит быстро подтянуть все комментарии к статье.
   3. поле 'state_id' является внешним ключом на таблицу с классификатором статусов, что обеспечивает целостность данных, а также то, что можно быстро получить комментарии с определенным статусом, например, комментарии со статусом 'pending' для последующией модерации администратором.
1. Таблица 'commnent_likes' (Лайки комментариев):
   1. поля 'user_id' и 'comment_id' являются внешними ключами на поле 'id' таблицы 'users' и поле 'id' таблицы 'comments', что позволяет обеспечить целостность данных, а также за счет индексов быстро получить данные о количестве лайков комментария и данных пользователей, лайкнувших комментарий.
1. Таблица 'articles' (Статьи):
   1. поле 'author_id' является внешним ключом на поле 'id' таблицы 'users', что помимо обеспечения целостности: автором статьи может быть только существующий пользователь, позволит быстро подтянуть данные автора статьи для отображения информации о нем.
   1. поле 'state_id' является внешним ключом на таблицу с классификатором статусов, что обеспечивает целостность данных, а также то, что можно быстро получить статьи с определенным статусом, например, статьи со статусом 'pending' для последующией модерации администратором.
   1. поле 'title' - индекс по это полю позволит быстро найти статью по названию.
   1. поле 'created_at' - индекс по этому полю позволит быстро найти статью по дате создания.
1. Таблица 'articles_comments' (Связь статей и комментариев):
   1. поля 'article_id' и 'comment_id' являются внешними ключами на поле 'id' таблицы 'articles' и поле 'id' таблицы 'comments', что помимо обеспечения целостности данных позволяет быстро получить для статьи относящиеся к ней комментарии. 
1. Таблица 'articles_likes' (Лайки статей):
   1. поля 'user_id' и 'article_id' являются внешними ключами на поле 'id' таблицы 'users' и поле 'id' таблицы 'articles', что позволяет обеспечить целостность данных, а также с помощью индексов быстро получить список самых популярных по количеству лайков статей.
1. Таблица 'favorite_artcles' (Избранные статьи):
   1. поля 'user_id' и 'article_id' являются внешними ключами на поле 'id' таблицы 'users' и поле 'id' таблицы 'articles', что позволяет обеспечить целостность данных, а также с помощью индексов быстро получить список статей добавленных пользователем в избранное.
1. Таблица 'articles_tags' (Связь тегов и статей):
   1. поля 'article_id' и 'tag_id' являются внешними ключами на поле 'id' таблицы 'articles' и поле 'id' таблицы 'tags', что позволяет быстро отфильтровать пользователю статьи по выбранным тегам.
1. Таблица 'favorite_tags' (Избранные теги):
   1. поля 'user_id' и  и 'tag_id' являются внешними ключами на поле 'id' таблицы 'users' и поле 'id' таблицы 'tags', что за счёт индексов позволяет пользователю быстро получить статьи соответствующие тегам, на которые он подписан.