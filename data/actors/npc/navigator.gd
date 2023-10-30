extends Component

var myRID 

func _ready():
	myRID = NavigationServer3D.agent_create()

func _physics_process(delta):
	NavigationServer3D.agent_set_velocity(myRID, actor.linear_velocity)