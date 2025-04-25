#Lana Musaffer || 1210455
#Mayar Masalmeh || 1211246

menu() {
  echo "WELCOME TO OUR MEDICAL SYSTEM! Please select an option:"
  echo "1. Add a new medical test record."
  echo "2. Search for a test by patient ID."
  echo "3. Searching for up normal tests."
  echo "4. Average test value."
  echo "5. Update an existing test result"
  echo "6. Delete a test."
  echo "7. Exit."
}

VALID_TESTS="Hgb BGT LDL systole diastole RBC"  #In order to check if the user enters an invalid test name

add_medicalTest() {
####################################[ENTER ID]############################################
    echo "Enter a 7-digit Patient ID:"
    read patient_id

    #Handle cases where the user enters an invalid ID
    while ! echo "$patient_id" | grep -Eq '^[0-9]{7}$'
    do
        echo "Invalid Patient ID! Please enter a 7-digit Patient ID:"
        read patient_id
    done
##################################[ENTER TEST NAME]#################################################
    echo "Enter test name:"
    read test_name

    #Convert test name to lowercase for comparison
    test_name_lower=$(echo "$test_name" | tr '[A-Z]' '[a-z]')

    # Validate Test Name
    valid=0
    for valid_test in $VALID_TESTS
    do
        #Convert each valid test name to lowercase
        valid_test_lower=$(echo "$valid_test" | tr '[A-Z]' '[a-z]')
        if [ "$test_name_lower" = "$valid_test_lower" ]
        then
            valid=1
            break
        fi
    done

    while [ $valid -eq 0 ]
    do
        echo "Invalid test name! Please enter a valid test name:"
        echo "Valid test names are: $VALID_TESTS"
        read test_name

        # Convert test name to lowercase for comparison
        test_name_lower=$(echo "$test_name" | tr '[A-Z]' '[a-z]')

        valid=0
        for valid_test in $VALID_TESTS
        do
            # Convert each valid test name to lowercase
            valid_test_lower=$(echo "$valid_test" | tr '[A-Z]' '[a-z]')
            if [ "$test_name_lower" = "$valid_test_lower" ]
            then
                valid=1
                break
            fi
        done
    done
#################################[ADD DATE]##################################################
    echo "Enter date of the test [USING THIS FORMAT: YYYY-MM]:"
    read test_date

    # Validate Test Date
    while ! echo "$test_date" | grep -Eq '^[0-9]{4}-[0-9]{2}$'
    do
        echo "Invalid date format! Please enter the date in YYYY-MM format:"
        read test_date
    done

    year=$(echo "$test_date" | cut -d'-' -f1)
    month=$(echo "$test_date" | cut -d'-' -f2)

    # Validate Year and Month
    while ! echo "$year" | grep -Eq '^[0-9]{4}$' || [ "$year" -lt 1900 ] || ! echo "$month" | grep -Eq '^[0-9]{2}$' || [ "$month" -lt 1 ] || [ "$month" -gt 12 ]
    do
        echo "Invalid year or month! Please enter a valid date in YYYY-MM format:"
        read test_date
        year=$(echo "$test_date" | cut -d'-' -f1)
        month=$(echo "$test_date" | cut -d'-' -f2)
    done
#######################################[ENTER RESULT]####################################################
    echo "Enter result value:"
    read result

    #validate result
    while [ -z "$result" ] || ! echo "$result" | grep -Eq '^[0-9]+([.][0-9]+)?$'
    do
        echo "Result cannot be empty and must be a numeric value! Please enter a result:"
        read result
    done

    result="$result, mg/dl"      #for appending unit to result
#####################################[ENTER STATUS]##########################################
    echo "Enter status (Pending, Completed, or Reviewed):"
    read status

    # Validate Status
    while ! echo "$status" | grep -Eq -i '^(Pending|Completed|Reviewed)$'
    do
        echo "Invalid status! Please enter one of the following: Pending, Completed, Reviewed:"
        read status
    done

    echo "$patient_id: $test_name, $test_date, $result, $status" >> medicalRecord.txt      # Add the record to the file

    if [ $? -eq 0 ]; then
        echo "Record added successfully."
    else
        echo "Failed to add the record."
    fi
}

