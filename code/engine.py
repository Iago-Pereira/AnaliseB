# %%

from sqlalchemy import create_engine, text
# %%

engine = create_engine("postgresql+psycopg2://IagoPereira:Dal3Bamb4@localhost:5432/mydatabase")

# %%

# Testar a conexão
with engine.connect() as connection:
    result = connection.execute(text("SELECT version();"))
    for row in result:
        print(row)
# %%

# Abrindo e lendo o conteúdo do arquivo .sql
with open("ddl.sql", "r", encoding="utf-8") as open_file:
    ddl_script = open_file.read()

# %%

# Executando o script no banco
with engine.connect() as connection:
    connection.execute(text(ddl_script))
    connection.commit()
# %%

# Verificar se as tabelas foram criadas
with engine.connect() as connection:
    result = connection.execute(text("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'data_mart_atendimento'
    """))
    print("Tabelas no schema data_mart_atendimento:")
    for row in result:
        print("-", row[0])
# %%
