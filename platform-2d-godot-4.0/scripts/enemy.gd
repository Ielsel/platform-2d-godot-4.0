extends CharacterBody2D

const SPEED = 50.0 # Velocidade do inimigo

# Salvando o wall detector em uma variável
@onready var wall_detector := $Wall_detector as RayCast2D
# Salvando a textura na variável
@onready var texture := $Texture as Sprite2D
@onready var anim := $Anim as AnimationPlayer

var direction := -1 # O inimigo vai começar andando pra esquerda

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * _delta

	if wall_detector.is_colliding(): # Se o inimigo colidir
		direction *= -1 # Direção multiplicado por -1 (vai fazer ir para a direita)
		wall_detector.scale.x *= -1 # Muda a posição do Raycast pra colidir do outro lado
		
	# Verificando a direção pra mudar o lado do sprite
	if direction == 1:
		texture.flip_h = true
	else:
		texture.flip_h = false

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = direction * SPEED * _delta

	move_and_slide()


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		queue_free()
		
		
