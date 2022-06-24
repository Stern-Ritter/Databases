# Запусть сервер PostgreSql
#### Выполненные команды для запуска postgresql в docker:
1. <code>docker search postgres</code>
1. <code>docker pull postgres</code>
1. <code>docker run --rm --name postgres -e POSTGRES_PASSWORD=1234 -d -p 5432:5432 postgres</code>
#### Подключение через консоль:
1. <code>docker exec -it postgres bash</code>
1. <code>su postgres</code>
1. <code>psql</code>

![Модель](https://github.com/Stern-Ritter/Databases/blob/homework-3/Подключение%20через%20консоль.jpg?raw=true)


#### Подключение через DBeaver:
![Модель](https://github.com/Stern-Ritter/Databases/blob/homework-3/Подключение%20через%20DBeaver.jpg?raw=true)