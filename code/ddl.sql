-- Criar o esquema do Data Mart
CREATE SCHEMA IF NOT EXISTS data_mart_atendimento;
COMMENT ON SCHEMA data_mart_atendimento IS 'Data Mart para análise de atendimento de operadoras de telecomunicações.';

-- ================================
-- TABELA DIM_TEMPO
-- ================================
CREATE TABLE data_mart_atendimento.dim_tempo (
    id_tempo SERIAL PRIMARY KEY,
    data DATE NOT NULL
);
COMMENT ON TABLE data_mart_atendimento.dim_tempo IS 'Dimensão Tempo apenas com data (ano-mês).';
COMMENT ON COLUMN data_mart_atendimento.dim_tempo.id_tempo IS 'Identificador único da dimensão tempo.';
COMMENT ON COLUMN data_mart_atendimento.dim_tempo.data IS 'Data no formato YYYY-MM.';

-- ================================
-- TABELA DIM_OPERADORA
-- ================================
CREATE TABLE data_mart_atendimento.dim_operadora (
    id_operadora SERIAL PRIMARY KEY,
    nome_grupo_economico VARCHAR(100) NOT NULL
);
COMMENT ON TABLE data_mart_atendimento.dim_operadora IS 'Dimensão Operadora com informações da empresa.';
COMMENT ON COLUMN data_mart_atendimento.dim_operadora.id_operadora IS 'Identificador único da operadora.';
COMMENT ON COLUMN data_mart_atendimento.dim_operadora.nome_grupo_economico IS 'Nome do grupo econômico da operadora.';

-- ================================
-- TABELA DIM_SERVICO
-- ================================
CREATE TABLE data_mart_atendimento.dim_servico (
    id_servico SERIAL PRIMARY KEY,
    nome_servico VARCHAR(50) NOT NULL
);
COMMENT ON TABLE data_mart_atendimento.dim_servico IS 'Dimensão Serviço (SMP, STFC, SCM).';
COMMENT ON COLUMN data_mart_atendimento.dim_servico.id_servico IS 'Identificador único do serviço.';
COMMENT ON COLUMN data_mart_atendimento.dim_servico.nome_servico IS 'Nome do serviço (ex.: SMP, STFC, SCM).';

-- ================================
-- TABELA FATO_ATENDIMENTO
-- ================================
CREATE TABLE data_mart_atendimento.fato_atendimento (
    id_fato SERIAL PRIMARY KEY,
    id_tempo INTEGER NOT NULL REFERENCES data_mart_atendimento.dim_tempo(id_tempo),
    id_operadora INTEGER NOT NULL REFERENCES data_mart_atendimento.dim_operadora(id_operadora),
    id_servico INTEGER NOT NULL REFERENCES data_mart_atendimento.dim_servico(id_servico),

    indicador_ida NUMERIC(10,4),                                   -- indicador_de_desempenho_no_atendimento_(ida)
    qtd_reclamacoes_periodo INTEGER,                              -- quantidade_de_reclamacoes_no_periodo
    qtd_sol_resolvidas_5dias INTEGER,                             -- quantidade_de_sol._resolvidas_em_ate_5_dias
    qtd_sol_resolvidas_periodo INTEGER,                           -- quantidade_de_sol._resolvidas_no_periodo
    qtd_acessos_servico INTEGER,                                  -- quantidade_de_acessos_em_servico
    qtd_reabertas INTEGER,                                        -- quantidade_de_reabertas
    qtd_reclamacoes INTEGER,                                      -- quantidade_de_reclamacoes
    qtd_resolvidas INTEGER,                                       -- quantidade_de_resolvidas
    taxa_reabertas NUMERIC(10,4),                                -- taxa_de_reabertas
    taxa_resolvidas_5dias NUMERIC(10,4),                         -- taxa_de_resolvidas_em_5_dias_uteis
    taxa_resolvidas_periodo NUMERIC(10,4),                       -- taxa_de_resolvidas_no_periodo
    indice_reclamacoes NUMERIC(10,4),                            -- indice_de_reclamacoes

    qtd_respondidas INTEGER,                                      -- quantidade_de_respondidas
    qtd_sol_respondidas_5dias INTEGER,                           -- quantidade_de_sol._respondidas_em_ate_5_dias
    qtd_sol_respondidas_periodo INTEGER,                         -- quantidade_de_sol._respondidas_no_periodo
    taxa_respondidas_5dias NUMERIC(10,4),                        -- taxa_de_respondidas_em_5_dias_uteis
    taxa_respondidas_periodo NUMERIC(10,4),                      -- taxa_de_respondidas_no_periodo

    UNIQUE (id_tempo, id_operadora, id_servico)
);
COMMENT ON TABLE data_mart_atendimento.fato_atendimento IS 'Tabela fato central com as métricas quantitativas do atendimento.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.id_fato IS 'Identificador único do registro de fato.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.id_tempo IS 'Chave estrangeira para a dimensão tempo.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.id_operadora IS 'Chave estrangeira para a dimensão operadora.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.id_servico IS 'Chave estrangeira para a dimensão serviço.';

COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.indicador_ida IS 'Indicador de Desempenho no Atendimento (IDA).';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_reclamacoes_periodo IS 'Quantidade de reclamações no período.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_sol_resolvidas_5dias IS 'Quantidade de solicitações resolvidas em até 5 dias úteis.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_sol_resolvidas_periodo IS 'Quantidade de solicitações resolvidas no período.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_acessos_servico IS 'Quantidade de acessos no serviço.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_reabertas IS 'Quantidade de solicitações reabertas.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_reclamacoes IS 'Quantidade de reclamações.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_resolvidas IS 'Quantidade de solicitações resolvidas.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.taxa_reabertas IS 'Taxa de reabertura.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.taxa_resolvidas_5dias IS 'Taxa de resolvidas em 5 dias úteis.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.taxa_resolvidas_periodo IS 'Taxa de resolvidas no período.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.indice_reclamacoes IS 'Índice de Reclamações.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_respondidas IS 'Quantidade de solicitações respondidas.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_sol_respondidas_5dias IS 'Quantidade de solicitações respondidas em até 5 dias úteis.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.qtd_sol_respondidas_periodo IS 'Quantidade de solicitações respondidas no período.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.taxa_respondidas_5dias IS 'Taxa de respondidas em 5 dias úteis.';
COMMENT ON COLUMN data_mart_atendimento.fato_atendimento.taxa_respondidas_periodo IS 'Taxa de respondidas no período.';

-- Índices para performance
CREATE INDEX idx_fato_tempo ON data_mart_atendimento.fato_atendimento(id_tempo);
CREATE INDEX idx_fato_operadora ON data_mart_atendimento.fato_atendimento(id_operadora);
CREATE INDEX idx_fato_servico ON data_mart_atendimento.fato_atendimento(id_servico);