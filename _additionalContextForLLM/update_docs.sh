#!/usr/bin/env bash
# Knowledge Assembler for CheckMade Project

set -e 
set -o pipefail


# ======================================================
# UTILITY FUNCTIONS
# ======================================================

# Initialize output file
init_output_file() {
    local file="$1"
    mkdir -p "$(dirname "$file")"
    > "$file"
}



# ======================================================
# MAIN FUNCTION
# ======================================================

main() {
    
    # ASSEMBLE DB FULL INFO
    # ---------------------------
    
    # DB Schema (Business/Summary)
    output="db_schema_business.md"
    init_output_file "$output"
    
    # Define queries
    local table_query="SELECT t.table_name, c.column_name, c.data_type, c.is_nullable FROM information_schema.tables t JOIN information_schema.columns c ON t.table_name = c.table_name WHERE t.table_schema = 'public' ORDER BY t.table_name, c.ordinal_position;"
    local relation_query="SELECT tc.table_name AS table_name, kcu.column_name AS column, ccu.table_name AS references_table, ccu.column_name AS references_column FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' ORDER BY tc.table_name;"
    
    {
        echo "--- DB Business Schema: All Tables and Fields ---"
        echo
        psql -d cm_ops -c "$table_query"
        echo
        echo "--- DB Business Schema: Relationships ---"
        echo
        psql -d cm_ops -c "$relation_query"
    } > "$output"
    
    # DB Schema (SQL)
    output="db_schema_technical.sql"
    init_output_file "$output"
    pg_dump --schema-only --no-owner cm_ops > "$output"
}

main
