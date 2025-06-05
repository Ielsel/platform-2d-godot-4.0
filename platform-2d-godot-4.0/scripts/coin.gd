extends Area2D

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass

# Função de Signals da colisão com o player
func _on_body_entered(_body: Node2D) -> void:
	$Anim.play("Collect") # Troca a animação para "Collect"

# Função de Signal que ativa após uma animação ser finalizada
func _on_anim_animation_finished() -> void:
	queue_free() # Remove a moeda
