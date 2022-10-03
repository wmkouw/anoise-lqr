using Revise
using LinearAlgebra
using Distributions
using Rocket
using GraphPPL
using ReactiveMP
using Plots
default(label="", margin=10Plots.pt)

# Define system structure
mutable struct PositioningSystem

    # 3D coordinates
    state :: Vector{Float64}
    
    # Load
    mass :: Float64

    # Measurement noise variance
    mnoise_var :: Float64

    PositioningSystem(state, mass, mnoise_var) = new(state, mass, mnoise_var)
end

# Mass of object
mass = 2.0 # kg

# Measurement noise
mnoise_var = 0.01

# Time scales
Δt = 0.01   # seconds
T = 1       # seconds
timesteps = range(0, T, step=Δt)

# Define system in initial state
system = PositioningSystem(zeros(6), mass, mnoise_var)

# System dynamics
function move!(system::PositioningSystem, force::Vector{Float64}; σ::Float64 = 1.0, Δt::Float64 = 1.0)

    # State transition matrix    
    A = [I(3)     Δt*I(3); 
         zeros(3,3)  I(3)]

    # Control matrix
    B = [zeros(3,3); I(3)*Δt/system.mass] 

    # Observation matrix
    C = [I(3) zeros(3,3)]

    # Update system state
    system.state = A*system.state + B*force

    # Generate observations
    observations = C*system.state + system.mnoise_var*randn(3)
end

# Generate force
force = cat([[cos.(k/T*2π), sin.(k/T*2π), 0.0] for k in timesteps]..., dims=2)

# Hold states
sensor = cat([move!(system, force[:,k], Δt=Δt) for (k,t) in enumerate(timesteps)]..., dims=2)

# Visualize
p101 = plot(timesteps, force[1,:], label="force x")
p102 = plot(timesteps, force[2,:], label="force y")
p201 = scatter(sensor[1,:], sensor[2,:], xlabel="x coordinate", ylabel="y coordinate")
plot(p101, p102, p201, layout=(3,1), size=(500,1000))
