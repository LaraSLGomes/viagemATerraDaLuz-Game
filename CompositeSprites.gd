extends RefCounted
class_name CompositeSprites
## Catálogo central dos spritesheets animados do avatar adolescente.
## Organiza as texturas por sexo e por estilo de cabelo.

const SPRITESHEETS: Dictionary = {
	"menino": {
		"curto": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCurto-menino.png"),
		"longo": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloLongo-menino.png"),
		"ondulado": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloOndulado-menino.png"),
		"crespo_baixo": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCrespoCurto-menino.png"),
		"crespo_volumoso": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCrespoGrande-menino.png")
	},
	"menina": {
		"curto": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCurto-menina.png"),
		"longo": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloLongo-menina.png"),
		"ondulado": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloOndulado-menina.png"),
		"crespo_baixo": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCrespoCurto-menina.png"),
		"crespo_volumoso": preload("res://assets/Personagens/customizacao/spritesheets_animados/cabeloCrespoGrande-menina.png")
	}
}

static func obter_spritesheet(sexo: String, estilo_cabelo: String) -> Texture2D:
	var sexo_key: String = "menina" if (sexo == "feminina" or sexo == "menina") else "menino"
	var estilo_key: String = estilo_cabelo.to_lower().strip_edges()
	
	# Normalização de nomes de estilos
	match estilo_key:
		"curto", "curto_desfiado", "curto_espigado":
			estilo_key = "curto"
		"longo", "liso_longo":
			estilo_key = "longo"
		"ondulado", "ondulado_longo":
			estilo_key = "ondulado"
		"crespo_baixo", "afro_curto", "crespo_curto":
			estilo_key = "crespo_baixo"
		"crespo_volumoso", "afro_volumoso", "crespo_grande":
			estilo_key = "crespo_volumoso"
		_:
			if not SPRITESHEETS[sexo_key].has(estilo_key):
				estilo_key = "curto"
	
	if SPRITESHEETS.has(sexo_key) and SPRITESHEETS[sexo_key].has(estilo_key):
		return SPRITESHEETS[sexo_key][estilo_key]
		
	return SPRITESHEETS["menino"]["curto"]