##########################################option 2.2##########################################
abnormalTestsID() {
    patient_id=$1

    # Check if medicalTest.txt exists
    if [ ! -f medicalTest.txt ]
    then
        echo "'medicalTest.txt' not found!"
        return 1
    fi

    # Read test definitions into an array
    declare -A test_ranges
    while IFS=';' read -r test_name range unit || [ -n "$test_name" ]
    do
        # Trim spaces and convert to lowercase
        test_name_clean=$(echo "$test_name" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        unit_clean=$(echo "$unit" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        test_ranges["$test_name_clean"]="$range;$unit_clean"
    done < medicalTest.txt

    # Check if medicalRecord.txt exists
    if [ ! -f medicalRecord.txt ]
    then
        echo "'medicalRecord.txt' not found!"
        return 1
    fi

    found_abnormal=false      # Flag to check if any abnormal result is found

    # Read each test result from medicalRecord.txt
    while IFS= read -r line
    do
        # Extract the patient ID and the rest of the line
        current_pid=$(echo "$line" | cut -d':' -f1 | sed 's/^ *//;s/ *$//')

        # Skip lines not matching the patient ID
        if [ "$current_pid" != "$patient_id" ]; then
            continue
        fi

        rest_of_line=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')

        # Split rest_of_line by commas
        IFS=',' read -r test_name_field date_field result_field unit_field status_field <<EOF
$(echo "$rest_of_line")
EOF

        # Trim spaces and standardize data
        test_name=$(echo "$test_name_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        result=$(echo "$result_field" | sed 's/^ *//;s/ *$//')
        unit=$(echo "$unit_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        status=$(echo "$status_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')

        # Ensure test_name is not empty
        if [ -z "$test_name" ]
        then
            continue
        fi

        # Fetch the expected range and unit for the test from the associative array
        range_info="${test_ranges[$test_name]}"
        if [ -z "$range_info" ]
        then
            continue
        fi

        range=$(echo "$range_info" | cut -d';' -f1)
        expected_unit=$(echo "$range_info" | cut -d';' -f2)

        # Ensure unit matches
        if [ "$unit" != "$expected_unit" ]
        then
            continue
        fi

        # Initialize min and max values
        min_value=""
        max_value=""

        # Parse the range (e.g., ">4.5,<6.0" or "<100")
        IFS=',' read -ra range_parts <<< "$range"

        for part in "${range_parts[@]}"
        do
            part_clean=$(echo "$part" | sed 's/^ *//;s/ *$//')
            if echo "$part_clean" | grep -q '^>'
            then
                min_value=${part_clean#*>}
            elif echo "$part_clean" | grep -q '^<'
            then
                max_value=${part_clean#*<}
            fi
        done

        # Validate that result is a valid number
        if ! echo "$result" | grep -Eq '^[0-9]+([.][0-9]+)?$'
        then
            continue
        fi

        abnormal=false          # Perform comparisons

        if [ -n "$min_value" ] && [ "$(echo "$result <= $min_value" | bc)" -eq 1 ]
        then
            abnormal=true
        fi

        if [ -n "$max_value" ] && [ "$(echo "$result >= $max_value" | bc)" -eq 1 ]
        then
            abnormal=true
        fi

        # Output the result
        if [ "$abnormal" = true ]
        then
            echo "Abnormal result found for $current_pid: $test_name, $date_field, $result, $unit, $status"
            found_abnormal=true
        fi
    done < medicalRecord.txt

    # Print message if no abnormal tests were found
    if [ "$found_abnormal" = false ]
    then
        echo "No abnormal tests for patient ID $patient_id."
    fi
}

#function to validate date format
validate_date() {
    local date="$1"
    if [[ "$date" =~ ^[0-9]{4}-(0[1-9]|1[0-2])$ ]]
    then
        return 0
    else
        return 1
    fi
}

############################################option 2###############################
SearchTest_byPatientID() {
  while true
  do
    echo "Enter patient ID:"
    read patient_id

    # Check if medicalRecord.txt exists
    if [ ! -f medicalRecord.txt ]
    then
      echo "'medicalRecord.txt' not found!"
      return 1
    fi

    # Check if there are any records for the given patient ID
    if ! grep -q "^$patient_id:" medicalRecord.txt
    then
      echo "There is no patient with this ID: $patient_id. Please try again:"
      continue
    fi

    # Show menu options
    echo "Pick what you would like to search for:"
    echo "1. Retrieve all patient tests."
    echo "2. Retrieve all abnormal patient tests."
    echo "3. Retrieve all patient tests in a given specific period."
    echo "4. Retrieve all patient tests based on test status."
    echo "5. Exit."

    # Read the user's choice
    read choice

    case "$choice" in
      1)  # Retrieve all patient tests
        grep "^$patient_id:" medicalRecord.txt
        ;;

        2)  # Retrieve all abnormal patient tests
            abnormalTestsID $patient_id
            ;;

        3)  # Retrieve all patient tests in a given specific period
                while true; do
                    echo "Enter start date (YYYY-MM):"
                    read start_date

                    # Validate the start_date
                    if ! validate_date "$start_date"; then
                        echo "Invalid start_date format: $start_date. Please enter a valid starting date:"
                        continue
                    fi

                    echo "Enter end date (YYYY-MM):"
                    read end_date

                    # Validate the end_date
                    if ! validate_date "$end_date"; then
                        echo "Invalid end_date format: $end_date. Please enter a valid ending date:"
                        continue
                    fi

                    # Check if start_date is less than end_date
                    if [ "$start_date" \> "$end_date" ]; then
                        echo "Start date must be less than end date. Please enter the dates again:"
                        continue
                    fi

                    # Break the loop if everything is correct
                    break
                done

                # Flag to check if any records were found
                records_found=false

                grep "^$patient_id:" medicalRecord.txt | while IFS=, read -r line; do
                    # Extract the date of the test (format YYYY-MM)
                    test_date=$(echo "$line" | cut -d',' -f2 | cut -d' ' -f2)

                    # Validate the test_date
                    if ! validate_date "$test_date"; then
                        echo "Invalid date format in record: $test_date"
                        continue
                    fi

                    # Compare the test date with the start and end dates
                    if [ "$test_date" = "$start_date" ] || [ "$test_date" = "$end_date" ] || { [ "$test_date" \> "$start_date" ] && [ "$test_date" \< "$end_date" ]; }; then
                        echo "$line"
                        records_found=true
                    fi
                done

                # Print message if no records were found
                if [ "$records_found" = false ]; then
                    echo "No tests found for the given period."
                fi
                ;;

      4)  # Retrieve all patient tests based on test status
        echo "Enter test status (Pending, Completed, or Reviewed):"
        read status

        # Validate status input
        if echo "$status" | grep -q '^[0-9]*$'
        then
          echo "Error: Status should not be a numerical value. Please enter a valid status:"
          continue
        fi

        grep "^$patient_id:" medicalRecord.txt | grep -i "$status"
        ;;

      5)  # Exit
        exit 0
        ;;

      *)  # Handle invalid choices
        echo "Invalid choice. Please select again:"
        read option
        ;;
    esac
  break
  done
}

