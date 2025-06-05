# Extensão do node principal
extends CharacterBody2D

# Declarando variáveis
const SPEED = 300.0 # Velocidade do player
const JUMP_VELOCITY = -400.0 # Velocidade do pulo
var is_jumping : bool = false # Estado de pulo

# Referência ao nó de animação (AnimatedSprite2D), inicializada após o nó estar na árvore
@onready var animation := $Anim as AnimatedSprite2D

# Função de gestão de movimentação
func _physics_process(delta: float) -> void: # Função chamada a cada frame de física
	# Aplicar gravidade se o jogador não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

 	# Verificando se o player apertou a tecla de pulo e está no chão
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY # Incrementando velocidade no eixo y, que vai fazer o player pular
		is_jumping = true # Mudando o estado de pulo para true
	elif is_on_floor(): # Se só estiver no chão
		is_jumping = false

	# Captura da direção horizontal, -x e +x
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction: # Se houver direção (tecla pressionada)
		velocity.x = direction * SPEED # Aplica velocidade
		animation.scale.x = direction # Muda o eixo horizontal da animação
		if !is_jumping: # Se não estiver pulando
			animation.play("Run") # Animação de corrida
	elif is_jumping: # Se estiver pulando
		animation.play("Jump") # Animação de pulo
	else: # Se não estiver fazendo nada
		# Suaviza a desaceleração quando nenhuma tecla é pressionada
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		animation.play("Idle") # Animação Idle (parado)

	move_and_slide() # Move o personagem de acordo com a física
