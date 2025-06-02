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

5. **Exportar o Resultado**
- O DataFrame `df_resultado` pode ser configurado para exportar como CSV ou imagem no script `ingestao.py`.

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


