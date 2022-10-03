using LinearAlgebra

mutable struct Estimator

    # Parameters
    m :: Vector{Float64}
    P :: Matrix{Float64}

    # Dynamics
    A :: Matrix{Float64}
    B :: Matrix{Float64}
    C :: Matrix{Float64}
    Q :: Matrix{Float64}
    R :: Matrix{Float64}

end

defEstimator(; m=zeros(6), 
               P=diagm(ones(6)), 
               A=diagm(ones(6)), 
               B=[zeros(3,3); diagm(ones(3))], 
               C=[diagm(ones(3)) zeros(3,3)],
               Q=diagm(ones(6)),
               R=diagm(ones(3))) = Estimator(m,P,A,B,C,Q,R)

function LQE!(estimator::Estimator,
              controller::Controller, 
              observation::Vector{Float64})

    # Prediction
    pred_m = estimator.A*estimator.m + estimator.B*controller.u
    pred_P = estimator.A*estimator.P*estimator.A' + estimator.Q

    # Update
    innovation = observation - estimator.C*pred_m
    S_k = estimator.C*pred_P*estimator.C' + estimator.R
    K_k = pred_P*estimator.C'*inv(S_k)
    estimator.m = pred_m + K_k*innovation
    estimator.P = (diagm(ones(6)) - K_k*estimator.C)*pred_P

    return estimator.m, estimator.P
end