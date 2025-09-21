require "httparty"
require "./formatarUrl.rb"
require "erb"
require "./bancoDeDados.rb"

# a api que estou utilizando é essa https://animechan.io/

class BuscarAnime
    UrlBase = "https://api.animechan.io/v1"

    def initialize
        @formatar = FormatarUrl.new
        @db = BancoDeDados.new
        @db.criar_tabela
    end

    def buscar_anime_pelo_nome(nomeDoAnime)
        nomeFormatado = ERB::Util.url_encode(nomeDoAnime)
        resposta = HTTParty.get("#{UrlBase}/anime/#{nomeFormatado}")

        case resposta.code

        when 200
            resposta = resposta.parsed_response

            if resposta['status'] == 'success' and resposta['data']
                data = resposta['data']
                nome = data['name']
                episodios = data['episodeCount']
                sinopse = data['summary']

                puts "\n\n\n"
                puts "Nome do anime: #{nome}\n\n"
                puts "Numero de episodios: #{episodios}\n\n"
                puts "Sinopse original (sem tradução): #{sinopse}\n\n"

                consumirApiTraducao = @formatar.retorna_url_formatada(sinopse)
                respostaApiTraducao = HTTParty.get(consumirApiTraducao)
                
                if respostaApiTraducao.code == 200
                    traducao = respostaApiTraducao.parsed_response['translation']
                    puts "Sinopse traduzida: #{traducao}\n\n"
                end

                @db.salvar_anime(nome, episodios, sinopse, traducao)
            end
        when 429
            puts "Muitas tentativas de buscar anime, tente novamente em 1 hora. Código: #{resposta.code}"
        else
            puts "Erro ao buscar o anime #{nomeDoAnime}, verifique se não há erros de digitação. Código: #{resposta.code}"
        end
    end
end

print "Digite o nome do anime: "
entrada = gets.chomp
buscarAnime = BuscarAnime.new
buscarAnime.buscar_anime_pelo_nome(entrada)
