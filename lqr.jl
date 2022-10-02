using Revise
using LinearAlgebra
using GLMakie

# Define system structure
mutable struct PositioningSystem

    # 3D coordinates
    state :: Vector{Float64}
    
    # Load
    mass :: Float64

    PositioningSystem(state, mass) = new(state, mass)
end

# Mass of object
mass = 2.0 # kg

# Time scales
Δt = 0.01   # seconds
T = 3       # seconds
timesteps = range(0, T, step=Δt)

# Define system in initial state
system = PositioningSystem(zeros(6), mass)

# System dynamics
function move!(system::PositioningSystem, force::Vector{Float64}; Δt::Float64 = 1.0)

    # State transition matrix    
    A = [I(3)     Δt*I(3); 
         zeros(3,3)  I(3)]

    # Control matrix
    B = [zeros(3,3); I(3)*Δt/system.mass] 

    system.state = A*system.state + B*force
end

# Generate force
force = cat([[cos.(k/T*2π), sin.(k/T*2π), 0.0] for k in timesteps]..., dims=2)

# Hold states
states = cat([move!(system, force[:,k], Δt=Δt) for (k,t) in enumerate(timesteps)]..., dims=2)

# Init figure
fig = Figure(; resolution=(1200, 600))
ax1 = Axis(fig[1, 1])
ax2 = Axis(fig[1, 2])
ax3 = Axis(fig[1, 3])
ax4 = Axis(fig[2, 1])
ax5 = Axis(fig[2, 2])
ax6 = Axis(fig[2, 3])

# Plot forces
plot!(ax1, timesteps, force[1,:], label="force x")
plot!(ax2, timesteps, force[2,:], label="force y")
plot!(ax3, timesteps, force[3,:], label="force z")

# Plot states
plot!(ax4, timesteps, states[1,:], label="position x")
plot!(ax5, timesteps, states[2,:], label="position y")
plot!(ax6, timesteps, states[3,:], label="position z")
