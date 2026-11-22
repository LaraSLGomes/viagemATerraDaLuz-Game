extends Node
## Armazenamento global e persistência do estado do jogador e progresso da aventura.

# Dados básicos do personagem
var nome_personagem: String = "Bento"
var sexo: String = "masculino" # "masculino" ou "feminina"
var estilo_cabelo: String = "curto" # "curto", "longo", "ondulado", "crespo_baixo", "crespo_volumoso"

# Índices selecionados na tela de criação
var idx_pele: int = 1
var idx_cabelo_cor: int = 1
var idx_cabelo_estilo: int = 0
var idx_blusa: int = 0
var idx_calca: int = 0
var idx_sapato: int = 0
var idx_mochila: int = 0

# Cores selecionadas (6 cores para o Shader de Palette Swap)
var cor_pele: Color = Color(0.92, 0.76, 0.62, 1.0)
var cor_cabelo: Color = Color(0.22, 0.14, 0.08, 1.0)
var cor_blusa: Color = Color(0.85, 0.15, 0.15, 1.0)
var cor_calca: Color = Color(0.15, 0.35, 0.75, 1.0)
var cor_roupa: Color = Color(0.85, 0.15, 0.15, 1.0) # Retrocompatibilidade
var cor_sapato: Color = Color(0.95, 0.85, 0.20, 1.0)
var cor_mochila: Color = Color(0.20, 0.70, 0.25, 1.0)

# Caminhos exatos das texturas (se necessário para retrocompatibilidade)
var textura_corpo: String = ""
var textura_cabelo: String = ""
var textura_blusa: String = ""
var textura_calca: String = ""
var textura_sapato: String = ""
var textura_mochila: String = ""

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
