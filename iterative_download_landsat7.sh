#!/bin/bash

# Configuration
CONFIG_FILE="/bess26/didxorkd/geefetch/configs/example_1/landsat7.yaml"
LOG_FILE="log_landsat7.py"
DATA_DIR="/esail3/satellite/"
SATELLITE="landsat7"
# Download the data
geefetch --logfile $LOG_FILE download $SATELLITE -c $CONFIG_FILE

# Extract start and end dates from the config file
START_DATE=$(grep 'start_date' $CONFIG_FILE | awk '{print $2}' | tr -d '"')
END_DATE=$(grep 'end_date' $CONFIG_FILE | awk '{print $2}' | tr -d '"')
START_YEAR=$(echo $START_DATE | cut -d'-' -f1)
END_YEAR=$(echo $END_DATE | cut -d'-' -f1)


# Rename the downloaded folder to include the year
DOWNLOAD_DIR="${DATA_DIR}${SATELLITE}"
NEW_DOWNLOAD_DIR="${DATA_DIR}${SATELLITE}_${START_YEAR}"
mv $DOWNLOAD_DIR $NEW_DOWNLOAD_DIR

# Modify the configuration file for the next run (example to change to next year)
NEXT_START_YEAR=$((START_YEAR - 1))
NEXT_END_YEAR=$((END_YEAR - 1))
sed -i "s/start_date: \"$START_DATE\"/start_date: \"$NEXT_START_YEAR-01-01\"/" $CONFIG_FILE
sed -i "s/end_date: \"$END_DATE\"/end_date: \"$NEXT_END_YEAR-12-31\"/" $CONFIG_FILE

# Print new dates for verification
echo "Updated start_date: $NEXT_START_YEAR-01-01"
echo "Updated end_date: $NEXT_END_YEAR-12-31"

# Run the loop
while [ $NEXT_START_YEAR -ge 2000 ]; do
    # Download the data
    geefetch --logfile $LOG_FILE download $SATELLITE -c $CONFIG_FILE

    # Rename the downloaded folder to include the year
    DOWNLOAD_DIR="${DATA_DIR}${SATELLITE}"
    NEW_DOWNLOAD_DIR="${DATA_DIR}${SATELLITE}_${NEXT_START_YEAR}"
    mv $DOWNLOAD_DIR $NEW_DOWNLOAD_DIR

    # Modify the configuration file for the next run
    START_DATE=$(grep 'start_date' $CONFIG_FILE | awk '{print $2}' | tr -d '"')
    END_DATE=$(grep 'end_date' $CONFIG_FILE | awk '{print $2}' | tr -d '"')
    NEXT_START_YEAR=$((NEXT_START_YEAR - 1))
    NEXT_END_YEAR=$((NEXT_END_YEAR - 1))
    sed -i "s/start_date: \"$START_DATE\"/start_date: \"$NEXT_START_YEAR-01-01\"/" $CONFIG_FILE
    sed -i "s/end_date: \"$END_DATE\"/end_date: \"$NEXT_END_YEAR-12-31\"/" $CONFIG_FILE

    # Update START_DATE and END_DATE for the next iteration
    START_DATE="${NEXT_START_YEAR}-01-01"
    END_DATE="${NEXT_END_YEAR}-12-31"

    # Print new dates for verification
    echo "Updated start_date: $NEXT_START_YEAR-01-01"
    echo "Updated end_date: $NEXT_END_YEAR-12-31"
done
