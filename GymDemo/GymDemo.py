import gym

env = gym.make("Breakout-ram-v4", render_mode = "human")
observation = env.reset()

for _ in range(1000):
  action = env.action_space.sample() # your agent here (this takes random actions)
  observation, reward, done, info = env.step(action)

  if done:
    observation = env.reset()
  
env.close()