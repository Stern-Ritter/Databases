# Индексы
### _Индексы PostgreSQL_
> **Цель**:\
>Знать и уметь применять основные виды индексов PostgreSQL\
>Построить и анализировать план выполнения запроса\
>Уметь оптимизировать запросы для с использованием индексов\
>**Описание/Пошаговая инструкция выполнения домашнего задания**:\
> Создать индекс к какой-либо из таблиц вашей БД.\
> Прислать текстом результат команды explain, в которой используется данный индекс.\
> Реализовать индекс для полнотекстового поиска.\
> Реализовать индекс на часть таблицы или индекс на поле с функцией.\
> Написать комментарии к каждому из индексов.\
> Описать что и как делали и с какими проблемами столкнулись.

##### 1. Создать индекс к какой-либо из таблиц вашей БД.
```sql
create index nickname_idx on administration.users(nickname);
analyze administration.users;
```

##### 2. Прислать текстом результат команды explain, в которой используется данный индекс.
###### Результат команды explain до создания индекса:
```sh
Seq Scan on users  (cost=0.00..40.12 rows=118 width=1075) (actual time=0.008..0.153 rows=118 loops=1)
  Filter: ((nickname)::text = 'Mildewed'::text)
  Rows Removed by Filter: 1652
Planning Time: 0.120 ms
Execution Time: 0.167 ms
```
При выполнении запроса последовательно считывается каждая запись таблицы (Seq Scan).
Каждая запись сравнивается с условием — Filter: (nickname)::text = 'Mildewed'::text. Если условие выполняется, запись вводится в результат. Иначе — отбрасывается.

###### Результат команды explain после создания индекса:
```sh
Bitmap Heap Scan on users  (cost=5.19..24.67 rows=118 width=1075) (actual time=0.022..0.060 rows=118 loops=1)
  Recheck Cond: ((nickname)::text = 'Mildewed'::text)
  Heap Blocks: exact=18
  ->  Bitmap Index Scan on nickname_idx  (cost=0.00..5.16 rows=118 width=0) (actual time=0.015..0.015 rows=118 loops=1)
        Index Cond: ((nickname)::text = 'Mildewed'::text)
Planning Time: 0.138 ms
Execution Time: 0.078 ms
```
Bitmap Index Scan — используется индекс nickname_idx для определения нужных страниц, на которых есть записи соответствующие условию — Index Cond: ((nickname)::text = 'Mildewed'::text), а затем PostgreSQL лезет на эти страницы — Bitmap Heap Scan, где уже ищет непосредственно кортежи, которые соответствуют условию — Recheck Cond: ((nickname)::text = 'Mildewed'::text).

##### 3. Реализовать индекс для полнотекстового поиска.
###### Создание индекса полнотекстового поиска:
```sql
create index title_search_idx on documents.articles using GIN (to_tsvector('english', title));
analyze documents.articles;
```
###### Запрос на получение всех статей, у которых в названии есть слова 'gadgets'и 'instruments':
```sql
select 
	title,
	description,
	body,
	created_at
from documents.articles
where title @@ to_tsquery('gadgets | instruments' );
```

###### Результат команды explain:
```sh
Seq Scan on articles  (cost=0.00..995.70 rows=294 width=1276) (actual time=0.081..16.464 rows=294 loops=1)
  Filter: ((title)::text @@ to_tsquery('Gadgets | Instruments'::text))
  Rows Removed by Filter: 1176
Planning Time: 0.441 ms
Execution Time: 16.486 ms
```

##### 4. Реализовать индекс на часть таблицы или индекс на поле с функцией.
###### Определение количества статей со статусом '1': 'pending'
```sql
select count(1) from documents.articles where state = 1;
```

###### Создание частичного индекса на статьи со статусом '1': 'pending'
```sql
create index pending_articles_idx on documents.articles(state) where state = 1;
analyze documents.articles;
```
###### Результат команды explain до создания индекса:
```sql
explain analyze
select 
	title,
	description,
	body,
	created_at
from documents.articles
where state = 1;
```
```sh
Seq Scan on articles  (cost=0.00..264.38 rows=147 width=1276) (actual time=0.008..0.443 rows=147 loops=1)
  Filter: (state = 1)
  Rows Removed by Filter: 1323
Planning Time: 0.053 ms
Execution Time: 0.458 ms
```
При выполнении запроса последовательно считывается каждая запись таблицы (Seq Scan).
Каждая запись сравнивается с условием — Filter: state = 1. Если условие выполняется, запись вводится в результат. Иначе — отбрасывается.

###### Результат команды explain после создания индекса:
```sh
Bitmap Heap Scan on articles  (cost=8.92..233.94 rows=147 width=1276) (actual time=0.020..0.101 rows=147 loops=1)
  Recheck Cond: (state = 1)
  Heap Blocks: exact=49
  ->  Bitmap Index Scan on pending_articles_idx  (cost=0.00..8.88 rows=147 width=0) (actual time=0.011..0.011 rows=147 loops=1)
Planning Time: 0.188 ms
Execution Time: 0.122 ms
```
Bitmap Index Scan — используется индекс pending_articles_idx для определения нужных страниц, на которых есть записи соответствующие условию индекса, а затем PostgreSQL лезет на эти страницы — Bitmap Heap Scan, где уже ищет непосредственно кортежи, которые соответствуют условию — Recheck Cond: (state = 1).


