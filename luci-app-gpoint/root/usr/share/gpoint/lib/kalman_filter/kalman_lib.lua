 local matrix = require("matrix_lib")

kalman_lib = {}

function kalman_lib.create(state, observation)
	local kalman = {
		timestep = 0, -- K
		-- These parameters define the size of the matrices.
		state_dimension = state,
		observation_dimension = observation,

		-- This group of matrices must be specified by the user.
		state_transition  			  = matrix.create(state, state),             -- F_k
		observation_model 			  = matrix.create(observation, state),       -- H_k
		process_noise_covariance 	  = matrix.create(state, state),             -- Q_k
		observation_noise_covariance  = matrix.create(observation, observation), -- R_k

		-- The observation is modified by the user before every time step.
		observation 				  = matrix.create(observation, 1),           -- z_k

		-- This group of matrices are updated every time step by the filter.
		predicted_state 			  = matrix.create(state, 1), 				 -- x-hat_k|k-1
		predicted_estimate_covariance = matrix.create(state, state), 			 -- P_k|k-1
		innovation 					  = matrix.create(observation, 1), 			 -- y-tilde_k
		innovation_covariance 		  = matrix.create(observation, observation), -- S_k
		inverse_innovation_covariance = matrix.create(observation, observation), -- S_k^-1
		optimal_gain 				  = matrix.create(state, observation), 		 -- K_k
		state_estimate 				  = matrix.create(state, 1), 				 -- x-hat_k|k
		estimate_covariance 		  = matrix.create(state, state), 			 -- P_k|k

		-- This group is used for meaningless intermediate calculations.
		vertical_scratch 			  = matrix.create(state, observation), 
		mall_square_scratch 		  = matrix.create(observation, observation),
		big_square_scratch 			  = matrix.create(state, state)
	}
	return kalman
end

function kalman_lib.predict(kalman)
	kalman.timestep = kalman.timestep + 1
	-- Predict the state
	kalman.predicted_state = matrix.multiply(kalman.state_transition, kalman.state_estimate, kalman.predicted_state)
	-- Predict the state estimate covariance
	kalman.big_square_scratch = matrix.multiply(kalman.state_transition, kalman.estimate_covariance, kalman.big_square_scratch)
	kalman.predicted_estimate_covariance = matrix.multiply_by_transpose(kalman.big_square_scratch, kalman.state_transition, kalman.predicted_estimate_covariance)
	kalman.predicted_estimate_covariance = matrix.add(kalman.predicted_estimate_covariance, kalman.process_noise_covariance, kalman.predicted_estimate_covariance)
	return kalman
end

function kalman_lib.estimate(kalman)
	-- Calculate innovation
	kalman.innovation = matrix.multiply(kalman.observation_model, kalman.predicted_state, kalman.innovation)
	kalman.innovation = matrix.subtract(kalman.observation, kalman.innovation, kalman.innovation)
	-- Calculate innovation covariance
	kalman.vertical_scratch = matrix.multiply_by_transpose(kalman.predicted_estimate_covariance, kalman.observation_model, kalman.vertical_scratch)
	kalman.innovation_covariance = matrix.multiply(kalman.observation_model, kalman.vertical_scratch, kalman.innovation_covariance)
	kalman.innovation_covariance = matrix.add(kalman.innovation_covariance, kalman.observation_noise_covariance, kalman.innovation_covariance)
	-- Invert the innovation covariance.
    -- Note: this destroys the innovation covariance.
    -- TODO: handle inversion failure intelligently.
 	matrix.destructive_invert(kalman.innovation_covariance, kalman.inverse_innovation_covariance)
    -- Calculate the optimal Kalman gain.
    -- Note we still have a useful partial product in vertical scratch
    -- from the innovation covariance.
    kalman.optimal_gain = matrix.multiply(kalman.vertical_scratch, kalman.inverse_innovation_covariance, kalman.optimal_gain)
    -- Estimate the state
    kalman.state_estimate = matrix.multiply(kalman.optimal_gain, kalman.innovation, kalman.state_estimate)
    kalman.state_estimate = matrix.add(kalman.state_estimate, kalman.predicted_state, kalman.state_estimate)
    -- Estimate the state covariance
    kalman.big_square_scratch = matrix.multiply(kalman.optimal_gain, kalman.observation_model, kalman.big_square_scratch)
    kalman.big_square_scratch = matrix.subtract_from_identity(kalman.big_square_scratch)
    kalman.estimate_covariance = matrix.multiply(kalman.big_square_scratch, kalman.predicted_estimate_covariance, kalman.estimate_covariance)
    return kalman
end

function kalman_lib.update(kalman)
	kalman = kalman_lib.predict(kalman)
	kalman = kalman_lib.estimate(kalman)
	return kalman
end

return kalman_lib
