extends Node
## Armazenamento global e persistência do estado do jogador e progresso da aventura.

# Dados de customização do personagem
var nome_personagem: String = "Bento"
var sexo: String = "masculino" # "masculino" ou "feminina"
var estilo_cabelo: String = "curto" # "curto" ou "longo"

var cor_pele: Color = Color(0.92, 0.76, 0.62, 1.0)
var cor_cabelo: Color = Color(0.22, 0.14, 0.08, 1.0)
var cor_roupa: Color = Color(0.24, 0.45, 0.72, 1.0)
var cor_sapato: Color = Color(0.28, 0.2, 0.15, 1.0)
var cor_mochila: Color = Color(0.68, 0.42, 0.2, 1.0)

# Estado de progresso
var fase_atual: String = "museu_introducao"
var slot_ativo: int = 1
var tempo_jogo_segundos: float = 0.0


func _process(delta: float) -> void:
	tempo_jogo_segundos += delta


func obter_tempo_formatado() -> String:
	var total_seg: int = int(tempo_jogo_segundos)
	var horas: int = total_seg / 3600
	var minutos: int = (total_seg % 3600) / 60
	return "%02dh %02dm" % [horas, minutos]