##### 5. Создать индекс на несколько полей (составной индекс)
###### Создание составного индекса по полям 'nickname' и 'email'
```sql
create index nickname_email_idx on administration.users(nickname, email);
analyze administration.users;
```

###### Результат команды explain до создания индекса:
```sh
Seq Scan on users  (cost=0.00..46.90 rows=2 width=43) (actual time=0.008..0.206 rows=62 loops=1)
  Filter: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text))
  Rows Removed by Filter: 1798
Planning Time: 0.107 ms
Execution Time: 0.219 ms
```
При выполнении запроса последовательно считывается каждая запись таблицы (Seq Scan).
Каждая запись сравнивается с условием — Filter: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text)). Если условие выполняется, запись вводится в результат. Иначе — отбрасывается.

###### Результат команды explain после создания индекса:
```sh
Bitmap Heap Scan on users  (cost=4.30..10.38 rows=2 width=43) (actual time=0.025..0.058 rows=62 loops=1)
  Recheck Cond: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text))
  Heap Blocks: exact=18
  ->  Bitmap Index Scan on nickname_email_idx  (cost=0.00..4.30 rows=2 width=0) (actual time=0.017..0.017 rows=62 loops=1)
        Index Cond: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text))
Planning Time: 0.161 ms
Execution Time: 0.076 ms
```
Bitmap Index Scan — используется индекс nickname_idx для определения нужных страниц, на которых есть записи соответствующие условию — Index Cond: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text)), а затем PostgreSQL лезет на эти страницы — Bitmap Heap Scan, где уже ищет непосредственно кортежи, которые соответствуют условию —   Recheck Cond: (((nickname)::text = 'Alierinn'::text) AND ((email)::text = 'jenny.solberg@hotmail.com'::text)).

##### 6. Описать что и как делали и с какими проблемами столкнулись
Проблемы с которыми столкнулся в ходе выполнения задания:
- В select запросах PostgreSQL нельзя явно указать какой индекс использовать;
- При небольших объемах данных в таблицах PostgreSQL использует полное сканирование таблицы (Seq Scan), несмотря на наличие индексов.


