require 'erb'

class FormatarUrl
  URL_BASE = "https://lingva.ml/api/v1/en/pt/"

  def retorna_url_formatada(texto)
    formatado = ERB::Util.url_encode(texto_single_line)
    "#{URL_BASE}#{formatado}"
  end
end
