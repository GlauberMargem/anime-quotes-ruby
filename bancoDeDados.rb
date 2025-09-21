require "pg"

class BancoDeDados
    def initialize
        @conexao = PG.connect(
        dbname: "postgres",   
        user: "postgres",
        password: "postgres",
        host: "127.0.0.1",
        port: 5432
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
        puts " Anime '#{nome}' salvo no banco com sucesso!"
    end
end