##### Данные в таблицах:
###### Таблица статусов:
```sql
insert into documents.states
(description)
values('pending'),
('approved'),
('rejected');
```
###### Таблица пользователей:
```sql
insert into administration.users 
(username, nickname, email, gender)
values('Pauline Bernt', 'Falefama', 'nora81@yahoo.com', 'f'),
('Hivard Agnete', 'Gagrlus', 'eirik21@hotmail.com', 'm'),
('Benjamin Ebba', 'Hedan', 'amalie_johansen@gmail.com', 'm'),
('Vigdis Knut', 'Alierinn', 'jenny.solberg@hotmail.com', 'f'),
('Eline Jesper', 'Chanoda', 'hedda79@gmail.com', 'f'),
('Marianne Bernt', 'Aurilau', 'jake80@yahoo.com', 'f'),
('Runar Annette', 'Kittywake', 'wava9@hotmail.com', 'f'),
('Alexandra Natalie', 'Evomind', 'davon18@gmail.com', 'f'),
('Barbara Maria', 'Rubrick', 'lolita96@gmail.com', 'f'),
('Dina Agnethe', 'RowanTree', 'hillary23@gmail.com', 'f'),
('Liss Amund', 'RadishRush', 'brandyn38@gmail.com', 'f'),
('Brynhild Birgitta', 'Succubus', 'tate52@gmail.com', 'f'),
('Aase Gustav', 'Moonlighter', 'benedict45@yahoo.com', 'm'),
('Laura Frans', 'Saddlewitch', 'aubrey86@yahoo.com', 'f'),
('Anita Rikard', 'NightLady', 'efren26@yahoo.com', 'f'),
('Viljar Walter', 'Ouster', 'roscoe25@yahoo.com', 'm'),
('Tore Regina', 'MonteSuma', 'aryanna16@yahoo.com', 'f'),
('Anette Ella', 'CrosStorm', 'pansy4@yahoo.com', 'f'),
('Aina Solfrid', 'Rhenus', 'uriel81@yahoo.com', 'f'),
('Anita Gina', 'Aurilau', 'candice3@gmail.com', 'f'),
('Tonje Sidsel', 'Dreadlight', 'erich15@gmail.com', 'm'),
('Torborg Lennart', 'Gigadude', 'hipolito35@hotmail.com', 'm'),
('Martha Anders', 'Mildewed', 'leda16@gmail.com', 'f'),
('Dagfinn Edvin', 'Pralltiller', 'fredy62@yahoo.com', 'm'),
('Torleif Torild', 'CitarNosis', 'felix63@yahoo.com', 'm'),
('Teresa Herleif', 'SappySue', 'beryl62@hotmail.com', 'f'),
('Birgitta Vilde', 'Scoundrella', 'crawford18@yahoo.com', 'f'),
('Stian Rebekka', 'Mildewed', 'hillard23@yahoo.com', 'f'),
('Audhild Sonja', 'Midgeabean', 'humberto78@gmail.com', 'f'),
('Oscar Carl', 'Papaur', 'junior29@gmail.com', 'm');
```
###### Таблица статей:
```sql
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
11,
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
12,
now(),
now()),
('Picture Your PAINTING On Top. Read This And Make It So',
'John K. Painting Named Director Of American Federation Of Musicians’ Electronic Media Services Division Following Tragic Death Of His Predecessor',
'John K. Painting has been named director of the American Federation of Musicians’ Electronic Media Services Division (EMSD) and assistant to the president
 following the tragic death of EMSD director Pat Varriale, who was struck and killed last month by a hit-and-run MTA bus on Staten Island. He was 69.
“I have immense respect for John and his thorough knowledge of AFM’s media agreements,” said AFM president Ray Hair, who made the appointment. “During John
 Painting’s tenure as division assistant director, working with Pat Varriale, he demonstrated his ability to tackle and resolve the difficult and complex
 problems that arise in the rapidly changing world we encounter in the negotiation and administration of electronic media agreements.”',
1,
13,
now(),
now()
),
('The Ultimate Secret Of IDEAS',
'Tomlinson: Celebrate Independence Day with diverse ideas and independent thinking',
'Independence Day is when we celebrate the birth of a nation that prioritizes individual liberty over social conformity, which is why it’s so sad that so many
 Texans want to cleanse our state of politically diverse ideas.
“I have grown weary of your liberal bent. I have often had the same thought: Why don’t you move to a more liberal-friendly state?” Nancy Reese writes.
“If you really hate red Texas, might I suggest you move to a blue state?” Dan Barth asked.
“Hey Chris, move to California or New York,” Rennie Baker ordered.
Those are a sampling from the last few weeks. Never mind that my family has been here since 1849 or that I graduated from the University of Texas at Austin.
Does it matter that I always carried a small Texas flag in my bag while traveling the world for good luck?
TOMLINSON’S TAKE: Crazy secession talk overshadows Texas Republican Party platforms good ideas.',
2,
14,
now(),
now()
),
(
'The Best Hobbies if You Need to Take a Break from Cycling',
'The Best Hobbies if You Need to Take a Break from Cycling',
'Staying active is incredibly important, and how people do this is going to vary depending on what they identify with most and what they enjoy doing. One of the
more popular options out there that a lot of people enjoy doing is cycling.
Of course, though many benefits come with cycling, there is no getting away from the fact you will probably want to take a break from it every now and then. This
is because the act could get repetitive, and you need a little bit of time away so that when you engage with it again, you will do so in a way where you love it 
just as much as you previously did. It would be best if you were sure to pick up some other hobbies that keep you active in the meantime, as people must stay on
 top of their physical and mental health. Some potential new hobbies include the following.',
2,
15,
now(),
now()
),
(
'The top hobbies in Britain',
'The top hobbies in Britain',
'Everyone needs a little downtime in between working and other commitments, and some people are only happy when they have a project to keep them busy or a goal to work
towards. Hobbies are an important part of maintaining good mental health and work-life balance, and some of the most popular have other physical and mental health benefits
as well.
Entertainment has changed immeasurably over the last few decades and online gaming is one area that has grown significantly. The evolution of technology has made it possible
to create engaging games on almost any theme, from quizzes and logic puzzles to action and adventure games and everything in between.
Now that most people have smartphones and the internet is more widely available than ever, there are more opportunities for online gaming than ever before. Gamers can even buy
high spec phones that are designed to make gaming on the go more fun, and with thousands of games to choose from, there are options to suit anyone’s tastes and preferences.
Bingo has long been one of the most popular games in the UK and British people have long been fans of playing together. From the days when there were brick-and-mortar halls in
every town centre to the 21st century in which online gaming is a huge market, it is one of the most quintessentially British games going.',
2,
16,
now(),
now()
),
(
'Musical instruments stolen from Ridgefield High School, police say',
'Musical instruments stolen from Ridgefield High School, police say',
'Police are looking for this vehicle of interest connected to a larceny of various musical instruments from Ridgefield High School earlier this year.
Police are looking for this vehicle of interest connected to a larceny of various musical instruments from Ridgefield High School earlier this year.
The Ridgefield Police Department said the larceny took place on March 28.
Despite the theft, Superintendent Susie Da Silva said that students were still able to continue with the band and orchestra programs. The programs will not be affected in the fall,
she added. Police released photos Monday afternoon of both a vehicle and person of interest in the case.
Anyone with information about the person or vehicle of interest are asked to contact Detective DuBord at 203-438-6531. Anonymous tips can also be submitted by calling 203-431-2345.
Liz Hardaway is a breaking news reporter for Hearst Connecticut Media through the Hearst Fellowship Program.
She previously worked at the San Antonio Express-News to help cover city hall and local issues. She also worked at the Sun Newspapers in Southwest Florida as a general assignment reporter
covering politics, business, and health.
Liz graduated from Ohio Wesleyan University in 2018 with a B.A. in journalism. She enjoys cooking, reading and playing with her dachshund, Finn.',
2,
17,
now(),
now()
),
(
'German therapeutic musical instrument maker makes music accessible to all',
'German therapeutic musical instrument maker makes music accessible to all',
'Gotz Rausch squats on a cushion on the floor of his workshop in Lunow-Stolzenhagen and lightly strokes the strings on a rectangular wooden box on legs.
It creates a soothing, vibrating hum. Rausch, an instrument maker, then uses his other hand to adjust something beneath the box, creating a lightly buzzing sound.
"This is a kotamo, a mixture of three different instruments," he says.
Rausch doesnt need any sheet music to create the soothing tones from his combination instrument.
"Thats just the great thing about therapeutic musical instruments. You can play them without taking long lessons to do so, and it creates access to the soul."
Thats why these wooden musical wonders are so versatile, being used in settings from hospitals to childrens facilities, music schools and psychotherapy or physical therapy practices, he says.
Rausch has spent the last five years building a total of 20 different instruments in his workshop in rural Brandenburg, the German state that surrounds the capital Berlin. A native of Hamburg,
he learned the trade 25 years ago in Berlin.
Back then, his teacher was among the few people who knew how to make therapy instruments, he says. Now, Germany is home to some 20 specialists, according to Rausch.
After all, the benefits of music therapy are well researched and widely known. More and more sound therapists are being trained.',
2,
18,
now(),
now()
),
(
'How weather can change the shape and sound of musical instruments',
'How weather can change the shape and sound of musical instruments',
'Summer is the time for outdoor concerts. But how do the summer heat and humidity impact the instruments providing such delightful tunes?
FOX Weather talked to experts — who are themselves musicians — about the impact/role weather can make/play on drums, guitars, pianos, winds and strings.
“Drums are the root, the core of a lot of the music we listen to,” said Daryl Anderson, drum designer/artist support for Yamaha Corporation of America.
Drum shells are typically made of wood such as maple, birch and Mahogany. On the other hand, snare drums, the primary drum heard in a lot of music, can also be made of metal.  
The circular surface that stretches across a drum shell, called the drumhead or skin, is often made of plastics. (As the name suggests, skins were originally made of natural materials, such as goatskin and cowhide).
Weather can take a significant toll on the different materials in drums — along with the drums’ sound quality',
2,
19,
now(),
now()
),
(
'Strictly Come Dancing eyeing up footballing legend and Coronation Street star',
'Strictly Come Dancing eyeing up footballing legend and Coronation Street star',
'Ex-England captain, Tony Adams, 55, could be swapping his old boots for dancing shoes when the primetime BBC show returns in the winter. According to bosses at the BBC, Adams will join the squad
of former soccer stars to have challenged for the Glitterball Trophy before. Previous footy aces include ex-goalkeeper David James, TV pundit Robbie Savage and Englands most capped footballer ever,
Peter Shilton.
Adams was nicknamed "Donkey" in his early playing days due to his inelegant style of defending.
However, he turned this image around when leading Arsenal to their successful spell in the 1990s.
Despite the 20th series not starting until later this year, excitement for the glamorous show is already building.
Strictly sources have shared what fans could expect from the ex-defenders first appearance.
Rumours are already circulating about who may join Kym and Tony in getting their sequins on this season.
So far documentary-maker Louis Theroux, Gogglebox star Scarlett Moffatt and soap star Adam Thomas have all been linked to the next edition of the glamorous show.',
2,
20,
now(),
now()
),
(
'Strictly Come Dancing announces four new pro dancers to complete 2022 cast',
'Strictly Come Dancing announces four new pro dancers to complete 2022 cast',
'Carlos Gu, Lauren Oakley, Michelle Tsiakkas, Vito Coppola join Strictly Come Dancing 2022. (BBC)
Strictly Come Dancing has announced four new professional dancers who will join the cast for the 2022 series.
The hit BBC One celebrity dance contest is due to return this autumn and after some high-profile dancer exits
earlier this year when Oti Mabuse and Aljaz Skorjanec announced they were quitting, the pro cast has been boosted by four new stars.
Read more: Whos taking part in Celebrity MasterChef 2022?
Viewers can look out for joining dancers European cup winner Vito Coppola, Chinese National Champion Carlos Gu, former Under 21 British
National Champion Lauren Oakley, and Latin dance champion Michelle Tsiakkas.
Lauren Oakley has previously danced with Giovanni Pernice and Anton Du Beke on their tours. (BBC)
They join the professional dancers already revealed for the upcoming series: Dianne Buswell, Nadiya Bychkova, Graziano Di Prima, Amy Dowden,
Karen Hauer, Katya Jones, Neil Jones, Nikita Kuzmin, Cameron Lombard, Gorka Marquez, Luba Mushtuk, Giovanni Pernice, Jowita Przystal, Johannes Radebe,
Kai Widdrington and Nancy Xu.',
2,
21,
now(),
now()
),
(
'Strictly Come Dancings Nicola Adams welcomes baby boy with partner Ella Baig',
'Strictly Come Dancings Nicola Adams welcomes baby boy with partner Ella Baig',
'Strictly Come Dancing star Nicola Adams has welcomed her first child with Ella Baig.
The boxer announced that their son was born on Saturday morning (July 9) in a statement, but has not yet revealed his name.
Nicola was bursting with pride for her partner Ella, as she revealed the happy news.
She said: "We are so excited to have welcomed our son into the world on Saturday morning at around 7am. Nothing prepares you for this moment in life but I am so overwhelmed with love and proud of Ella.
"We cant wait to start this new chapter with baby Adams."
Related: Everything you need to know about Strictly Come Dancing 2022
Back in February, Nicola announced that she and blogger Ella were expecting their first child together.
The Olympic champion and her partner shared a joint Instagram post to let their followers know the exciting update with a picture of their ultrasound scan of the baby.
"Were so excited to announce that our family is expanding," she wrote at the time. "After what feels like a lifetime, we can finally say were going to be parents! Were
 so excited to share this magical journey with you all, the ups, the downs everything in between."',
2,
22,
now(),
now()
),
(
'UK study reveals Omicron variant ‘substantially less likely’ to cause long Covid',
'UK study reveals Omicron variant ‘substantially less likely’ to cause long Covid',
'A new study by researchers at King’s College London on the risk of long COVID after infection found that the odds of experiencing long COVID were between 20-50% less during
the Omicron period versus the Delta period, depending on age and time since vaccination.
In the first peer-reviewed study to report on the risk of long COVID and the Omicron variant, published in a letter to The Lancet, researchers compared data on the Omicron variant
from reports for the ZOE Health Study with what they had already discovered on the Delta variant.
In the UK, 56,003  adult cases were identified in the ZOE Health Study app as first testing positive between 20 December 2021 and 9 March 2022, when Omicron was the dominant strain.
Researchers compared these cases to 41,381 cases of adults who first tested positive between 1 June 2021 and 27 November 2021, when the Delta variant was dominant.
The analysis shows that 4.4% of Omicron cases developed into long COVID, compared to 10.8% of Delta cases. However, the absolute number of people experiencing long COVID was higher 
in the Omicron period due to the vast numbers of people infected with Omicron from December 2021 to February 2022.',
2,
23,
now(),
now()
),
(
'Tsunami waves as high as 42 feet could crash into Seattle within minutes of an earthquake on Seattle Fault, study finds',
'Tsunami waves as high as 42 feet could crash into Seattle within minutes of an earthquake on Seattle Fault, study finds',
'A single earthquake in Seattle could cause a catastrophic situation for the northwest corner of the state, a new report from Washingtons Department of Natural Resources found.
The study was focused on the Seattle Fault, located beneath the Puget Sound and the city of Seattle. Researchers developed modeling scenarios based on the impacts of the last 
tsunami-triggering earthquake in the region, which occurred about 1,100 years ago. That earthquake on the fault is believed to have been between a 7.0 and 7.5 magnitude event and 
researchers said in their report that it may have been the only large earthquake on the fault within the past 16,000 years. 
However, they said, "the fault is still active and is capable of generating similar tsunamigenic earthquakes today."',
2,
24,
now(),
now()
),
(
'Non-white ICU patients get less oxygen treatment than needed -study',
'Non-white ICU patients get less oxygen treatment than needed -study',
'A medical worker (R) puts a pulse oximeter on a womans finger to check her oxygen level during a door-to-door survey for the coronavirus disease (COVID-19) amidst its spread in Ahmedabad, India June 26, 2020. REUTERS/Amit Dave/File Photo
July 11 (Reuters) - A flaw in a widely used medical device that measures oxygen levels causes critically ill Asians, Blacks and Hispanics to receive less supplemental oxygen to help them breathe than white patients, according to data from a 
large study published on Monday.
Pulse oximeters clip onto a fingertip and pass red and infrared light through the skin to gauge oxygen levels in the blood. It has been known since the 1970s that skin pigmentation can throw off readings, but the discrepancies were not believed 
to affect patient care.
Among 3,069 patients treated in a Boston intensive care unit (ICU) between 2008 and 2019, people of color were given significantly less supplemental oxygen than would be considered optimal compared to white people because of inaccuracies in pulse 
oximeter readings related to their skin pigment, the study found.',
2,
25,
now(),
now()
),
(
'Before our homes got smart: 7 vintage home gadgets that hark back to a bygone era',
'Before our homes got smart: 7 vintage home gadgets that hark back to a bygone era',
'Dutch designer Jaro Gielens basement is a sight to behold: The 1,000-square-foot space has been converted into a vault for one of the worlds largest collections of small household appliances from the 1960s to the 1990s -- featuring mostly items in mint-condition. 
A niche pursuit, you might be thinking, but together these items hold stories that reach far beyond the walls of his home.
"A unique fact is that all items are complete with the original packaging," he said in an email interview. "The pictures and graphics on the box best illustrate how these products were presented and marketed, and often tell from which period the product originated."
The collection now stands at 1,370 items, covering all product categories except vacuum cleaners and microwave ovens. The largest group represented is coffee makers, followed by hair dryers, mixers and dental devices. Some of the most iconic items are featured in the 
collectors new book, "Soft Electronics."
The gadgets speak to a very different time in product design that coincided with new consumer behaviors and necessities.',
2,
26,
now(),
now()
),
(
'Brains & BBQ: Smart Gadgets for Grilling',
'Brains & BBQ: Smart Gadgets for Grilling',
'Add some intelligence to your outdoor cooking this summer with these clever devices.
Summer means spending more time outdoors—and that includes cooking and dining. Smart technology, always a force in the traditional indoor kitchen, has extended its reach outdoors, adding connectivity and convenience to a variety of grilling devices, and making outdoor 
food prep faster, easier and safer.
Whether youre a seasoned pit master or an aspiring outdoor chef, youre sure to find something useful in these gadgets below.
Looking for a complete outdoor cooking setup? Look no further than the Traeger Timberline XL. Featuring an induction cooktop, 1,320 square inches of grill space and a max temperature of 500ºF, the Timberline XL ensures that you can create any culinary masterpiece you can imagine. But the Timberlines 
size and strength are matched by its smarts. Not only does the grill feature an easy-to-use touchscreen display, intuitive controls and a Super Smoke mode that ensures your food retains a wood-fired flavor, but it also includes Traegers WiFire technology, which allows users to control and monitor their 
grill from across the deck or across the estate. The Timberlines WiFire features can even be paired with Amazon Alexa or Google Home, granting the grill master voice control over the cooking process.',
2,
27,
now(),
now()
),
(
'Should You Buy Smart Home Gadgets on Prime Day?',
'Should You Buy Smart Home Gadgets on Prime Day?',
'This story is part of Amazon Prime Day, CNETs guide to everything you need to know and how to find the best deals.
Amazons annual Prime Day sale returns July 12-13, and some deals are already live in the run-up to the event. Not surprisingly,
that includes a smattering of deals on Echo speakers and other Amazon devices, a few of which are already marked down to all-time lows.
If youre an avid Alexa user interested in expanding the assistants footprint throughout your home, then youll obviously want to give those
deals a look, but other smart home manufacturers are likely to be in the mix, too. From smart lights to robot vacuums, its a safe bet that 
youll be able to find Prime Day discounts across a variety of categories, and competing retailers like Walmart, Best Buy and Target figure
to be in the mix with smart home sales of their own, too.',
2,
28,
now(),
now()
),
(
'Mom plans legal action after 7-year-old girl punished by school for BLM poster that said any life',
'Mom plans legal action after 7-year-old girl punished by school for BLM poster that said any life',
'A 7-year-old was punished by her school for including the phrase "any life" on a Black Lives Matter drawing she made, and her mother is now looking to take legal action.
Chelsea Boyle said her white daughter was confused about why she got in trouble for a picture depicting her diverse group of friends at Viejo Elementary School in Orange County, California. The picture included the Black Lives Matter slogan, with the phrase "any life" underneath, along with figures of different
colors to represent their various races.
"My children see color as a color, as a description. I am trying to raise them the way the world should be, not the way it is. That’s how I’m trying to make my personal change," Boyle said on the "Just Listen to Yourself" podcast, pointing out that her daughters best friend is a person of color but not Black "and 
she didn’t understand why she didn’t matter, why her friend didn’t matter."
"It wasn’t ‘all lives matter,’ it was ‘any life,’" Boyle continued. "It was something she came up on her own. She just didn’t understand it. It was completely innocent, and that broke my heart."',
2,
29,
now(),
now()
),
(
'Lee County School Board District 6 election: Three candidates are running',
'Lee County School Board District 6 election: Three candidates are running',
'Three candidates are vying for the Lee County School Board District 6 at-large seat this year.
In the running are Tia Collin, Denise Nystrom and Jada Langford-Fleming.\
Incumbent Betsy Vaughn is not running for reelection and could not be reached for comment about her reasons for staying out of the race.
The primary, which will take place Aug. 23, will see the top two vote-getters move on to the general election, if no candidate gets more than 50% of the vote.
District 6 is an at-large nonpartisan race, which means anyone in the county can vote for a District 6 candidate.
Other school board election coverage: 
Nystrom and Collins listed student achievement as a top priority for the district. Collins and Langford-Flaming said parental involvement is crucial.
Tia Collin is running for the Lee County School Board District 6 at-large.
A resident of Lee County for more 30 years, Collin said shes had a positive experience with Lee County Schools. All four of her children graduated from the district, and three received special education services.
Her late husband, Sgt. Ryan Willin, of the Lee County Sheriffs Office, also graduated from the district.
I know where we’ve come from, where we are and where we need to go,I’m a life skills instructor, teaching intellectually and developmentally disabled adults in our community, most of whom are Lee County Public Schools alums. I see great potential where others see none.',
2,
30,
now(),
now()
),
(
'Lee County School Board District 5 elections: Gittens facing challenge from Persons',
'Lee County School Board District 5 elections: Gittens facing challenge from Persons',
'Two candidates are vying for Lee County School Boards District 5 seat this year.
Voters in District 5, which includes Lehigh Acres and Alva in eastern Lee County, will choose between Gwynetta Gittens, the districts incumbent, and newcomer Armor Persons in the nonpartisan primary Aug. 23.
While both candidates have voiced differing concerns with the district, the one thing they seem to see eye-to-eye on is making sure parents and the community are involved in the decision-making process.
Other school board election coverage: 
Armor Persons
Armor Persons, candidate for Lee County School Board District 5 race.
Persons is a sixth-generation Lee County native. Hes heavily involved in the tennis community —as a director for 50 years and owner of Courtmaster Tennis Services for 30 years — and a member of the Lee County Chamber of Commerce.
He said he wants to give parents and taxpayers a louder voice in the district. With new laws addressing critical race theory and gender identity, book bans and masking, Persons said the board needs to make sure the superintendent enforces the state laws.
"The present board does little or no action on public input," Persons said. "They are consumed by infighting and lose focus of their elected objective of setting policy."',
2,
31,
now(),
now()
),
(
'Amazon Prime Day 2022: Amazon is giving away $125 in free money. Heres how to cash in',
'Amazon Prime Day 2022: Amazon is giving away $125 in free money. Heres how to cash in',
'Amazon Prime Day 2022 is here. On July 12 and 13, Amazon will slash prices on top-rated tech, kitchen gadgets, apparel and more for Amazon Prime members.
This years Amazon Prime Day may prove to be the best and most lucrative one yet. Thats because Amazon is offering $125 worth of free money to Prime members. Read on to see all the ways you can get free money at Amazon now.
Top products in this article:
Amazon free money deal No. 1: Reload $100 on a gift card, get a $10 credit
Amazon free money deal No. 2: Complete a Prime Stampcard, get a $10 credit
Amazon free money deal No. 3: Get up to $60 in Prime Day credits
There are a few easy ways to earn free money at Amazon right now. You can earn $10 when you reload a gift card with $100 or more. Youll get another $10 when you active and complete your 2022 Prime Stampcard by exploring the benefits of an Amazon Prime membership,
$20 for uploading a photo to Amazon Photos and $25 for adding a card to your Amazon Wallet.',
2,
32,
now(),
now()
),
(
'Money markets scale back ECB rate-hike bets amid recession fears',
'Money markets scale back ECB rate-hike bets amid recession fears',
'July 12 (Reuters) - Money markets on Tuesday scaled back bets on the degree of European Central Bank interest-rate hikes this year and for 2023 amid recession fears.
Market participants reckon that an economic slowdown due to surging energy prices and a potential drop in inflation would take some pressure off the central bank to raise rates.
They are currently pricing 137 basis points in total of ECB rate hikes in 2022, down from 145 bps on Monday, and 180 bps worth of tightening by the end of 2023 from around 195 bps the day before.',
2,
33,
now(),
now()
),
(
'Millennial Money: 4 money moves to make before baby arrives',
'Millennial Money: 4 money moves to make before baby arrives',
'The arrival of a new baby is all-consuming. In the early weeks, your waking hours are a cycle of feedings, diaper changes and Googling “Is it normal for a baby to (fill in the blank).”
Mustering the energy — and attention span — for otherwise routine tasks like showering and paying bills can feel like a tall order. You’ll be lucky to remember what day it is, much less when your next credit card payment is due.
Do your future, sleep-deprived self a favor and start prepping your finances early into your pregnancy so things can run on autopilot for a while after the baby arrives.
If you don’t already have a budget, start there, says Cecilia Williams, a mother, certified financial planner and the chief operating officer of Halbert Hargrove, a financial planning firm.
“Outline all your current income and expenses so you and your partner have a solid understanding of where your money goes each month,” Hargrove says. “This will absolutely need to be adjusted as you get closer to your due date, so having a starting point is priority No. 1.”
Then build a plan for managing the other costs, large and small, that come with having a baby.
RESEARCH THE COST TO DELIVER YOUR CHILD
The price tag for childbirth is steep. The average cost for delivery can range from $10,000 to $20,000, depending on where you live. Even with insurance, new parents can expect to pay several thousand dollars out of pocket for maternity care.
Contact your insurer or the hospital where you plan to deliver to get more specific numbers. Then take a deep dive into your health care coverage to understand your coinsurance, deductible, maximums and coverage limits.',
2,
34,
now(),
now()
),
(
'More are trading dream job for a dream life',
'More are trading dream job for a dream life',
'So reads the title of YouTuber Kathouts video that grabbed over half a million views and nearly 8,000 comments — most of which agree with the videos title:
In the video, Kathout, a self-described former "hustle-culture-obsessed college vlogger," argues for a life where she doesnt dream of labor.
We might think we dont "dream" of labor, but many of us have had a "dream job" — the dream being that were doing a job that aligns exactly with what we want to do. The "dream job" is the job that makes us feel like we have a purpose. Its what we believe were supposed to be doing, even if it means it consumes our lives.
A 2017 study found that four out of 10 adults believed they already had their dream job. Seventy percent thought having their dream job was possible.
Our dream jobs were so important to us because our lives revolved around work.
But in 2021, a newer study reported that 93% of Americans arent pursuing their dream career. Almost 60% are rethinking their career; one in three are considering leaving their jobs.
Why? The new way of working has turned what many believed were dream jobs into nightmares.
For many corporate workers, recent events brought a shift in the physical way they work. Gone were commutes, in-person meetings and eight-plus hour days in cubicles.
Remote work didnt just take away what office workers were used to; for many, it gave them much more. It gave them time with family. It gave them more sleep. It gave them the ability to be home for dinner; do their laundry in the middle of the day; take a walk around the neighborhood; work from a beach in Hawaii; to have more
flexibility and structure in their life. Work was no longer a barrier to living life as they desired.',
2,
35,
now(),
now()
),
(
'‘Dream job’: Benji ready to go ‘all in’ to fix Tigers as head coaching ambitions revealed',
'‘Dream job’: Benji ready to go ‘all in’ to fix Tigers as head coaching ambitions revealed',
'Benji Marshall has opened up on his NRL head coaching ambitions and his love for the Wests Tigers after reports the club are considering installing Tim Sheens as a mentor to him.
After the Tigers missed out on Cameron Ciraldo the club is now reportedly considering using Sheens as their head coach with Marshall to work under him and be groomed for the top job down the line.
“There is a lot being said about the coaching at the Tigers with Tim Sheens and possibly yourself (Benji Marshall),” Braith Anasta said on NRL 360.
Stream every game of every round of the 2022 NRL Telstra Premiership Season Live & Ad-Break Free During Play on Kayo. New to Kayo? Start your free trial now >
“Is there any chance we could see Benji Marshall as the head coach of the Wests Tigers one day?”
“Well not any time soon, but the dream for me would be to be an NRL coach and at the Wests Tigers would be an ideal situation,” Marshall said.
“Obviously it has been reported that Tim Sheens is going to get the job and mentor someone.
“If the opportunity was for me to be mentored under him with a pathway to become a head coach it is something I would definitely consider.
“I love my job that I do now, but that is an opportunity that I might never get again. The opportunity to try and become a head coach.',
2,
36,
now(),
now()
),
(
'Ann Ricker lands her dream job as the new editor of TALK Greenville',
'Ann Ricker lands her dream job as the new editor of TALK Greenville',
'Welcome to my first issue as editor of TALK. I couldn’t be more thrilled about writing to you!
I love magazines. I remember as a young girl, pouring over periodicals, tearing out pages, plastering them from ceiling to baseboard. Saving the volumes in stacks — for years (much to my Mother’s dismay). Reading them over and over ... and over. Now, I realize I always wanted to be an editor. This is my dream job.
While this is my first issue as editor, it is not my first issue with TALK. For just over eight years, I’ve been the magazine’s stylist and fashion contributor, curating, styling and writing the monthly fashion and Wear It Now features. I will continue in that role in addition to my new duties guiding the rest of the magazine.
Ann Ricker
This issue highlights women entrepreneurs and their journey to be successful business owners in their respective fields. These exceptional women have been guided by others and are now able to provide mentorship and leadership themselves.
My own career has been a winding road, from designing in New York to being a stay-at-home mom and then a public-school art educator, and now to this new role as editor. Navigating it would not have been possible without the gift of mentorship.
In December of 2014, Kim Hassold approached me about styling Talk’s fashion features. I was nervous and unsure as it was my first time working for a magazine. But Kim had faith in me and guided me, and over time my confidence -- and duties -- grew. I will be forever grateful for her trust and leadership.',
3,
37,
now(),
now()
),
(
'Americans may get the one presidential race the country doesnt want in 2024',
'Americans may get the one presidential race the country doesnt want in 2024',
'This small consolation for the White House cannot disguise growing signs that Bidens presidency is in deep trouble even before midterm elections in November, which threaten a devastating rebuke to his Democratic Party in the House. The New York Times/Siena College nationwide survey published on Monday coincides with a flurry of 
unflattering stories about Bidens age and political proficiency and growing speculation about his prospects for reelection. The question of whether any Democrats would dare challenge him in a primary is an increasingly hot topic despite dismissals by leading alternative potential candidates.
And yet, Biden, saddled with an approval rating of just 33% in the survey, is still in the game against Trump. The survey showed no clear leader, with Biden earning 44% to Trumps 41% among registered voters, within the polls margin of sampling error. A poll is just a snapshot in time, but its hardly encouraging news for the ex-President
and suggests he has huge liabilities in the general electorate, despite expectations among his conservative media boosters that he would cruise to revenge over an elderly Biden in 2024.
But the closeness also points to a more profound theme that is emerging as the US barrels toward 2024 and has implications beyond the identity of the person who sits in the Oval Office in 2025. A country mired in multiple crises, politically estranged within and facing risky international flashpoints may get a 2024 contest between two 
candidates whose answers havent worked over the previous eight years and whom millions of people would like to see retire from the stage to make room for younger, fresher faces.',
3,
38,
now(),
now()
),
(
'Why the press gets so much wrong about politics and our country and just doesnt care',
'Why the press gets so much wrong about politics and our country and just doesnt care',
'PROGRAMMING ALERT: Watch Ari Fleischer discuss this topic and more on July 12 on "The Ingraham Angle" at 10 pm ET on Fox News Channel
In June 2021, the Reuters Institute for the Study of Journalism asked people in 46 countries how much they trust their nation’s media. The results were devastating for American journalism – the United States came in last place.
American media are the least trusted in the world.  Only 29 percent of the American people trust the media, the survey found, the very bottom of the international barrel. (Finland is in first place, with 65 percent saying they trust their media. Canadian media, for comparison’s sake, enjoy a 45 percent level of trust.) 
Most reporters when they hear this will think, "There’s something wrong with the American people." Most Americans will think "There’s something wrong with the media."
This was one of my many findings in my just-released book, "Suppression, Deception, Snobbery and Bias  Why the Press Gets So Much Wrong – And Just Doesn’t Care" (Broadside Books, July 12, 2022).
ARI FLEISCHER WRITES NEW BOOK ON WHY THE LIBERAL MEDIA KEEPS GETTING THE NEWS WRONG
America’s mainstream media is in decline and denial, and neither is good for our country. It’s important for our democracy that people can trust what they read and see on the news. But after four years of watching much of the press corps do everything in its power to reverse the results of the 2016 election, I had enough. I watched the press suppress news they didn’t like and deceive people by airing false stories. 
Newsrooms overwhelmingly consist of like-minded, cut-from-the-same-cloth, tweet-the-same-thing people who have alienated most gun owners, people who go to church regularly, live in rural areas or think life begins at conception.',
3,
39,
now(),
now()
),
(
'Sri Lanka’s Gotabaya Rajapaksa fails in effort to flee country',
'Sri Lanka’s Gotabaya Rajapaksa fails in effort to flee country',
'The Sri Lankan president, Gotabaya Rajapaksa, has made a failed attempt to flee the country after airport staff stood in his way and forced him to beat a humiliating retreat.
Rajapaksa, who is due to officially resign on Wednesday after months of demonstrations calling for him to step down, was reportedly trying to escape to Dubai on Monday night.
However, officials said immigration staff refused to let the president come to the VIP area of the airport to stamp his passport and he would not go through the ordinary queues for fear of being mobbed by the public.
As a result, Rajapaksa reportedly missed four flights to the United Arab Emirates, and he and his wife had to return to a nearby military base.
According to officials who spoke to Agence France-Presse, the president is now considering using a navy patrol craft to flee the island, though this could not be confirmed.
While he is still president, Rajapaksa enjoys immunity from arrest and he is believed to want to go abroad before stepping down to avoid the possibility of being detained. He stands accused of overseeing corruption and economic mismanagement, which bankrupted the country and triggered the worst financial crisis on record.
He has also been accused of war crimes, including enforced disappearances and extrajudicial killings, during his time as defence minister, when he brought the civil war, fought against the Tamil minority, to a bloody end in 2009. For more than a decade, the allegations against him have been prevented from reaching the courts.',
3,
40,
now(),
now()
);
```