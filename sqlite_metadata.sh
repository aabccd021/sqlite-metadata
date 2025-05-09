db_file=${1:-''}
output_file=${2:-''}

if [ -n "$output_file" ]; then
  exec >"$output_file"
fi

sqlite_version=$(sqlite3 "$db_file" "SELECT sqlite_version();")
echo "# SQLite Version"
echo "$sqlite_version"

tables=$(sqlite3 "$db_file" ".tables")

echo
echo
echo "# Tables"

for table in $tables; do
  echo
  echo
  echo "## $table"

  echo
  echo "### table_info"
  echo "|cid|name|type|notnull|dflt_value|pk|"
  echo "|---|----|----|-------|----------|--|"
  sqlite3 "$db_file" "PRAGMA table_info($table);"

  echo
  echo "### foreign_key_list"
  echo "|seq|id|table|from|to|on_update|on_delete|match|"
  echo "|---|--|-----|----|--|---------|---------|-----|"
  sqlite3 "$db_file" "PRAGMA foreign_key_list($table);"

  echo
  echo "### constraints"
  echo '```sql'
  sqlite3 "$db_file" "SELECT sql FROM sqlite_master WHERE type='table' AND name='$table' AND sql LIKE '%CHECK%';"
  echo '```'
done

indexes=$(sqlite3 "$db_file" "SELECT name FROM sqlite_master WHERE type='index';")
echo "# Indexes"
echo '```'
echo "$indexes" | sort
echo '```'
echo

views=$(sqlite3 "$db_file" "SELECT name FROM sqlite_master WHERE type='view';")
echo "# Views"
echo '```'
echo "$views" | sort
echo '```'
echo

triggers=$(sqlite3 "$db_file" "SELECT name FROM sqlite_master WHERE type='trigger';")
echo "# Triggers"
echo '```'
echo "$triggers" | sort
echo '```'
echo
