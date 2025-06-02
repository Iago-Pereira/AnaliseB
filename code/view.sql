-- Habilitar a extensão necessária para crosstab (caso ainda não esteja ativa)
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Função que cria ou recria a view dinamicamente
CREATE OR REPLACE FUNCTION data_mart_atendimento.criar_view_taxa_variacao()
RETURNS void AS
$$
DECLARE
    lista_colunas text;
    sql text;
BEGIN
    -- Obter os nomes dos grupos econômicos e gerar a lista de colunas dinamicamente
    SELECT string_agg(
               format('%I NUMERIC(10,2)', nome_grupo_economico),
               ', '
           )
    INTO lista_colunas
    FROM (
        SELECT DISTINCT nome_grupo_economico
        FROM data_mart_atendimento.dim_operadora
        ORDER BY nome_grupo_economico
    ) t;

    -- Construir o SQL para criar ou substituir a view
    sql := format($f$
        CREATE OR REPLACE VIEW data_mart_atendimento.view_taxa_variacao AS
        SELECT mes,
               ROUND(AVG(taxa_variacao)::NUMERIC, 2) AS "Taxa de Variação Média",
               %s
        FROM (
            SELECT
                to_char(dt.data, 'YYYY-MM') AS mes,
                dop.nome_grupo_economico,
                ((fa.taxa_resolvidas_5dias - lag(fa.taxa_resolvidas_5dias) OVER (PARTITION BY fa.id_operadora ORDER BY dt.data)) /
                 NULLIF(lag(fa.taxa_resolvidas_5dias) OVER (PARTITION BY fa.id_operadora ORDER BY dt.data), 0)) * 100 AS taxa_variacao
            FROM data_mart_atendimento.fato_atendimento fa
            JOIN data_mart_atendimento.dim_tempo dt ON fa.id_tempo = dt.id_tempo
            JOIN data_mart_atendimento.dim_operadora dop ON fa.id_operadora = dop.id_operadora
            WHERE fa.taxa_resolvidas_5dias IS NOT NULL
        ) sub
        GROUP BY mes
        ORDER BY mes
    $f$, 
    (
        SELECT string_agg(
            format(
                'ROUND(AVG(CASE WHEN nome_grupo_economico = %L THEN taxa_variacao END)::NUMERIC, 2) - ROUND(AVG(taxa_variacao)::NUMERIC, 2) AS %I',
                nome_grupo_economico,
                nome_grupo_economico
            ),
            ', '
        )
        FROM (
            SELECT DISTINCT nome_grupo_economico
            FROM data_mart_atendimento.dim_operadora
        ) t
    )
    );

    -- Executar o SQL dinâmico
    EXECUTE sql;
END;
$$ LANGUAGE plpgsql;