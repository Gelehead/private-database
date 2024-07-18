using Agents
using Random
using LinearAlgebra
using StaticArrays
using CairoMakie

# Define agent structure
mutable struct Bird <: AbstractAgent
    id::Int
    pos::NTuple{2, Float64}
    vel::SVector{2, Float64}
    speed::Float64
    cohere_factor::Float64
    separation::Float64
    separate_factor::Float64
    match_factor::Float64
    visual_distance::Float64
end

# Initialize model
function initialize_model(;
    n_birds = 100,
    speed = 1.5,
    cohere_factor = 0.1,
    separation = 2.0,
    separate_factor = 0.25,
    match_factor = 0.04,
    visual_distance = 5.0,
    extent = (100, 100),
    seed = 42,
)
    space2d = ContinuousSpace(extent; spacing = visual_distance / 1.5)
    rng = Random.MersenneTwister(seed)

    model = ABM(Bird, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())
    for i in 1:n_birds
        pos = (rand(rng, 1:extent[1]), rand(rng, 1:extent[2]))
        vel = rand(rng, SVector{2, Float64}) * 2 .- 1
        bird = Bird(i, pos, vel, speed, cohere_factor, separation, separate_factor, match_factor, visual_distance)
        add_agent!(bird, model)
    end
    return model
end

# Define agent behavior
function agent_step!(bird, model)
    neighbor_ids = nearby_ids(bird, model, bird.visual_distance)
    N = 0
    match = separate = cohere = SVector(0.0, 0.0)
    for id in neighbor_ids
        N += 1
        neighbor = model[id]
        heading = neighbor.pos .- bird.pos

        cohere += heading
        if norm(heading) < bird.separation
            separate -= heading
        end
        match += neighbor.vel
    end
    N = max(N, 1)
    cohere = cohere / N * bird.cohere_factor
    separate = separate / N * bird.separate_factor
    match = match / N * bird.match_factor

    bird.vel += cohere + separate + match
    bird.vel /= norm(bird.vel)
    bird.pos += bird.vel * bird.speed
    wraparound!(bird, model)
end

# Plotting the flock

CairoMakie.activate!()

const bird_polygon = Makie.Polygon(Point2f[(-1, -1), (2, 0), (-1, 1)])
function bird_marker(b::Bird)
    φ = atan(b.vel[2], b.vel[1])
    rotate_polygon(bird_polygon, φ)
end

model = initialize_model()
figure = abmplot(model; agent_marker = bird_marker)
figure

# Create a video
abmvideo(
    "flocking.mp4", model;
    agent_marker = bird_marker,
    framerate = 20, frames = 150,
    title = "Flocking"
)
