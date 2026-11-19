extends Node
## Armazenamento global e persistência do estado do jogador e progresso da aventura.

# Dados básicos do personagem
var nome_personagem: String = "Bento"
var sexo: String = "masculino" # "masculino" ou "feminina"
var estilo_cabelo: String = "curto" # "curto" ou "longo"

# Índices selecionados na tela de criação (-1 significa sem a peça ou padrão)
var idx_pele: int = 1
var idx_cabelo_cor: int = 1
var idx_blusa: int = -1
var idx_calca: int = -1
var idx_sapato: int = 0
var idx_mochila: int = 0

# Cores selecionadas
var cor_pele: Color = Color(0.92, 0.76, 0.62, 1.0)
var cor_cabelo: Color = Color(0.22, 0.14, 0.08, 1.0)
var cor_roupa: Color = Color(0.24, 0.45, 0.72, 1.0) # Retrocompatibilidade
var cor_blusa: Color = Color(0.24, 0.45, 0.72, 1.0)
var cor_calca: Color = Color(0.2, 0.35, 0.55, 1.0)
var cor_sapato: Color = Color(0.15, 0.15, 0.16, 1.0)
var cor_mochila: Color = Color(0.20, 0.32, 0.65, 1.0)

# Caminhos exatos das texturas selecionadas
var textura_corpo: String = "res://assets/Personagens/customizacao/CANVAS_180x360/corpos/corpo_masculino.png"
var textura_cabelo: String = "res://assets/Personagens/customizacao/CANVAS_180x360/cabelos/curto_desfiado.png"
var textura_blusa: String = ""
var textura_calca: String = ""
var textura_sapato: String = "res://assets/Personagens/customizacao/CANVAS_180x360/sapatos/tenis_preto.png"
var textura_mochila: String = "res://assets/Personagens/customizacao/CANVAS_180x360/mochilas/mochila_azul_marinho.png"

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
