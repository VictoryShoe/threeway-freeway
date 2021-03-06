extends StreamPlayer

signal beat
signal role_switch

var beat_interval = 60.0/127.0
var timer = 0
var beat_cnt = 0
var beats_per_change = 8
var roles = []

func _ready():
	self.play()
	set_process(true)

func _process(delta):
	if roles.size() == 0:
		randomize_roles()
	else:	
		timer += delta
		if timer >= beat_interval:
			timer = timer - beat_interval
			beat_cnt += 1
			
			emit_signal("beat", beat_cnt)
			
			if beat_cnt >= beats_per_change:
				beat_cnt = 0
				randomize_roles()

func randomize_roles():
	var state = randi()%7+1
	if state == 1:
		roles = ['turning', 'accelerating', 'shooting']
	elif state == 2:
		roles = ['turning', 'shooting', 'accelerating']
	elif state == 3:
		roles = ['accelerating', 'shooting', 'turning']
	elif state == 4:
		roles = ['accelerating', 'turning', 'shooting']
	elif state == 5:
		roles = ['shooting', 'turning', 'accelerating']
	elif state == 6:
		roles = ['shooting', 'accelerating', 'turning']
	else:
		roles = ['turning', 'accelerating', 'shooting']
	
	emit_signal("role_switch", roles[0], roles[1], roles[2])
