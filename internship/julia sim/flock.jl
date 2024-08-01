using Agents
using Random, LinearAlgebra
using CairoMakie
using GeometryBasics

# Define the Bird agent
@agent struct Bird(ContinuousAgent{2,Float64})
    speed::Float64
    cohere_factor::Float64
    separation::Float64
    separate_factor::Float64
    match_factor::Float64
    visual_distance::Float64
end

# Initialize the model
function initialize_model(;
    n_birds = 100,
    speed = 1.5,
    cohere_factor = 0.1,
    separation = 2.0,
    separate_factor = 0.25,
    match_factor = 0.04,
    visual_distance = 5.0,
    extent = (200, 200),  # Increase the environment size
    seed = 42,
)
    space2d = ContinuousSpace(extent; spacing = visual_distance / 1.5)
    rng = Random.MersenneTwister(seed)

    model = StandardABM(Bird, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())
    for _ in 1:n_birds
        vel = rand(abmrng(model), SVector{2}) * 2 .- 1
        add_agent!(
            model,
            vel,
            speed,
            cohere_factor,
            separation,
            separate_factor,
            match_factor,
            visual_distance,
        )
    end
    return model
end

# Define the agent step function
function agent_step!(bird, model)
    neighbor_ids = nearby_ids(bird, model, bird.visual_distance)
    N = 0
    match = separate = cohere = (0.0, 0.0)
    
    for id in neighbor_ids
        N += 1
        neighbor = model[id].pos
        heading = get_direction(bird.pos, neighbor, model)

        cohere = cohere .+ heading
        dist = euclidean_distance(bird.pos, neighbor, model)
        if dist < bird.separation
            separate = separate .- (heading / dist^2)  # Increase separation force
        end
        match = match .+ model[id].vel
    end
    
    N = max(N, 1)
    cohere = cohere ./ N .* bird.cohere_factor
    separate = separate .* bird.separate_factor
    match = match ./ N .* bird.match_factor
    
    bird.vel = (bird.vel .+ cohere .+ separate .+ match) ./ 2
    bird.vel = bird.vel ./ norm(bird.vel)
    
    move_agent!(bird, model, bird.speed)
end

# Define the bird marker for plotting
function bird_marker(b::Bird)
    φ = atan(b.vel[2], b.vel[1])
    rot_mat = [cos(φ) -sin(φ); sin(φ) cos(φ)]
    polygon = Point2f[(-0.5, -0.5), (1, 0), (-0.5, 0.5)]  # Smaller bird size
    transformed_polygon = Point2f[(rot_mat * p) + b.pos for p in polygon]
    return GeometryBasics.Polygon(transformed_polygon)
end

# Initialize the model again
model = initialize_model()

# Function to extract bird markers from the model
function extract_bird_markers(model)
    return [bird_marker(agent) for agent in allagents(model)]
end

# Custom abmplot function without unsupported attributes
function custom_abmplot!(ax::Axis, model)
    polygons = extract_bird_markers(model)
    poly!(ax, polygons; color = :blue)
end

# Plotting the flock using custom abmplot function
fig = Figure(resolution = (800, 800))
ax = Axis(fig[1, 1], title = "Flocking Simulation")
custom_abmplot!(ax, model)
display(fig)

# Function to update the model and plot
function update_fn!(model, ax)
    step!(model, 1)
    custom_abmplot!(ax, model)
end

# Function to clear the plot
function clear_plot!(ax)
    empty!(ax)
end

# Record the simulation
record(fig, "flocking.mp4", 1:1000) do i
    clear_plot!(ax)
    update_fn!(model, ax)
end
