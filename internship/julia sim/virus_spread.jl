using Agents
using Random
using LinearAlgebra
using CairoMakie
using GeometryBasics

# Define the Individual agent
@agent struct Individual(ContinuousAgent{2, Float64})
    state::Symbol  # :susceptible, :infected, or :recovered
    infection_time::Int  # Time since infection
end

# Parameters
const RECOVERY_TIME = 10
const INFECTION_RADIUS = 2.0
const INITIAL_INFECTED = 5
const MOVEMENT_SPEED = 1.0

# Initialize the model
function initialize_model(;
    n_individuals = 100,
    extent = (100, 100),
    seed = 42,
)
    space2d = ContinuousSpace(extent; spacing = 1.0)
    rng = Random.MersenneTwister(seed)

    model = StandardABM(Individual, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())
    
    # Add individuals to the model
    for _ in 1:n_individuals
        pos = rand(rng, 2) .* extent
        add_agent!(
            model,
            pos,
            :susceptible,
            0
        )
    end

    # Infect some individuals initially
    infected_indices = rand(rng, 1:n_individuals, INITIAL_INFECTED)
    for idx in infected_indices
        agent = model[idx]
        agent.state = :infected
        agent.infection_time = 0
    end

    return model
end

# Define the agent step function
function agent_step!(individual, model)
    if individual.state == :infected
        individual.infection_time += 1
        if individual.infection_time >= RECOVERY_TIME
            individual.state = :recovered
        end
    end

    # Check for infection
    if individual.state == :susceptible
        for neighbor in nearby_agents(individual, model, INFECTION_RADIUS)
            if neighbor.state == :infected
                individual.state = :infected
                individual.infection_time = 0
                break
            end
        end
    end

    # Move the agent
    move_agent!(individual, model, MOVEMENT_SPEED)
end

# Define the individual marker for plotting
function individual_marker(ind::Individual)
    color = ind.state == :infected ? :red : (ind.state == :recovered ? :blue : :green)
    return (ind.pos, color)
end

# Initialize the model
model = initialize_model()

# Function to extract individual markers from the model
function extract_individual_markers(model)
    return [individual_marker(agent) for agent in allagents(model)]
end

# Create the figure and axis
fig = Figure(resolution = (800, 800))
ax = Axis(fig[1, 1], title = "Virus Spread Simulation")

# Plot the initial state
markers = scatter!(ax, [p for (p, _) in extract_individual_markers(model)]; markersize = 10, color = [c for (_, c) in extract_individual_markers(model)])

# Function to update the plot with new data
function update_plot!(markers, model)
    positions = [p for (p, _) in extract_individual_markers(model)]
    colors = [c for (_, c) in extract_individual_markers(model)]
    markers.positions = positions
    markers.colors = colors
    fig[1, 1] # Force re-render
end

# Function to step the model and update the plot
function update_fn!(model, markers)
    step!(model, 1)
    update_plot!(markers, model)
end

# Record the simulation
record(fig, "virus_spread.mp4", 1:150) do i
    update_fn!(model, markers)
    sleep(0.1)  # Pause to visualize changes
end
