#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU()
{
  
  if [[ $1 ]];
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?"
  fi
  
  #get services
  SERVICES=$($PSQL "select * from services;")
  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" 
  done
  read SERVICE_ID_SELECTED

  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]];
  then
    #send back to main menu
    MAIN_MENU "This is not a valid bike number."
  else
    #get services availability
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    #if not available
    if [[ -z $SERVICE_AVAILABILITY ]];
    then
      #sen back to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #get customer's phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone='$CUSTOMER_PHONE'")
      
      #if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]];
      then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      
      fi
    
      #if customer exist
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")
      
      
      
      #Get service time
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      
      INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."


    fi

  fi

  

}

MAIN_MENU