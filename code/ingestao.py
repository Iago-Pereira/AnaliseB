# %%

import pandas as pd
from unidecode import unidecode
import os
from sqlalchemy import create_engine, text, Date

# %%

engine = create_engine("postgresql+psycopg2://IagoPereira:Dal3Bamb4@localhost:5432/mydatabase")
# %%

def carregar_arquivo(caminho_arquivo):
    return pd.read_excel(caminho_arquivo, engine='odf', skiprows=8)
# %%

# Tratamento dos atributos
def limpar_dados(df):
    df = df.dropna(subset=['GRUPO ECONÔMICO'])
    df = df.rename(columns={
        "GRUPO ECONÔMICO": "grupo_economico",
        "VARIÁVEL": "variavel"
    })
    df['grupo_economico'] = df['grupo_economico'].str.split(' ').str[0]
    return df
# %%

def transformar_formato(df):
    # Aplica melt e pivot para deixar os dados em formato tabular
    df_melted = pd.melt(
        df,
        id_vars=['grupo_economico', 'variavel'],
        var_name='data',
        value_name='valor'
    )
    df_pivot = df_melted.pivot_table(
        index=['grupo_economico', 'data'],
        columns='variavel',
        values='valor'
    ).reset_index()
    df_pivot.columns.name = None
    return df_pivot
# %%

def padronizar_colunas(df):
    # Remove acentos, espaços, coloca minúsculas e converte colunas de quantidade
    df.columns = [unidecode(col).replace(" ", "_").lower() for col in df.columns]
    colunas_quantidade = [col for col in df.columns if col.startswith('quantidade')]
    for col in colunas_quantidade:
        df[col] = df[col].astype('Int64')
    return df
# %%

def processar_arquivo(caminho_arquivo, servico):
    df = carregar_arquivo(caminho_arquivo)
    df = limpar_dados(df)
    df = transformar_formato(df)
    df = padronizar_colunas(df)
    df['servico'] = servico
    return df
# %%

def carregar_todos_dados(pastas):
    dfs = []
    for servico, pasta in pastas.items():
        arquivos = [f for f in os.listdir(pasta) if f.endswith('.ods')]
        for arquivo in arquivos:
            caminho_arquivo = os.path.join(pasta, arquivo)
            df = processar_arquivo(caminho_arquivo, servico)
            dfs.append(df)
    return pd.concat(dfs, ignore_index=True)
# %%

# Uso
pastas = {
    'SCM': '../data/SCM',
    'SMP': '../data/SMP',
    'STFC': '../data/STFC'
}

df_final = carregar_todos_dados(pastas)
# %%

# Se df_final['data'] está como string 'YYYY-MM'
# df_final['data'] = df_final['data'].apply(lambda x: x + '-01')
# %%

# dim_tempo
df_final['data'] = pd.to_datetime(df_final['data']).dt.date
dim_tempo = df_final[['data']].drop_duplicates().sort_values('data').reset_index(drop=True)

dim_tempo.to_sql('dim_tempo', engine, schema='data_mart_atendimento', if_exists='append', index=False)

# %%

# dim_operadora
dim_operadora = df_final[['grupo_economico']].drop_duplicates().rename(columns={'grupo_economico':'nome_grupo_economico'})

dim_operadora.to_sql('dim_operadora', engine, schema='data_mart_atendimento', if_exists='append', index=False)

# %%

# dim_servico
dim_servico = df_final[['servico']].drop_duplicates().rename(columns={'servico':'nome_servico'})

dim_servico.to_sql('dim_servico', engine, schema='data_mart_atendimento', if_exists='append', index=False)
# %%

# Carregar as dimensões para DataFrames com ids para fazer o merge

dim_tempo_db = pd.read_sql('SELECT id_tempo, data FROM data_mart_atendimento.dim_tempo', engine)
dim_operadora_db = pd.read_sql('SELECT id_operadora, nome_grupo_economico FROM data_mart_atendimento.dim_operadora', engine)
dim_servico_db = pd.read_sql('SELECT id_servico, nome_servico FROM data_mart_atendimento.dim_servico', engine)
# %%

dim_tempo_db['data'] = pd.to_datetime(dim_tempo_db['data']).dt.date
# Merge para incluir as chaves
fato = df_final.merge(dim_tempo_db, left_on='data', right_on='data', how='left')
fato = fato.merge(dim_operadora_db, left_on='grupo_economico', right_on='nome_grupo_economico', how='left')
fato = fato.merge(dim_servico_db, left_on='servico', right_on='nome_servico', how='left')

# %%
# Selecionar as colunas de fato com nomes iguais aos da tabela fato
fato = fato.rename(columns={
    'indicador_de_desempenho_no_atendimento_(ida)': 'indicador_ida',
    'indice_de_reclamacoes': 'indice_reclamacoes',
    'quantidade_de_acessos_em_servico': 'qtd_acessos_servico',
    'quantidade_de_reabertas': 'qtd_reabertas',
    'quantidade_de_reclamacoes': 'qtd_reclamacoes',
    'quantidade_de_reclamacoes_no_periodo': 'qtd_reclamacoes_periodo',
    'quantidade_de_resolvidas': 'qtd_resolvidas',
    'quantidade_de_sol._resolvidas_em_ate_5_dias': 'qtd_sol_resolvidas_5dias',
    'quantidade_de_sol._resolvidas_no_periodo': 'qtd_sol_resolvidas_periodo',
    'taxa_de_reabertas': 'taxa_reabertas',
    'taxa_de_resolvidas_em_5_dias_uteis': 'taxa_resolvidas_5dias',
    'taxa_de_resolvidas_no_periodo': 'taxa_resolvidas_periodo',
})

# Selecionar as colunas chave e as métricas, ignorando colunas de dimensão e outras desnecessárias
fato = fato[[
    'id_tempo', 'id_operadora', 'id_servico',
    'indicador_ida', 'indice_reclamacoes', 'qtd_acessos_servico', 'qtd_reabertas',
    'qtd_reclamacoes', 'qtd_reclamacoes_periodo', 'qtd_resolvidas',
    'qtd_sol_resolvidas_5dias', 'qtd_sol_resolvidas_periodo',
    'taxa_reabertas', 'taxa_resolvidas_5dias', 'taxa_resolvidas_periodo'
]]

# Gravar na tabela fato
fato.to_sql('fato_atendimento', engine, schema='data_mart_atendimento', if_exists='append', index=False)

# %%

with open("view.sql", "r", encoding="utf-8") as open_file:
    view_script = open_file.read()
# %%

with engine.connect() as connection:
    print("Executando script para criar/atualizar a função que cria a view...")
    connection.execute(text(view_script))
    connection.commit()

    print("Executando a função para criar/recriar a view...")
    connection.execute(text("SELECT data_mart_atendimento.criar_view_taxa_variacao();"))
    connection.commit()

    print("Consultando a view...")
    query = """
        SELECT * FROM data_mart_atendimento.view_taxa_variacao;
    """
    df_resultado = pd.read_sql(query, connection)
# %%

df_resultado