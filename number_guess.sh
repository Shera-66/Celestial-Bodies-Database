#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME
CHECK_USER=$($PSQL "SELECT * FROM usernames WHERE username='$NAME';")
if [[ -z $CHECK_USER ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "INSERT INTO usernames(username, games_played) VALUES('$NAME', 1);")
else
  echo $CHECK_USER | while IFS=" |" read USER_ID USERNAME GAMES_PLAYED BEST_GAME_SCORE;
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_SCORE guesses."
    ((GAMES_PLAYED++))
    INCREMENT_GAMES=$($PSQL "UPDATE usernames SET games_played = '$GAMES_PLAYED' WHERE username = '$NAME';")
  done
fi
RANDOM_NUMBER=$((1 + RANDOM % 1000))

echo "Guess the secret number between 1 and 1000:"
read GUESS

TRIES=1

while ! [[ $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done

while ! [[ $RANDOM_NUMBER -eq $GUESS ]]
do
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    ((TRIES++))
    read GUESS
  else [[ $GUESS -lt $RANDOM_NUMBER ]]
    echo "It's higher than that, guess again:"
    ((TRIES++))
    read GUESS
  fi
done
GAMES_PLAYED=$($PSQL "SELECT games_played FROM usernames WHERE username = '$NAME';")
BEST_SCORE=$($PSQL "SELECT best_game_score FROM usernames WHERE username = '$NAME';")

if [[ $GAMES_PLAYED -eq 1 ]]
then
  UPDATE_SCORE=$($PSQL "UPDATE usernames SET best_game_score = '$TRIES' WHERE username = '$NAME';")
fi

if [[ $TRIES -lt $BEST_SCORE ]]
then
  UPDATE_NEW_SCORE=$($PSQL "UPDATE usernames SET best_game_score = '$TRIES' WHERE username = '$NAME';")
fi
echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
