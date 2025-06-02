# Usar a imagem base com Python 3.11.12 e Debian Bookworm
FROM python:3.11.12-bookworm

# Definir diretório de trabalho dentro do contêiner
WORKDIR /app

# Copiar os scripts Python para o contêiner
COPY code/engine.py .
COPY code/ingestao.py .

# Instalar as bibliotecas necessárias
RUN pip install --no-cache-dir pandas SQLAlchemy unidecode

# Definir o comando padrão para execução do script de ingestão
CMD ["python", "ingestao.py"]