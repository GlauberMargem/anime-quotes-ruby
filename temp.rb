require "erb"

class FormatarTexto

    def formatar_texto(texto)
        texto = ERB::Util.url_encode(texto)
        puts "texto formatado: #{texto}"
    end
end

print "digite o texto: "
texto = gets.chomp
formatarTexto = FormatarTexto.new
formatarTexto.formatar_texto(texto)