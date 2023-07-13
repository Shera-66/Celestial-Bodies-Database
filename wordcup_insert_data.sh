#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY;")
# Insert data into teams table

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$($PSQL "SELECT team_id from teams WHERE name='$WINNER' ")
  OPPONENT_ID=$($PSQL "SELECT team_id from teams WHERE name='$OPPONENT' ")
if [[ $WINNER != 'winner' && $OPPONENT != 'opponent' ]]
then
  if [[ -z $WINNER_ID ]]
  then
   INSERT_W=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
   if [[ $INSERT_W == "INSERT 0 1" ]]
   then
    echo Inserted $WINNER
   fi
  elif [[ -z $OPPONENT_ID ]]
  then
    INSERT_O=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_O == "INSERT 0 1" ]]
   then
    echo Inserted $OPPONENT
   fi
  fi
fi
done

# Insert data into games table

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# get team ids
  WINNER_ID=$($PSQL "SELECT team_id from teams WHERE name='$WINNER' ")
  OPPONENT_ID=$($PSQL "SELECT team_id from teams WHERE name='$OPPONENT' ")

  if [[ $YEAR != "year" && $WINNER != 'winner' && $OPPONENT != 'opponent' ]]
  then 
    # get infos
    G_WINNER=$($PSQL "SELECT winner_id FROM games WHERE (winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID )")
    G_OPPONENT=$($PSQL "SELECT opponent_id FROM games WHERE (winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID )")
    
    # if not found
    if [[ -z $G_WINNER && -z $G_OPPONENT ]] 
    then 
      # insert infos
   echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    fi
   fi
    
done
