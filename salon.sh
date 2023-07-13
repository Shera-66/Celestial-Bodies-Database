#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICES=$($PSQL 'SELECT * FROM services;');
echo -e "Welcome to My Salon, how can I help you?"
SERVICES() {
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
}
SERVICES
read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
if [[ !($($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")) ]]
then
  SERVICES "I could not find that service. What would you like today?"
else
echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE
  if [[ !($($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")) ]]
  then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
