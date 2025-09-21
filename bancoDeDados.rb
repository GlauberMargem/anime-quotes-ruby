require "pg"

class Database
    def initialize
        @conn = PG.connect(dbname: "bancoDeAnimes", user: "postgres", password: "postgres")
    end

    def criar_tabela
    @conn.exec <<-SQL
        CREATE TABLE IF NOT EXISTS animes (
            id SERIAL PRIMARY KEY,
            mal_id INTEGER,
            titulo VARCHAR(255),
            status VARCHAR(100),
            episodios INTEGER
        );
    SQL
    end