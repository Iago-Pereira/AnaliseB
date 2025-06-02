# Projeto: Taxa de Variação por Operadora

Este projeto calcula a taxa de variação percentual de atendimentos por grupo econômico, exibindo os dados mensalmente. Ele utiliza **Python**, **Pandas**, **SQLAlchemy**, e é containerizado com **Docker** e orquestrado com **docker-compose**. O cálculo é baseado nos dados do índice de desempenho do atendimento das prestadoras de telecomunicações no Brasil.

---

## Estrutura do Repositório

docker-compose.yml # Orquestração de serviços com Docker

Dockerfile # Definição do contêiner

code/

├── ingestao.py # Código para ingestão dos dados

├── engine.py # Configuração da conexão com o banco

├── view.sql # Script de criação da view

├── ddl.sql # Script de criação de tabelas e extensões, se necessário

data/

├── SCM/ # Diretório com dados para ingestão (Serviço de Comunicação Multimídia)

├── SMP/ # Diretório com dados para ingestão (Serviço Móvel Pessoal)

├── STFC/ # Diretório com dados para ingestão (Serviço Telefônico Fixo Comutado)


---

## Fonte dos Dados

Os dados utilizados neste projeto estão disponíveis no **Portal Brasileiro de Dados Abertos**, sob o título:

- [Índice de Desempenho do Atendimento das Prestadoras de Telecomunicações](https://dados.gov.br/dados/conjuntos-dados/indice-desempenho-atendimento)

Recomenda-se o download dos arquivos para as categorias SCM, SMP e STFC, a serem salvos nos diretórios correspondentes dentro da pasta `data/` antes da execução do projeto.

---

## Etapas do Projeto

1. **Configuração do Banco e Tabelas**
   - O arquivo `code/ddl.sql` define tabelas, extensões e outras estruturas necessárias no banco de dados.

2. **Ingestão de Dados**
   - O script `code/ingestao.py` lê os dados localizados na pasta `data/` e os insere nas tabelas do banco de dados PostgreSQL.

3. **Criação da View**
   - O script `code/view.sql` contém a lógica para criar ou recriar a view `view_taxa_variacao`, que calcula a taxa de variação percentual de atendimentos por grupo econômico.

4. **Consulta e Processamento**
   - O script `code/ingestao.py` consulta a view e gera um DataFrame `df_resultado`, que pode ser exportado como CSV ou imagem.

5. **Containerização e Orquestração**
   - O `Dockerfile` configura a imagem Docker para o projeto, incluindo bibliotecas como `pandas`, `SQLAlchemy` e `unidecode`.
   - O `docker-compose.yml` orquestra a execução do contêiner com o banco de dados e o código.

---

## Instruções de Uso

1. **Obter os Dados**
   - Acesse o portal [dados.gov.br](https://dados.gov.br/dados/conjuntos-dados/indice-desempenho-atendimento) e baixe os arquivos para as categorias **SCM**, **SMP** e **STFC**.
   - Salve os arquivos no diretório correspondente dentro da pasta `data/`.

2. **Build do Contêiner**
docker-compose build

3. **Execução do Contêiner**
docker-compose up

4. **Acesso e Logs**
- O serviço executará os scripts de criação de tabelas, ingestão e consulta automaticamente.
- Os logs da execução serão exibidos no terminal.

---

## Requisitos

- **Docker** e **docker-compose** instalados.
- Banco de dados compatível com PostgreSQL.
- Python 3.11+ (usado na imagem base do Docker).
- As bibliotecas `pandas`, `SQLAlchemy`, `unidecode` e demais dependências são instaladas automaticamente no contêiner.

---

## Observações Importantes

- Configure corretamente o `docker-compose.yml` com as credenciais e endereços do banco de dados.
- O diretório `data/` deve conter os dados correspondentes para que o processo de ingestão funcione.

---

# Bibliotecas Otimizadoras da Tarefa 

## Pandas

[Pandas](https://pandas.pydata.org/) é uma biblioteca poderosa e flexível para manipulação e análise de dados em Python. Ela oferece estruturas de dados eficientes, como `DataFrame` e `Series`, e uma ampla gama de funcionalidades para:

- **Leitura e gravação de dados**: CSV, Excel, bancos de dados, entre outros.
- **Transformação e limpeza de dados**: filtros, agrupamentos, cálculos agregados.
- **Análise estatística**: geração de insights, cálculo de tendências e visualização.

No contexto deste projeto, o Pandas permite:

- **Leitura fácil dos arquivos de dados brutos** (CSV) baixados do portal oficial.
- **Realização de transformações complexas e cálculos** de forma simples e eficiente (como a taxa de variação).
- **Exportação de resultados** para formatos como CSV ou até imagens (por meio de visualizações e tabelas renderizadas).

## SQLAlchemy

[SQLAlchemy](https://www.sqlalchemy.org/) é uma biblioteca que facilita a **conexão e interação com bancos de dados relacionais** no Python. Ela oferece:

- Uma **abstração de alto nível sobre SQL**, permitindo trabalhar com objetos Python em vez de strings SQL.
- **Mapeamento objeto-relacional (ORM)** para manipular tabelas como se fossem classes Python.
- Gerenciamento eficiente de **conexões e transações** com o banco de dados.
- Portabilidade entre diferentes sistemas de gerenciamento de bancos de dados (PostgreSQL, MySQL, SQLite, etc.).

Neste projeto, o SQLAlchemy permite:

- **Conectar-se ao banco de dados PostgreSQL** de forma simples e segura.
- **Inserir dados do Pandas DataFrame** diretamente nas tabelas do banco com `to_sql`.
- **Executar queries complexas** ou chamadas de stored procedures/views como métodos Python.

## Benefícios Combinados

A combinação de **Pandas + SQLAlchemy** torna o fluxo de ingestão e análise de dados mais prático e eficiente:

- O Pandas facilita o processamento e transformação dos dados de entrada.
- O SQLAlchemy simplifica a conexão e o carregamento dos dados no banco de dados.
- Ambas as bibliotecas **reduzem significativamente o tempo e a complexidade do desenvolvimento**, eliminando a necessidade de escrever comandos SQL extensos e complexos e permitindo uma automação eficiente do processo.

Essas bibliotecas juntas permitem que o projeto seja mais ágil, seguro e robusto para lidar com grandes volumes de dados e transformações analíticas.
