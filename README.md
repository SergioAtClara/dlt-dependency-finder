# DLT Dependency Finder

DLT Dependency Finder is a utility script designed to search for dependencies in DLT mart models present in [data-analytics-dbt repository](https://github.com/clara-team/data-analytics-dbt/). This script simplifies the process of identifying dependencies within marts.

## Usage

1. **Set the `base_path` and `mart_to_search` variables** in the `dlt_dep_find.sh` script:

   - `base_path`: This should be set to the path where you cloned the `data-analytics-dbt` repository.
   - `mart_to_search`: Set this to the name of the mart to search (without the `.sql` extension). You can also set `mart_to_search="*"` to search all marts in the `marts_dir`.

2. **Run the script**:

   ```bash
   bash ./dlt_dep_find.sh
   ```