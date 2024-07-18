using Pkg
Pkg.activate(".")

using Agents


# Agent
@agent Person GridAgent{2} begin
    health :: Int64
    illness_duration :: Int64
end



function initialize(;
    susceptibility = 0.3, 
    illness_duration = 10, 
    grid_dimension = (20, 20),
    total_agents = 400
    )
    
    # environment 
    space = GridSpaceSingle(grid_dimension; periodic = false)

    # model properties as defined in the function parameter
    properties = Dict(
        :susceptibility => susceptibility
        :illness_duration => illness_duration
    )

    model = ABM(Person, space; properties)


    for i in 1:total_agents
        p = Person(i, (1, 1), 0, 0)
        add_agent_single!(p, model)
    end

    # inside the simulation, 1 person is sick
    sick_person = random_agent(model)
    sick_person.health = 1
    return model 
end

model = initialize()

function person_color(p)
    if p.health == 0
        return :blue
    else
        return :redirect_stderr
    
    end
end

person_color


using CairoMakie
fig, ax, abmobs = Agents.abmplot(model;ac = :blue, am = :rect, as = 10)

fig