class_name Enemy
extends CharacterBody2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var enemy_idle_state: EnemyIdleState = $FiniteStateMachine/EnemyIdleState
@onready var enemy_chase_state: EnemyChaseState = $FiniteStateMachine/EnemyChaseState
@onready var chase_end_timer: Timer = $ChaseEndTimer
@onready var enemy_search_state: EnemySearchState = $FiniteStateMachine/EnemySearchState
@onready var enemy_attack_state: EnemyAttackState = $FiniteStateMachine/EnemyAttackState
@onready var hurt_box: Area2D = $HurtBox

var max_speed = 400.0
var acceleration =max_speed *1.5
var target:Player = null
var last_known_pos = null
var attack_power = 10
var knockback_strength = 500
func _ready():
	target = Global.player
	enemy_idle_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_search_state))
	enemy_chase_state.in_range.connect(fsm.change_state.bind(enemy_attack_state))
	
	enemy_search_state.search_failed.connect(fsm.change_state.bind(enemy_idle_state))
	enemy_search_state.search_succeeded.connect(fsm.change_state.bind(enemy_chase_state))
	
	enemy_attack_state.player_out_of_range.connect(fsm.change_state.bind(enemy_chase_state))
	print_tree_pretty()
func _physics_process(delta: float) -> void:
	move_and_slide()

func attack():
	target.take_damage(attack_power,self,knockback_strength)
