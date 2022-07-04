---3. Ќапишите запрос на добавление данных с выводом информации о добавленных строках.
insert into administration.users 
(username, nickname, email, gender)
values('Pauline Bernt', 'Falefama', 'nora81@yahoo.com', 'f'),
('H?vard Agnete', 'Gagrlus', 'eirik21@hotmail.com', 'm'),
('Benjamin Ebba', 'Hedan', 'amalie_johansen@gmail.com', 'm'),
('Vigdis Knut', 'Alierinn', 'jenny.solberg@hotmail.com', 'f'),
('Eline Jesper', 'Chanoda', 'hedda79@gmail.com', 'f')
returning id, username;

insert into documents.states
(description)
values('pending'),
('approved'),
('rejected')
returning *;

insert into documents.articles
(title, description, body, state, autor_id, created_at, updated_at)
values
('9 Ridiculous Rules About travel',
'Travel chaos as airlines given green light to axe flights',
'Travel chaos: Travellers have been hit with cancellations, delays and missing baggage. Photo: PA
Holidaymakers should brace for even more travel chaos in the coming days as airlines have been given a green light to cancel flights this summer without incurring in any fines.
Airlines are expected to announce a fresh wave of cancellations over the summer period as the government introduced an "airline slot amnesty".
Under this plan, airlines will be able to cancel flights without being penalised for not using their airport slot, but must finalise their summer schedule by Friday 8 July.
If a flight is planned later this summer and airlines feel they will not be able to staff it, they can cancel it without incurring fines or penalties.
Heathrow is expected to be affected the most by the cancellations as London busiest airport struggles to cope with demand.',
1,
6,
now(),
now()),
('17 Tricks About CATS You Wish You Knew Before',
'SPCA PETS: Cats find support with each other',
'The Taunton Animal Shelter Pets of the Week are "Bonded Buddies," a couple of male domestic short hair cats.
Theyre bonded because they are 9 years old, and have lived together since they were kittens.
Their family could no longer care for them.
They are sweet and friendly cats, with pretty blue and green eyes.
The Taunton Animal Shelter Pets of the Week are "Bonded Buddies," a couple of male domestic short hair cats.
An approved adoption application is required to bring them home.
Email ds4paws@hotmail.com, call the Taunton Animal Shelter at 508-822-1463, or visit www.tauntonshelter.petfinder.com.
This article originally appeared on The Taunton Daily Gazette: Pets of the Week Bonded Buddies Taunton Animal Shelter cat rescue',
1,
6,
now(),
now()),
('Picture Your PAINTING On Top. Read This And Make It So',
'John K. Painting Named Director Of American Federation Of MusiciansТ Electronic Media Services Division Following Tragic Death Of His Predecessor',
'John K. Painting has been named director of the American Federation of MusiciansТ Electronic Media Services Division (EMSD) and assistant to the president
 following the tragic death of EMSD director Pat Varriale, who was struck and killed last month by a hit-and-run MTA bus on Staten Island. He was 69.
УI have immense respect for John and his thorough knowledge of AFMТs media agreements,Ф said AFM president Ray Hair, who made the appointment. УDuring John
 PaintingТs tenure as division assistant director, working with Pat Varriale, he demonstrated his ability to tackle and resolve the difficult and complex
 problems that arise in the rapidly changing world we encounter in the negotiation and administration of electronic media agreements.Ф',
 2,
 7,
 now(),
now()),
('The Ultimate Secret Of IDEAS',
'Tomlinson: Celebrate Independence Day with diverse ideas and independent thinking',
'Independence Day is when we celebrate the birth of a nation that prioritizes individual liberty over social conformity, which is why itТs so sad that so many
 Texans want to cleanse our state of politically diverse ideas.
УI have grown weary of your liberal bent. I have often had the same thought: Why donТt you move to a more liberal-friendly state?Ф Nancy Reese writes.
УIf you really hate red Texas, might I suggest you move to a blue state?Ф Dan Barth asked.
УHey Chris, move to California or New York,Ф Rennie Baker ordered.
Those are a sampling from the last few weeks. Never mind that my family has been here since 1849 or that I graduated from the University of Texas at Austin.
Does it matter that I always carried a small Texas flag in my bag while traveling the world for good luck?
TOMLINSONТS TAKE: Crazy secession talk overshadows Texas Republican Party platforms good ideas.',
3,
8,
now(),
now())
returning id;

select * from administration.users;
select * from documents.states;
select * from documents.articles;


---1. Ќапишите запрос по своей базе с регул€рным выражением, добавьте по€снение, что вы хотите найти.
---Ќайти пользователей, у которых им€ начинаетс€ на букву 'b' а фамили€ на букву 'e' независимо от регистра
select id, username, nickname, email, bio, gender, image
from administration.users
where username ~* '^(b).*\s(e)';

---2. Ќапишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как пор€док соединений в FROM вли€ет на результат? ѕочему?
---Ќа left join вли€ет пор€док соединини€ таблиц, так как дл€ таблицы, котора€ наход€тс€ слева от оператора идет поиск всех значений, 
---соответствующих по ключу соединени€, при этом все записи из правой таблицы, дл€ которых соответствие не найдено, не включаютс€ в итоговый
---набор данных.
--- Ќа inner join не вли€ет пор€д соединени€ таблиц, так как все записи и левой и правой таблицы, по которым не найдены соответстви€ по
---ключу соединени€ в противоположной таблице, не включаютс€ в итоговый набор данных.
select 
  a.title,
  a.description,
  a.body,
  s.description as state,
  u.username,
  u.nickname,
  u.email,
  a.created_at,
  a.updated_at
from documents.articles as a
left join administration.users as u
  on a.autor_id = u.id
inner join 
  (
    select id, description
    from documents.states
    where description = 'pending'
  ) as s
  on a.state = s.id;

---4. Ќапишите запрос с обновлением данные использу€ UPDATE FROM
create table administration.users_stat
(user_id int primary key, 
articles_count int,
first_article_date timestamp);

insert into administration.users_stat
(user_id)
select id
from administration.users;

update administration.users_stat
set articles_count = (
  select count(id)
  from documents.articles as a
  where a.autor_id = administration.users_stat.user_id
);

update administration.users_stat
set first_article_date = a.min_article_date
from (
  select autor_id, min(created_at) as min_article_date
  from documents.articles
  group by autor_id) as a
where a.autor_id = administration.users_stat.user_id;

select * from administration.users_stat;

---5. Ќапишите запрос дл€ удалени€ данных с оператором DELETE использу€ join с другой таблицей с помощью using.
delete from documents.articles
  using administration.users_stat
where administration.users_stat.user_id = documents.articles.autor_id
and administration.users_stat.articles_count < 2
returning documents.articles.*;

select * from documents.articles;