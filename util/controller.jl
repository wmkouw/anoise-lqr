using LinearAlgebra

mutable struct Controller

    # Parameters
    u :: Vector{Float64}

end

defController(; u=zeros(6)) = Controller(u)


function LQR(system::PositioningSystem, setpoint::Vector{Float64}; T::Int64 = 10)



    u_k = -K*(system.state - setpoint)
end