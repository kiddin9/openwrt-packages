local kalman = require("kalman_lib")
local matrix = require("matrix_lib")

-- Test the example of a train moving along a 1-d track
function test_train()
    local k = kalman.create(2, 1)
    -- The train state is a 2d vector containing position and velocity.
    -- Velocity is measured in position units per timestep units.
    k.state_transition = matrix.set(k.state_transition, 1.0, 1.0,
                                                        0.0, 1.0)
    -- We only observe position
    k.observation_model = matrix.set(k.observation_model, 1.0, 0.0)
    -- The covariance matrices are blind guesses
    k.process_noise_covariance = matrix.set_identity(k.process_noise_covariance)
    k.observation_noise_covariance = matrix.set_identity(k.observation_noise_covariance)
    -- Our knowledge of the start position is incorrect and unconfident
    local deviation = 1000.0
    k.state_estimate = matrix.set(k.state_estimate, 10 * deviation)
    k.estimate_covariance = matrix.set_identity(k.estimate_covariance)
    k.estimate_covariance = matrix.scale(k.estimate_covariance, deviation * deviation)

    for i = 1, 10 do
        k.observation = matrix.set(k.observation, i)
        k = kalman.update(k)
    end


    print("estimated position: " .. tostring(k.state_estimate[1][1]))
    print("estimated position: " .. tostring(k.state_estimate[2][1]))

end

test_train()
print("OK")