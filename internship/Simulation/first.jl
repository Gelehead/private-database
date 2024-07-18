using Agents
using Plots

# Define agent structure
mutable struct ContinuousAgent <: AbstractAgent
    id::Int
    pos::NTuple{2, Float64}  # position (x, y)
    vel::NTuple{2, Float64}  # velocity (vx, vy)
end

# Initialize model
function initialize_model(num_agents::Int)
    space = ContinuousSpace((0.0, 100.0), (0.0, 100.0); periodic = false)
    model = ABM(ContinuousAgent, space)
    
    for i in 1:num_agents
        pos = (rand(Uniform(0, 100)), rand(Uniform(0, 100)))
        vel = (randn(), randn())
        add_agent!(model, ContinuousAgent(i, pos, vel))
    end

    return model
end

# Update rules for agents
function agent_step!(agent, model)
    agent.pos = (agent.pos[1] + agent.vel[1], agent.pos[2] + agent.vel[2])
    agent.pos = clamp.(agent.pos, 0.0, 100.0)
end

# Plotting function
function plot_agents(model)
    x = [agent.pos[1] for agent in allagents(model)]
    y = [agent.pos[2] for agent in allagents(model)]
    scatter(x, y, xlim=(0, 100), ylim=(0, 100), xlabel="x", ylabel="y", title="Continuous Agent Simulation")
end

# Run simulation and plot results
model = initialize_model(50)

for step in 1:100
    step!(model, agent_step!, 1)
end

plot_agents(model)
