/*
By Jackie Nguyen
github: https://github.com/aznone5
linkedin: https://www.linkedin.com/in/jackie-dan-nguyen/
Kaggle DataSet: https://www.kaggle.com/datasets/braydenrogowski/league-of-legends-worlds-2021-playin-group-stats

TASK
I came here to aggergate the dataset to depict trends based on champion picked, players preferences, players performances, ether on certain champions or in general,
teams priority on objectives, team performance, Role Power, etc.
*/


/*
Under the Youtube database, we will be creating our table
*/

use youtube;

drop table if exists lol_2021_stats;
CREATE TABLE lol_2021_stats (
team varchar(24), 
player varchar(255),
opponent_team varchar(24),
position varchar(24),
champion varchar(255),
kills int,
deaths int,
assists int,
creep_score int,
gold_earned int,
champion_damage_share float,
kill_participation float,
wards_placed int,
wards_destroyed int,
wards_interacted int,
dragons_slayed int,
dragons_losted int,
barons_slayed int,
barons_losted int,
results varchar(9)
);

/*
team varchar(24),  Abbreviation of the team playing,  BYG = Beyond Gaming (Taiwan), C9 = Cloud 9 (North America), HLE = Hanwha Life esports (Korea), UOL = Unicorns of Love (Russia), 
GS = Galatasaray esports (Turkey), DFM = Detonation Focus Me (Japan), INF = Infinity esports (Latin America), PCE = Peace (Oceania), LNG = Li-Ning (China), RED Canids (Brazil)
player varchar(255),  Ign(in-game username) of the player BYG Beyond Gaming has a Top Subsitute named 'PK'
opponent_team varchar(24), The opponent of the team corresponding to the row on column team
position varchar(24), What role they play(adc = attack damage carry), top, jungle, mid, adc, support
champion varchar(255), Champion they decided to pick in the draft phase, or champion the player is playing
kills int, How many kills did that player get on that champion in that game
deaths int, How many deaths did that player get on that champion in that game
assists int, How many assists did that player get on that champion in that game
creep_score int, How many minons or monsters did that player slay in that game
gold_earned int, How much gold a person accumulated
champion_damage_share float, Percentage of damage  that person did incomparison to the rest of his/her team
kill_participation float, Percentage of kills and assist a player recive in comparison to the total teams killscore
wards_placed int, How many wards did you place down
wards_destroyed int, How many wards did you destroy
wards_interacted int, wards_placed + wards_destroyed
dragons_slayed int, How many dragons did your team slay 
dragons_losted int, How many dragons did the enemy team slay
barons_slayed int, How many barons did your team slay
barons_losted int, How many barons did your team slay
results varchar(9) Did that team win or lose
*/
/*
Let's take a look at our table
*/


select *
from lol_2021_stats;


/*
Analysing the win loss ratio of each team
*/


select a.team, a.wins, a.losses, round(a.wins / (a.wins + a.losses), 2) as win_loss_ratio
from
(select team, round(sum(case when results = 'W' then 1 else 0 end) / 5, 0) as wins, round(sum(case when results = 'L' then 1 else 0 end) / 5, 0) as losses
from lol_2021_stats
group by team) as a
order by win_loss_ratio desc;


/*
Alot of mispelling of errors on the 'player' column, therefore
we need to update the table to get the corret players before making
our table
*/


SET SQL_SAFE_UPDATES = 0

UPDATE lol_2021_stats
SET player = 'Vulcan'
WHERE player = 'Bulcan';
UPDATE lol_2021_stats
SET player = 'Zergsting'
WHERE player = 'Zersting';
UPDATE lol_2021_stats
SET player = 'Vsta'
WHERE player = 'Leona';


/*
Now that we are here, we can find the individual performance of each player, what role they play, and what team they play for.
to summarize, each team has 5 players, and 5 positions, kinda like basketball.
** Note some teams like BYG Beyond Gamming have subsitutes.
*/


select team, player, position, sum(kills) as total_kills, sum(deaths) as total_deaths, sum(assists) as total_assist,
round((sum(kills) + sum(assists)) / sum(deaths), 2) as kda_ratio, round(avg(creep_score), 0) as avg_creep_score,
round(avg(gold_earned), 0) as avg_gold_earned, round(avg(champion_damage_share), 2) as avg_damage_share
from lol_2021_stats
group by team, player, position
order by team, position;


/*
This graph more focuses on wards, and kill participation, more teamwork relataed stats
*/


select team, player, position, round(avg(kill_participation), 2) as avg_kill_participation, round(avg(wards_placed), 2) as avg_wards_place,
round(avg(wards_destroyed), 2) as avg_wards_destroyed, round(avg(wards_interacted), 2) as avg_wards_interaction
from lol_2021_stats
group by team, player, position
order by team, position;


