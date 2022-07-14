create table statistic( 
player_name VARCHAR(100) not null,
player_id INT not null,
year_game smallint not null check (year_game > 0),
points DECIMAL(12, 2) check (points >= 0),
primary key (player_name, year_game));

INSERT INTO statistic(player_name, player_id, year_game, points) 
VALUES ('Mike',1,2018,18), 
('Jack',2,2018,14), 
('Jackie',3,2018,30), 
('Jet',4,2018,30), 
('Luke',5,2019,16), 
('Mike',1,2019,14), 
('Jack',2,2019,15), 
('Jackie',3,2019,28), 
('Jet',4,2019,25), 
('Luke',5,2020,19), 
('Mike',1,2020,17), 
('Jack',2,2020,18), 
('Jackie',3,2020,29), 
('Jet',4,2020,27);

select 
  year_game,
  sum(points) as points
from statistic
group by year_game
order by year_game desc;

select 
  year_game, 
  sum(points) as points
from statistic
group by grouping sets (year_game)
order by year_game desc;

select 
  coalesce(year_game::text, 'Итого:') as year_game,
  sum(points) as points
from statistic
group by rollup(year_game) 
order by year_game;

with points_statistic as (
select 
  coalesce(year_game::text, 'Итого:') as year_game,
  sum(points) as points
  from statistic
  group by rollup(year_game)
  order by year_game
) 
select 
  year_game,
  points 
from points_statistic;


with cte as (
  select
    player_id,
    player_name,
    year_game,
    sum(points) as sum_points
  from statistic
  group by 
    player_id, 
    player_name,
    year_game
), cte2 as (
  select
    player_id,
    player_name,
    year_game,
    sum_points as current_year_points,
    lag(sum_points, 1) over (partition by player_id order by year_game) as previous_year_points
  from cte
)
select 
  player_id,
  player_name,
  year_game,
  current_year_points,
  previous_year_points
from cte2
where year_game = '2020';