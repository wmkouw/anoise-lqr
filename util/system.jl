using LinearAlgebra

mutable struct PositioningSystem

    # 3D coordinates
    state :: Vector{Float64}
    
    # Load of object 
    mass :: Float64

    # System dynamics matrices
    A :: Matrix{Float64}
    B :: Matrix{Float64}
    C :: Matrix{Float64}
    Q :: Matrix{Float64}
    R :: Matrix{Float64}
end

function defPositioningSystem(; state = zeros(6), 
                                mass = 1.0, 
                                A = diagm(ones(6)),
                                B = [zeros(3,3); diagm(ones(3))],
                                C = [diagm(ones(3)) zeros(3,3)], 
                                Qc = ones(3),
                                Rc = ones(3),
                                Δt = 1.0)

    # Process noise covariance matrix
    Q = [diagm(Qc)*Δt^3/3    diagm(Qc)*Δt^2/2;
         diagm(Qc)*Δt^2/2    diagm(Qc)*Δt]
    
    # Measurement noise covariance matrix
    R = diagm(Rc)

    return PositioningSystem(state, mass, A,B,C,Q,R)
end 

function move!(system::PositioningSystem, force::Vector{Float64})
    "System dynamics"

    # State transition
    system.state = system.A*system.state + system.B*force + cholesky(system.Q).U*randn(6)

    # Generate observations
    observations = system.C*system.state + cholesky(system.R).U*randn(3)
end
