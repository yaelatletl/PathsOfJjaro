extends Component

var myRID 

func _ready():
	myRID = NavigationServer.agent_create()

func _physics_process(delta):
	NavigationServer.agent_set_velocity(myRID, actor.linear_velocity)