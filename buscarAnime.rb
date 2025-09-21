require "httparty"
require "./formatarUrl.rb"
require "erb"

# a api que estou utilizando é essa https://animechan.io/

class BuscarAnime
    UrlBase = "https://api.animechan.io/v1"

    def initialize
        @formatar = FormatarUrl.new
    end

    def buscar_anime_pelo_nome(nomeDoAnime)
        nomeFormatado = ERB::Util.url_encode(nomeDoAnime)
        resposta = HTTParty.get("#{UrlBase}/anime/#{nomeFormatado}")

        if resposta.code == 200
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
            end
        if resposta.code == 429
            puts "Muitas tentativas de buscar anime, tente novamente em 1 hora. Código: #{resposta.code}"
        end
        else
            puts "Erro ao buscar o anime #{nomeDoAnime}, verifique se não há erros de digitação. Código: #{resposta.code}"
        end
    end
end

print "Digite o nome do anime: "
entrada = gets.chomp
buscarAnime = BuscarAnime.new
buscarAnime.buscar_anime_pelo_nome(entrada)
