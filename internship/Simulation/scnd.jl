using Agents
using Plots

# Define agent structures
mutable struct Prey <: AbstractAgent
    id::Int
    pos::Tuple{Int, Int}
    energy::Int
end

mutable struct Predator <: AbstractAgent
    id::Int
    pos::Tuple{Int, Int}
    energy::Int
end

# Initialize model
function initialize_model(num_prey::Int, num_predators::Int, grid_size::Int)
    space = Grid(grid_size, grid_size; periodic = false)
    model = ABM(Union{Prey, Predator}, space)
    
    for i in 1:num_prey
        pos = (rand(1:grid_size), rand(1:grid_size))
        add_agent!(model, Prey(i, pos, 5))
    end
    
    for i in 1:num_predators
        pos = (rand(1:grid_size), rand(1:grid_size))
        add_agent!(model, Predator(i + num_prey, pos, 5))
    end
    
    return model
end

# Define agent behavior
function prey_step!(agent, model)
    new_pos = rand(nearby_positions(agent.pos, model, moore=true))
    move_agent!(agent, new_pos, model)
    agent.energy -= 1
end

function predator_step!(agent, model)
    prey_nearby = [a for a in nearby_agents(agent, model) if a isa Prey]
    if !isempty(prey_nearby)
        prey = rand(prey_nearby)
        agent.pos = prey.pos
        kill_agent!(prey, model)
        agent.energy += 5
    else
        new_pos = rand(nearby_positions(agent.pos, model, moore=true))
        move_agent!(agent, new_pos, model)
        agent.energy -= 1
    end
end

function agent_step!(agent, model)
    if agent isa Prey
        prey_step!(agent, model)
    elseif agent isa Predator
        predator_step!(agent, model)
    end
end

# Run simulation
model = initialize_model(100, 10, 20)

for step in 1:100
    step!(model, agent_step!, 1)
    model.agents = filter(a -> a.energy > 0, model.agents)
end

# Visualization
function plot_agents(model)
    prey_pos = [agent.pos for agent in allagents(model) if agent isa Prey]
    predator_pos = [agent.pos for agent in allagents(model) if agent isa Predator]
    
    prey_x = [pos[1] for pos in prey_pos]
    prey_y = [pos[2] for pos in prey_pos]
    predator_x = [pos[1] for pos in predator_pos]
    predator_y = [pos[2] for pos in predator_pos]
    
    scatter(prey_x, prey_y, label="Prey", xlim=(1, 20), ylim=(1, 20))
    scatter!(predator_x, predator_y, label="Predators", xlim=(1, 20), ylim=(1, 20))
end

plot_agents(model)
