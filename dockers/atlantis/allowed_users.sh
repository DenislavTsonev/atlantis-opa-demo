#!/bin/bash

if [[ ! $ALLOWED_USERS =~ $USER_NAME ]]
then
    echo "#################################################################"
    echo "# User ( ${USER_NAME} ) is NOT allowed to run terraform apply"
    echo "# Allowed users are ${ALLOWED_USERS}"
    echo "#################################################################"

    exit 1
fi