using Revise
using LinearAlgebra
using Distributions
using Rocket
using GraphPPL
using ReactiveMP
using Plots
default(label="", margin=10Plots.pt)

include("util/system.jl")
include("util/estimator.jl")
include("util/controller.jl")

# Time scales
T = 1       # seconds
Δt = 0.01   # seconds
tk = range(0, T, step=Δt)

# Mass of object
mass = 2.0 # kg

# Dynamics
A = [I(3)       Δt*I(3); 
     zeros(3,3)    I(3)]
B = [zeros(3,3); 
     I(3)*Δt/mass]
C = [I(3) zeros(3,3)]

# Noise covariances
Qc = [1e-2, 1e-2, 1e-2]
Rc = [1e-3, 1e-3, 1e-3]

# Define system in initial state
system = defPositioningSystem(state = zeros(6), 
                              mass = mass,
                              A = A,
                              B = B,
                              Qc = Qc,
                              Rc = Rc,
                              Δt = Δt)

# Generate force
force = cat([[cos.(k/T*2π), sin.(k/T*2π), 0.0] for k in tk]..., dims=2)

# Hold states
sensor = cat([move!(system, force[:,k], Δt=Δt) for (k,t) in enumerate(tk)]..., dims=2)

# Set points
sets = cat([[cos.(π), sin.(π), 0.0] for k in tk]..., dims=2)

# Visualize
p101 = plot(timesteps, force[1,:], label="force x")
p102 = plot(timesteps, force[2,:], label="force y")
p201 = scatter(sensor[1,:], sensor[2,:], xlabel="x coordinate", ylabel="y coordinate")
plot(p101, p102, p201, layout=(3,1), size=(500,1000))
