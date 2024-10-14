q#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams;")"
# Script to populate tables table
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [[ "$winner" != "winner" && "$opponent" != "opponent" ]]
  then
    # Check if winner exists in the teams table
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $winner_id ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      # Get the ID of the newly inserted winner
      winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    fi

    # Check if opponent exists in the teams table
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $opponent_id ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      # Get the ID of the newly inserted opponent
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    fi
  fi
done

# Script to populate games table

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [[ "$winner" != "winner" && "$opponent" != "opponent" ]]
  then
  # Find winner_id and opponent_id in teams table based on team_id
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")
  # Check if the game_id is populated in games table based on the match
  game_id=$($PSQL "SELECT game_id FROM games WHERE winner_id=$winner_id AND opponent_id=$opponent_id")
    # If no match is found add a new record with all the info
    if [[ -z $game_id ]]
    then
      echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
      # Get a new game_id
      game_id=$($PSQL "SELECT game_id FROM games WHERE winner_id=$winner_id AND opponent_id=$opponent_id")
    fi
  fi
done