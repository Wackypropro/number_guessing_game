#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Secret number generator (1 - 1000)
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Fetch user details from database
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # New user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=""
else
  # Existing user
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true
do
  read GUESS

  # Check if input is a valid integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update database record upon winning
NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $BEST_GAME ]] || [[ $GUESS_COUNT -lt $BEST_GAME ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
else
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED WHERE username = '$USERNAME'")
fi



