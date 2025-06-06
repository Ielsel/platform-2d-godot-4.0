# Extensão do node principal
extends CharacterBody2D

# Declarando variáveis
const SPEED = 100.0 # Velocidade do player
const JUMP_VELOCITY = -300.0 # Velocidade do pulo
var is_jumping : bool = false # Estado de pulo
var player_life := 5
var knockback_vector := Vector2.ZERO
# Captura da direção horizontal, -x e +x
var direction # Declarando variável que vai ser usada para a movimentação
var is_hurted := false # Variável de estado hurt

# Referência ao nó de animação (AnimatedSprite2D), inicializada após o nó estar na árvore
@onready var animation := $Anim as AnimatedSprite2D
@onready var remote_transform := $Remote as RemoteTransform2D # Referência ao node RemoteTransform2D/Remote

# Função de gestão de movimentação
func _physics_process(delta: float) -> void: # Função chamada a cada frame de física
	direction = Input.get_axis("ui_left", "ui_right")
	# Aplicar gravidade se o jogador não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

 	# Verificando se o player apertou a tecla de pulo e está no chão
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY # Incrementando velocidade no eixo y, que vai fazer o player pular
		is_jumping = true # Mudando o estado de pulo para true
	elif is_on_floor(): # Se só estiver no chão
		is_jumping = false

	if direction: # Se houver direção (tecla pressionada)
		velocity.x = direction * SPEED # Aplica velocidade
		animation.scale.x = direction # Muda o eixo horizontal da animação
	else: # Se não estiver fazendo nada
		# Suaviza a desaceleração quando nenhuma tecla é pressionada
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide() # Move o personagem de acordo com a física
	_set_state()

func _on_hurtbox_body_entered(_body: Node2D) -> void: # Signal ativado se o player entrar em colisão
	#if body.is_in_group("enemies"): # Se o corpo colidido for do grupo enemies
		#queue_free() # morre
	if player_life <= 1:
		queue_free()
	else:
		if $Ray_right.is_colliding():
			take_damage(Vector2(-200, -200))
		elif $Ray_left.is_colliding():
			take_damage(Vector2(200, -200))

# Função para o node Remote salvar a posição da câmera atual para a câmera em world
func follow_camera(camera): 
	var camera_path = camera.get_path() # Atribuindo o caminho da câmera na árvore de nós
	remote_transform.remote_path = camera_path # Sincronizando a posição do node Remote com o do câmera
	
# função de dano
func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1 # Decremento de vida
	
	if knockback_force != Vector2.ZERO: # Se o parâmetro de knockback for diferente de 0
		knockback_vector = knockback_force # Atribuindo o valor do parâmetro para a variável
		
		var knockback_tween := get_tree().create_tween() # Criando um tween
		# Efeito de suavização na animação de parada do knockback
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1) # Alterando a propriedade modulate (cor do player) para vermelho
		# Efeito de suavização para retorno à cor original
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
	
	# Alterando pra sprite de dano
	is_hurted = true # Mudando o estado de dano para true
	await get_tree().create_timer(.3).timeout # Criando um timer da animação
	is_hurted = false # Retornando o valor para false/retirando o estado de hurt

# Função pra fazer o toque na tela funcionar
func _input(event):
	if event is InputEventScreenTouch:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			is_jumping = true
		elif is_on_floor():
			is_jumping = false

# Função de estado do player pra trocar os sprites
func _set_state():
	var state = "Idle"
	
	if !is_on_floor():
		state = "Jump"
	elif direction != 0:
		state = "Run"
	
	if is_hurted:
		state = "Hurt"
	
	if animation.name != state:
		animation.play(state)
