#!/bin/bash

: ' This script searches for dependencies in DLT models.
    It searches for dependencies in the models in the marts directory and the models in the
     directories specified in dep_directories.
    It then prints the source files for the mart being searched and the dependencies found in
     other models.
    ** Please notice that the script might duplicate dependencies if the same dependency is found in
     multiple models. You can use the python code list(dict.fromkeys(mylist)) to remove duplicates easily.
    ** The script will also find all source files for dependencies that have the same name.'

base_path="$HOME/projects/data-analytics-dbt"
marts_dir="$base_path/models/marts"

# Name of the mart to search (without the .sql extension)
# You can replace this with * to search all marts in marts_dir (mart_to_search="*")
mart_to_search="sat_invoicing_summary_origination"

dep_directories=("$base_path/models/staging" "$base_path/models/intermediate")

debug=0

echo_path_without_base() {
    path_without_sql_extension=$(echo "$1" | sed 's/.sql//')
    echo "${path_without_sql_extension/$base_path\//}"
}

debug_echo() {
    if [ $debug -eq 1 ]; then
        echo "$1"
    fi
}

# Function that will go through dep_directories and search for dependencies recursively
dep_search() {
    mart_dep_table_name="$1"

    debug_echo "Searching dependencies for: $mart_dep_table_name"
    for dir in "${dep_directories[@]}"; do
        all_files=$(find "$dir" -type f -name "*.sql")

        for model_file in $all_files; do
            if grep -q -E "CREATE( OR REFRESH)?( TEMPORARY)? LIVE (VIEW|TABLE) $1" "$model_file"; then

                debug_echo "found dependency $mart_dep_table_name in $model_file"
                echo_path_without_base "    \"$model_file\","
                model_dep_table_names=$(grep -o 'LIVE\.[a-zA-Z0-9_]*' "$model_file" | sed 's/LIVE\.//')

                for model_dep_table_name in $model_dep_table_names; do
                    dep_search "$model_dep_table_name"
                done

            fi
        done

    done
}

# Loop through each SQL model file in the directory
mart_files=$(find "$marts_dir" -type f -name "$mart_to_search.sql")
for mart_file in $mart_files; do
    # echo "Dependencies for $marts_dir:"
    echo ""
    debug_echo "Source files for $mart_file:"
    echo_path_without_base "    \"$mart_file\","

    # Extract table names from the model file
    mart_dep_table_names=$(grep -o 'LIVE\.[a-zA-Z0-9_]*' "$mart_file" | sed 's/LIVE\.//')

    # Loop through each table name and search for dependencies in other model files
    for mart_dep_table_name in $mart_dep_table_names; do
        dep_search "$mart_dep_table_name"
    done

done