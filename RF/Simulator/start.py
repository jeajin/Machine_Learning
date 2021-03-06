from simglucose.controller.pid_ctrller import PIDController
from simglucose.controller.qlearnctrller import QLController
from simglucose.controller.dqlearnctrller import DQLController
from simglucose.simulation.user_interface import simulate

Qcontroller = PIDController()
s = simulate(controller=Qcontroller)

# Qcontroller = QLController(actions=3)
# s = simulate(controller=Qcontroller)

# DQcontroller = DQLController(state_size=1, action_size=1, episode=10)
# s = simulate(controller=DQcontroller)