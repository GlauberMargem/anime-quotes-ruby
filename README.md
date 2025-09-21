# anime-quotes-ruby

Projeto simples em Ruby que busca informações de animes usando a API **AnimeChan** ([https://animechan.io/](https://animechan.io/)) — obtém dados do anime, traduz a sinopse e salva no **PostgreSQL**.

---

## Conteúdo deste README

* Descrição
* Tecnologias
* Pré-requisitos
* Instalação
* Configuração do banco (Windows / pgAdmin / linha de comando)
* Uso
* Estrutura de arquivos
* Esquema do banco (SQL)
* Depuração / Solução de problemas (erros comuns que você encontrou)
* Boas práticas / melhorias futuras
* Licença

---

## Descrição

O projeto consulta a API `https://animechan.io/` para obter dados de um anime pelo nome, exibe no console a informação (nome, número de episódios e sinopse) e salva esses dados em uma tabela no PostgreSQL. Também possui integração (via `formatarUrl.rb`) com uma API de tradução para salvar a sinopse traduzida.

## Tecnologias

* Ruby (recomendo 3.x)
* Gems: `httparty`, `pg`, `erb` (e opcionalmente `dotenv` para variáveis de ambiente)
* PostgreSQL (no seu ambiente você usa a versão 17)

---

## Pré-requisitos

1. Ruby instalado (3.x).
2. PostgreSQL instalado (neste projeto usamos a sua instalação com serviço `postgresql-x64-17`).
3. Gems do projeto (listadas no `Gemfile`).

Se não tiver as gems instaladas, rode:

```bash
bundle install
# ou
# gem install pg httparty
```

> Sugestão: usar `bundle` (Bundler) para garantir versões.

---

## Instalação / Configuração (rápido)

1. Clone o repositório:

```bash
git clone https://github.com/GlauberMargem/anime-quotes-ruby.git
cd anime-quotes-ruby
```

2. Instale as dependências:

```bash
bundle install
```

3. Configure as variáveis de ambiente (recomendado) ou edite `bancoDeDados.rb` com as credenciais:

Crie um arquivo `.env` (se usar `dotenv`) com:

```
DB_NAME=animequotes
DB_USER=anime_user
DB_PASSWORD=sua_senha_segura
DB_HOST=localhost
DB_PORT=5432
```

No Ruby, basta adicionar no topo dos seus scripts (se usar dotenv):

```ruby
require 'dotenv/load'
```

> Alternativa: deixar no `bancoDeDados.rb` valores padrão e substituir manualmente.

---

## Configuração do PostgreSQL (passo a passo para Windows)

### 1) Verificar serviço

Abra `services.msc` (Win + R -> services.msc) e verifique o serviço `postgresql-x64-17`.

* Se não estiver rodando: clique com o botão direito -> **Iniciar**.
* Para reiniciar: **Reiniciar**.

Você também pode usar o CMD/PowerShell com privilégios de administrador:

```powershell
# verificar status
sc query "postgresql-x64-17"

# iniciar
net start "postgresql-x64-17"

# parar
net stop "postgresql-x64-17"
```

### 2) Se o `psql` não estiver no PATH (comum) — comando direto:

```powershell
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d postgres -h localhost -p 5432
```

> Ajuste o caminho se a sua instalação estiver em outra pasta (por exemplo `C:\Program Files\PostgreSQL\17\bin`).

### 3) Criar database e usuário (via `psql` ou pgAdmin)

Conecte-se como `postgres` (ou use pgAdmin) e rode:

```sql
CREATE DATABASE animequotes;
CREATE USER anime_user WITH ENCRYPTED PASSWORD 'sua_senha_segura';
GRANT ALL PRIVILEGES ON DATABASE animequotes TO anime_user;
```

### 4) Criação da tabela (pode ser executado pelo próprio script Ruby ou manualmente)

SQL da tabela usada pelo projeto:

```sql
CREATE TABLE IF NOT EXISTS animes (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255),
  episodios INT,
  sinopse TEXT,
  sinopse_traduzida TEXT,
  created_at TIMESTAMP DEFAULT now()
);
```

---

## Exemplo: atualizar `bancoDeDados.rb` para usar variáveis de ambiente

```ruby
require 'pg'

class BancoDeDados
  def initialize
    @conexao = PG.connect(
      dbname: ENV.fetch('DB_NAME', 'postgres'),
      user: ENV.fetch('DB_USER', 'postgres'),
      password: ENV['DB_PASSWORD'],
      host: ENV.fetch('DB_HOST', 'localhost'),
      port: ENV.fetch('DB_PORT', 5432)
    )
  end

  def criar_tabela
    @conexao.exec <<-SQL
      CREATE TABLE IF NOT EXISTS animes (
        id SERIAL PRIMARY KEY,
        nome VARCHAR(255),
        episodios INT,
        sinopse TEXT,
        sinopse_traduzida TEXT
      );
    SQL
  end

  def salvar_anime(nome, episodios, sinopse, sinopse_traduzida)
    @conexao.exec_params(
      "INSERT INTO animes (nome, episodios, sinopse, sinopse_traduzida) VALUES ($1, $2, $3, $4)",
      [nome, episodios, sinopse, sinopse_traduzida]
    )
  end
end
```

Se quiser usar `.env`, adicione `gem 'dotenv'` ao `Gemfile` e `require 'dotenv/load'` no topo do seu script.

---

## Uso

Rodar o script principal:

ruby buscarAnime.rb

Digite o nome do anime quando solicitado (ex.: Fullmetal alchemist).

Se a API responder corretamente, os dados serão exibidos e salvos no banco.

### Estrutura de pastas

anime-quotes-ruby/
├─ buscarAnime.rb        # Script principal
├─ bancoDeDados.rb       # Classe de conexão PostgreSQL
├─ formatarUrl.rb        # Formata URL de tradução
├─ Gemfile
├─ Gemfile.lock
└─ README.md

### Estrutura do banco

Tabela criada automaticamente:

CREATE TABLE IF NOT EXISTS animes (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255),
  episodios INT,
  sinopse TEXT,
  sinopse_traduzida TEXT,
  created_at TIMESTAMP DEFAULT now()
);

### Erros comuns

psql: command not found

Adicione C:\Program Files\PostgreSQL\17\bin ao PATH ou rode o executável completo.

server closed the connection unexpectedly

O serviço postgresql-x64-17 não está rodando. Inicie em services.msc.

Senha incorreta

Resete no pgAdmin ou via SQL:

ALTER USER postgres PASSWORD 'nova_senha';

### Autor

Desenvolvido por Glauber Margem.