/*
We're here to analyze the objective control of each team, 
a major outcome of who decided to win or not
*/


select a.team, a.total_dragon_kills, a.total_dragons_gived, round(a.total_dragon_kills / (a.total_dragon_kills + a.total_dragons_gived), 2) as dragon_kill_ratio,
a.total_baron_kills, a.total_barons_gived, round(a.total_baron_kills / (a.total_baron_kills + a.total_barons_gived), 2) as baron_kill_ratio
from
(select team, round(sum(dragons_slayed) / 5, 0) as total_dragon_kills, round(sum(dragons_losted) / 5, 0) as total_dragons_gived, 
round(sum(barons_slayed) / 5, 0) as total_baron_kills, round(sum(barons_losted) / 5, 0) as total_barons_gived
from lol_2021_stats
group by team) as a;


/*
Lets see that stats of how good certain roles are
*/

select a.position, a.total_kills, a.total_deaths, a.total_assists, round((total_kills + total_assists) / total_deaths, 2) as kda_ratio, a.avg_creep_score, a.avg_gold_earned, 
a.avg_champion_damage_share, a.avg_kill_participation, a.avg_wards_placed, a.avg_wards_destroyed, a.avg_wards_interacted
from
(select position, sum(kills) as total_kills, sum(deaths) as total_deaths, sum(assists) as total_assists, round(avg(creep_score), 0) as avg_creep_score, round(avg(gold_earned), 0) as avg_gold_earned, 
round(avg(champion_damage_share), 2) as avg_champion_damage_share, round(avg(kill_participation), 2) as avg_kill_participation, round(avg(wards_placed), 1) as avg_wards_placed,
round(avg(wards_destroyed), 1) as avg_wards_destroyed, round(avg(wards_interacted), 1) as avg_wards_interacted
from lol_2021_stats
group by position) as a
order by kda_ratio desc;


/*
Let's focus more on champion performance, specifically on how often they are played, 
win/loss ratio, and who is picking these champions
*/


select a.champion, a.position, round(a.win / (a.lost + a.win), 2) as win_loss_percentage, a.win + a.lost as total_games_played, a.total_kills, a.total_deaths,
a.total_assists, (case when a.kda_ratio is null then round(a.total_kills + a.total_assists / 1, 2) else a.kda_ratio end) as kda_ratio, a.avg_creep_score, a.avg_gold_earn, a.avg_kill_participation
from(
select champion, position, sum(case when results = 'W' then 1 else 0 end) as win, sum(case when results = 'L' then 1 else 0 end) as lost,
sum(kills) as total_kills, sum(deaths) as total_deaths, sum(assists) as total_assists, round((sum(kills) + sum(assists)) / sum(deaths), 2) as kda_ratio, 
round(avg(creep_score), 0) as avg_creep_score, round(avg(gold_earned), 0) as avg_gold_earn, round(avg(kill_participation), 2) as avg_kill_participation
from lol_2021_stats
group by champion, position
order by position) as a
order by a.position, total_games_played desc;


/*
For this graph, we are going to see what teams priortize in draft
and look into the performance of players vs average performance throughout
play-in stages
*/


select a.team, a.player,  a.position, a.champion, a.number_of_wins, a.number_of_losses, round(a.number_of_wins / (a.number_of_losses + a.number_of_wins), 2) as player_win_loss_ratio, 
b.avg_champion_winrate, (case when a.kda_ratio is null then round((a.total_kills + a.total_assists) / 1, 2) else a.kda_ratio end) as player_kda_ratio, b.avg_kda_ratio
from (
select team, player,  position, champion, sum(case when results = 'W' then 1 else 0 end) as number_of_wins, sum(kills) as total_kills, sum(assists) as total_assists,
sum(case when results = 'L' then 1 else 0 end) as number_of_losses, round((sum(kills) + sum(assists)) / sum(deaths), 2) as kda_ratio
from lol_2021_stats
group by team, player, position, champion
order by position) as a
left join
    (select 
        champion, 
        ROUND((case when sum(deaths) = 0 then sum(kills) + sum(assists) / 1  else (sum(kills) + sum(assists)) / sum(deaths) end), 2) as avg_kda_ratio,
        round(sum(case when results = 'W' then 1 else 0 end) / (sum(case when results = 'L' then 1 else 0 end) + sum(case when results = 'W' then 1 else 0 end) ), 2) as avg_champion_winrate
     from lol_2021_stats
     group by champion) b
on A.champion = B.champion;