########################option 4################################################
avgTest() {
  # Initialize arrays to store sums and counts
  declare -A test_sums
  declare -A test_counts

  # Read the medicalRecord.txt file and calculate sums and counts
  while IFS=", " read -r line
  do
    # Extract test name and result
    test_name=$(echo "$line" | cut -d',' -f1 | cut -d':' -f2)
    result=$(echo "$line" | cut -d',' -f3)

    # Remove leading and trailing spaces from test_name and result
    test_name=$(echo "$test_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Only process lines with valid numerical results
    if echo "$result" | grep -Eq '^[0-9]*\.?[0-9]+$'
    then
      # Initialize sums and counts if not already set
      if [ -z "${test_sums[$test_name]}" ]
      then
        test_sums[$test_name]=0
        test_counts[$test_name]=0
      fi

      # Update sum and count
      test_sums[$test_name]=$(echo "${test_sums[$test_name]} + $result" | bc)
      test_counts[$test_name]=$(echo "${test_counts[$test_name]} + 1" | bc)
    fi
  done < medicalRecord.txt

  # Calculate and print the average for each test type
  for test_name in "${!test_sums[@]}"
  do
    sum=${test_sums[$test_name]}
    count=${test_counts[$test_name]}

    if [ "$count" -ne 0 ]
    then
      average=$(echo "scale=2; $sum / $count" | bc)
      printf "Average %s test value = %.2f\n" "$test_name" "$average"
    else
      printf "%s: No valid results\n" "$test_name"
    fi
  done
}

###################################option 5#########################
updateTest() {
    echo "Current Medical Record file contents:"
    cat -n medicalRecord.txt  # Display the file with line numbers

    echo ""
    echo "Enter the line number of the test you want to update:"
    read line_number

    # Validate the line number, as it must be a positive integer
    if ! echo "$line_number" | grep -Eq '^[0-9]+$'; then
        echo "Invalid line number! Please enter a positive integer:"
        return
    fi

    # Validate that the line number exists in the file
    total_lines=$(wc -l < medicalRecord.txt)
    if [ "$line_number" -le 0 ] || [ "$line_number" -gt "$total_lines" ]; then
        echo "Line number out of range! Please enter a valid line number between 1 and $total_lines."
        return
    fi

    # Extract the existing record
    old_record=$(sed -n "${line_number}p" medicalRecord.txt)

    # Prompt user for new test result
    echo "Enter the new test result value:"
    read new_result

    # Validate the new result
    while [ -z "$new_result" ]; do
        echo "Result cannot be empty! Please enter a valid result:"
        read new_result
    done

    # Extract patient ID and details
    patient_id=$(echo "$old_record" | cut -d':' -f1)
    details=$(echo "$old_record" | cut -d':' -f2-)

    # Split the details into fields using IFS
    IFS=',' read -r field1 field2 field3 field4 field5 <<< "$details"

    # Update the third field with the new result
    field3=" $new_result"

    # Reassemble the fields into the updated details string
    updated_details="$field1,$field2,$field3,$field4,$field5"

    # Replace the old record with the updated record in the file
    sed -i "${line_number}s|.*|${patient_id}: ${updated_details}|" medicalRecord.txt

    if [ $? -eq 0 ]; then
        echo "Record updated successfully."
    else
        echo "Failed to update the record."
    fi
}
#################################option 6###########################################
deleteTest() {
  echo "Medical Record file contents:"
  cat -n medicalRecord.txt
  echo ""
  echo "Enter the line number you want to delete:"
  read line_number

  # Validate the line number, as it must be a positive integer
  if ! echo "$line_number" | grep -Eq '^[0-9]+$'
  then
    echo "Invalid line number! Please enter a positive integer:"
    read line_number
    return
  fi

  # Validate that the line number exists in the file
  total_lines=$(wc -l < medicalRecord.txt)
  if [ "$line_number" -le 0 ] || [ "$line_number" -gt "$total_lines" ]
  then
    echo "Line number out of range! Please enter a valid line number between 1 and $total_lines."
    return
  fi

  sed "${line_number}d" medicalRecord.txt > medicalRecord.tmp && mv medicalRecord.tmp medicalRecord.txt
  if [ $? -eq 0 ]
  then
    echo "Record at line number $line_number deleted successfully."
  else
    echo "Error deleting the record."
  fi
}

#########################option 3################################################
abnormalTests() {
    # Check if medicalTest.txt exists
    if [ ! -f medicalTest.txt ]
    then
        echo "'medicalTest.txt' not found!"
        return 1
    fi

    # Declare an array to store test ranges
    declare -A test_ranges

    # Read each test definition from the medicalTest.txt file into the array
    while IFS=';' read -r test_name range unit || [ -n "$test_name" ]
    do
        # Trim spaces and convert test_name and unit to lowercase
        test_name_clean=$(echo "$test_name" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        unit_clean=$(echo "$unit" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        test_ranges["$test_name_clean"]="$range;$unit_clean"
    done < medicalTest.txt

    # Check if medicalRecord.txt exists
    if [ ! -f medicalRecord.txt ]
    then
        echo "'medicalRecord.txt' not found!"
        return 1
    fi

    found_abnormal=false     # Flag to check if any abnormal result is found

    # Read each test result from medicalRecord.txt
    while IFS= read -r line
    do
        # Extract the patient ID and the rest of the line
        current_pid=$(echo "$line" | cut -d':' -f1 | sed 's/^ *//;s/ *$//')

        rest_of_line=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')

        # Split rest_of_line by commas
        IFS=',' read -r test_name_field date_field result_field unit_field status_field <<EOF
$(echo "$rest_of_line")
EOF

        # Trim spaces and standardize data
        test_name=$(echo "$test_name_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        result=$(echo "$result_field" | sed 's/^ *//;s/ *$//')
        unit=$(echo "$unit_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')
        status=$(echo "$status_field" | tr '[A-Z]' '[a-z]' | sed 's/^ *//;s/ *$//')

        # Ensure test_name is not empty
        if [ -z "$test_name" ]
        then
            continue
        fi

        # Fetch the expected range and unit for the test from the associative array
        range_info="${test_ranges[$test_name]}"
        if [ -z "$range_info" ]
        then
            continue
        fi

        range=$(echo "$range_info" | cut -d';' -f1)
        expected_unit=$(echo "$range_info" | cut -d';' -f2)

        # Ensure unit matches
        if [ "$unit" != "$expected_unit" ]
        then
            continue
        fi

        # Initialize min and max values
        min_value=""
        max_value=""

        # Parse the range
        IFS=',' read -ra range_parts <<EOF
$(echo "$range")
EOF

        for part in "${range_parts[@]}"
        do
            part_clean=$(echo "$part" | sed 's/^ *//;s/ *$//')
            if [ "${part_clean#*>}" != "$part_clean" ]
            then
                min_value=${part_clean#*>}
            elif [ "${part_clean#*<}" != "$part_clean" ]
            then
                max_value=${part_clean#*<}
            fi
        done

        # Validate that result is a valid number
        if ! echo "$result" | grep -Eq '^[0-9]+([.][0-9]+)?$'; then
            continue
        fi

        # Perform comparisons
        abnormal=false
        if [ -n "$min_value" ] && [ "$(echo "$result < $min_value" | bc)" -eq 1 ]
        then
            abnormal=true
        fi

        if [ -n "$max_value" ] && [ "$(echo "$result >= $max_value" | bc)" -eq 1 ]
        then
            abnormal=true
        fi

        # Output the result
        if [ "$abnormal" = true ]
        then
            echo "Abnormal result found: $current_pid: $test_name, $date_field, $result, $unit, $status"
            found_abnormal=true
        fi
    done < medicalRecord.txt

    # Print message if no abnormal tests were found
    if [ "$found_abnormal" = false ]
    then
        echo "No abnormal tests."
    fi
}


option=0
while true
do
  menu

  read option
  case "$option"
    in
        1) add_medicalTest ;;
        2) SearchTest_byPatientID ;;
        3) abnormalTests ;;
        4) avgTest ;;
        5) updateTest ;;
        6) deleteTest ;;
        7) echo "Thanks for using our program!"
           exit ;;
        *) echo "Invalid choice. Please select again:"
           read option;;

    esac

done