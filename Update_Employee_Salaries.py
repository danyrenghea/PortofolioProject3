import psycopg2

# Configurating Connection to PostgreSQL data base
conn = psycopg2.connect(
    dbname="greencycles",
    user="postgres",
    password="pasword",
    host="localhost",
    port="5433"
)

# Setting of autocommit on True
conn.set_session(autocommit=True)

# Creating a cursor for execute SQL commands
cursor = conn.cursor()

# Calling of the stored procedure
cursor.execute("CALL emp_salary_update();")

# Ending of connection and of the cursor 
cursor.close()
conn.close()