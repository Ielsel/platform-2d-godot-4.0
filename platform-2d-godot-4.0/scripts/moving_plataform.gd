# Extensão do nó principal
extends Node2D

# constante de delay
const wait_duration := 1.0

@onready var platform := $platform as AnimatableBody2D # O objeto vai iniciar junto com o jogo

# @export vai permitir a configuração das variáveis
@export var move_speed := 3.0 # Velocidade da plataforma
@export var distance := 192 # Distância que vai ser percorrida
@export var move_horizontal := true # Variável de controle do sentido de movimento

var follow := Vector2.ZERO # Variável que guarda o valor de destino, iniciando em (0,0)
var platform_center := 16 # Vai calcular o centro do tile

# Inicío do objeto na cena
func _ready() -> void:
	move_platform() # Chamando a função de movimento

# Função chamada a cada frame
func _physics_process(_delta: float) -> void:
	# Move suavemente a plataforma em direção à posição de destino (`follow`)
	platform.position = platform.position.lerp(follow, 0.5) 

# Função de movimento da plataforma
func move_platform():
	# Verifica o sentido do movimento da plataforma, se é horizontal ou vertical
	var move_direction = Vector2.RIGHT * distance if move_horizontal else Vector2.UP * distance
	# Calcula a duração que a plataforma levará para percorrer a distância definida
	var duration = move_direction.length() / float(move_speed * platform_center)
	
	# Criação de um Tween
	# Cria um tween que vai repetir para sempre, com movimento linear e aceleração suave no começo e fim
	var platform_tween = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# Anima a movimentação de ida da plataforma, começando após um delay
	platform_tween.tween_property(self, "follow", move_direction, duration).set_delay(wait_duration)
	# Anima a movimentação de volta da plataforma, começando após um delay um pouco maior
	platform_tween.tween_property(self, "follow", Vector2.ZERO, duration).set_delay(duration + wait_duration * 2)
