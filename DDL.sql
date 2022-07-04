--- Cоздание базы данных
create database otus;
select datname from pg_database;

---Создание табличных пространств
mkdir /data
mkdir /data/tablespace1
mkdir /data/tablespace2
chown postgres:postgres /data/tablespace1
chown postgres:postgres /data/tablespace2
 
create tablespace tablespace1 location '/data/tablespace1';
create  tablespace tablespace2 location '/data/tablespace2';
 
select * from pg_tablespace;

--- Создание схем
create schema documents;
create schema administration;

---Создание ролей
create role admin;
grant all on all tables in schema administration to admin;
grant all on all tables in schema documents to admin;
alter database otus owner to admin;

create user ritter;
grant admin to ritter;

select * from pg_roles;
select * from pg_user;

---Создание таблиц
DROP TABLE IF EXISTS administration.users;

CREATE TABLE IF NOT EXISTS administration.users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(32) NOT NULL,
  nickname VARCHAR(32) NOT NULL,
  email VARCHAR(255) NOT NULL,
  bio VARCHAR(512) NULL DEFAULT NULL,
  gender CHAR(1) NOT NULL,
  image VARCHAR(512) NULL DEFAULT NULL)
TABLESPACE tablespace1;
 

DROP TABLE IF EXISTS documents.states;

CREATE TABLE IF NOT EXISTS documents.states (
  id SERIAL PRIMARY KEY,
  description VARCHAR(10) NOT NULL)
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.articles;

CREATE TABLE IF NOT EXISTS documents.articles (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  image VARCHAR(512) NULL DEFAULT NULL,
  state INT NOT NULL,
  autor_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  CONSTRAINT autor_id_articles_fk
    FOREIGN KEY (autor_id)
    REFERENCES administration.users (id),
  CONSTRAINT state_id_articles_fk
    FOREIGN KEY (state)
    REFERENCES documents.states (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.comments;

CREATE TABLE IF NOT EXISTS documents.comments (
  id SERIAL PRIMARY KEY,
  author_id INT NOT NULL,
  acticle_id INT NOT NULL,
  body VARCHAR(1000) NOT NULL,
  state INT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  edited_at TIMESTAMP NOT NULL,
  CONSTRAINT acticle_id_comments_fk
    FOREIGN KEY (acticle_id)
    REFERENCES documents.articles (id),
  CONSTRAINT author_id_comments_fk
    FOREIGN KEY (author_id)
    REFERENCES administration.users (id),
  CONSTRAINT state_id_comments_fk
    FOREIGN KEY (state)
    REFERENCES documents.states (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.articles_comments;

CREATE TABLE IF NOT EXISTS documents.articles_comments (
  article_id INT NOT NULL,
  comment_id INT NOT NULL,
  PRIMARY KEY (article_id, comment_id),
  CONSTRAINT article_id_articles_comments_fk
    FOREIGN KEY (article_id)
    REFERENCES documents.articles (id),
  CONSTRAINT comment_id_articles_comments_fk
    FOREIGN KEY (comment_id)
    REFERENCES documents.comments (id))
TABLESPACE tablespace2;

   
DROP TABLE IF EXISTS documents.articles_likes;

CREATE TABLE IF NOT EXISTS documents.articles_likes (
  user_id INT NOT NULL,
  article_id INT NOT NULL,
  PRIMARY KEY (user_id, article_id),
  CONSTRAINT article_id_articles_likes_fk
    FOREIGN KEY (article_id)
    REFERENCES documents.articles (id),
  CONSTRAINT user_id_articles_likes_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.tags;

CREATE TABLE IF NOT EXISTS documents.tags (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(25) NOT NULL)
TABLESPACE tablespace2;
  
 
DROP TABLE IF EXISTS documents.articles_tags;

CREATE TABLE IF NOT EXISTS documents.articles_tags (
  article_id INT NOT NULL,
  tag_id INT NOT NULL,
  PRIMARY KEY (article_id, tag_id),
  CONSTRAINT article_id_articles_tags_fk
    FOREIGN KEY (article_id)
    REFERENCES documents.articles (id),
  CONSTRAINT tag_id_articles_tags_fk
    FOREIGN KEY (tag_id)
    REFERENCES documents.tags (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.comments_likes;

CREATE TABLE IF NOT EXISTS documents.comments_likes (
  user_id INT NOT NULL,
  comment_id INT NOT NULL,
  PRIMARY KEY (user_id, comment_id),
  CONSTRAINT comment_id_comments_likes_fk
    FOREIGN KEY (comment_id)
    REFERENCES documents.comments (id),
  CONSTRAINT user_id_comments_likes_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS documents.favorite_articles;

CREATE TABLE IF NOT EXISTS documents.favorite_articles (
  user_id INT NOT NULL,
  article_id INT NOT NULL,
  PRIMARY KEY (user_id, article_id),
  CONSTRAINT article_id_favorite_articles_fk
    FOREIGN KEY (article_id)
    REFERENCES documents.articles (id),
  CONSTRAINT user_id_favorite_articles_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace2;
   
   
DROP TABLE IF EXISTS documents.favorite_tags;

CREATE TABLE IF NOT EXISTS documents.favorite_tags (
  user_id INT NOT NULL,
  tag_id INT NOT NULL,
  PRIMARY KEY (user_id, tag_id),
  CONSTRAINT tag_id_favorite_tags_fk
    FOREIGN KEY (tag_id)
    REFERENCES documents.tags (id),
  CONSTRAINT user_id_favorite_tags_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace2;


DROP TABLE IF EXISTS administration.following_users;

CREATE TABLE IF NOT EXISTS administration.following_users (
  user_id INT NOT NULL,
  following_user_id INT NOT NULL,
  PRIMARY KEY (user_id, following_user_id),
  CONSTRAINT following_user_id_following_users_fk
    FOREIGN KEY (following_user_id)
    REFERENCES administration.users (id),
  CONSTRAINT user_id_following_users_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace1;
    

DROP TABLE IF EXISTS administration.invite_codes;

CREATE TABLE IF NOT EXISTS administration.invite_codes (
  code CHAR(20) PRIMARY KEY,
  issuer_id INT NOT NULL,
  user_id INT NOT NULL,
  used BOOLEAN NOT NULL DEFAULT '0',
  CONSTRAINT issuer_id_invite_codes_fk
    FOREIGN KEY (issuer_id)
    REFERENCES administration.users (id),
  CONSTRAINT user_id_invite_codes_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace1;

   
DROP TABLE IF EXISTS administration.roles;

CREATE TABLE IF NOT EXISTS administration.roles (
  id SERIAL PRIMARY KEY,
  description VARCHAR(10) NOT NULL)
TABLESPACE tablespace1;


DROP TABLE IF EXISTS administration.roles_users;

CREATE TABLE IF NOT EXISTS administration.roles_users (
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT role_id_roles_users_fk
    FOREIGN KEY (role_id)
    REFERENCES administration.roles (id),
  CONSTRAINT user_id_roles_users_fk
    FOREIGN KEY (user_id)
    REFERENCES administration.users (id))
TABLESPACE tablespace1;
