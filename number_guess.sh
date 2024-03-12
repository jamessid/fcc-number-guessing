#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=1

# testing only: output random number
echo "Secret number is: $SECRET_NUMBER"

# username input
echo "Enter your username:"
read USERNAME

# check that username is less than 22 chars
while [[ ${#USERNAME} -gt 22 ]]
do
  echo "Usernames must be 22 characters or less. Please try again."
  read USERNAME
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  USER_GAME_COUNT=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  USER_BEST_SCORE=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME! You have played $USER_GAME_COUNT games, and your best game took $USER_BEST_SCORE guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read CURRENT_GUESS

READ_GUESS() {
  echo $1
  read CURRENT_GUESS
}

while [[ $CURRENT_GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $CURRENT_GUESS =~ ^[0-9]*$ ]]
  then
    READ_GUESS "That is not an integer, guess again:"
  elif [[ $CURRENT_GUESS -gt $SECRET_NUMBER ]]
  then
    READ_GUESS "It's lower than that, guess again:"
  else
    READ_GUESS "It's higher than that, guess again:"
  fi
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

# insert game data
INSERT_GAME_DATA=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES);")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
