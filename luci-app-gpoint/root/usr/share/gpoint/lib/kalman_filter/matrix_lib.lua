matrix_lib = {}

function matrix_lib.create(rows, cols)
	local matrix = {}
	for i = 1,rows do
	    matrix[i] = {}
		for j = 1,cols do
			matrix[i][j] = 0.0
		end
	end
	return matrix
end

function matrix_lib.print(matrix)
	for i = 1, #matrix do
		for j = 1, #matrix[i] do
			io.write(matrix[i][j] .. " ")
		end
		io.write('\n')
	end
end

function matrix_lib.set(matrix, ...)
    local k = 1
	for i = 1, #matrix do
		for j = 1, #matrix[i] do
			if arg[k] ~= nil then
		    	matrix[i][j] = arg[k]
		    end
		    k = k + 1
		end
    end
	return matrix
end

function matrix_lib.set_identity(matrix)
	for i = 1, #matrix do
		for j = 1, #matrix[i] do
			matrix[i][j] = i == j and 1.0 or 0.0
		end
	end
	return matrix
end

function matrix_lib.copy(matrix)
	local copy = {}
	for i = 1, #matrix do
	    copy[i] = {}
		for j = 1, #matrix[i] do
			copy[i][j] = matrix[i][j]
		end
	end
	return copy
end

function matrix_lib.add(matrix_a, matrix_b, matrix_c)
	for i = 1, #matrix_a do
		for j = 1, #matrix_a[i] do
			matrix_c[i][j] = matrix_a[i][j] + matrix_b[i][j]
		end
	end
	return matrix_c
end

function matrix_lib.subtract(matrix_a, matrix_b, matrix_c)
	for i = 1, #matrix_a do
		for j = 1, #matrix_a[i] do
			matrix_c[i][j] = matrix_a[i][j] - matrix_b[i][j]
		end
	end
	return matrix_c
end

function matrix_lib.subtract_from_identity(matrix)
	for i = 1, #matrix do
		for j = 1, #matrix[i] do
			matrix[i][j] = i == j and (1.0 - matrix[i][j]) or (0.0 - matrix[i][j])
		end
	end
	return matrix
end

function matrix_lib.multiply(matrix_a, matrix_b, matrix_c)
	for i = 1, #matrix_c do
		for j = 1, #matrix_c[i] do
			matrix_c[i][j] = 0.0
			for k = 1, #matrix_a[i] do
				matrix_c[i][j] = matrix_c[i][j] + (matrix_a[i][k] * matrix_b[k][j])
			end
		end
	end
	return matrix_c
end

function matrix_lib.multiply_by_transpose(matrix_a, matrix_b, matrix_c)
	for i = 1, #matrix_c do
		for j = 1, #matrix_c[i] do
			matrix_c[i][j] = 0.0
			for k = 1, #matrix_a[1] do
				matrix_c[i][j] = matrix_c[i][j] + (matrix_a[i][k] * matrix_b[j][k])
			end
		end
	end
	return matrix_c
end

function matrix_lib.transpose(matrix_input, matrix_output)
	for i = 1, #matrix_input do
		for j = 1, #matrix_input[i] do
			matrix_output[j][i] = matrix_input[i][j]
		end
	end
	return matrix_output
end

function matrix_lib.equal(matrix_a, matrix_b, tolerance)
	for i = 1, #matrix_a do
		for j = 1, #matrix_a[i] do
			if math.abs(matrix_a[i][j] - matrix_b[i][j]) > tolerance then
				return false
			end
		end
	end
	return true
end

function matrix_lib.scale(matrix, scalar)
	for i = 1, #matrix do
		for j = 1, #matrix[i] do
			matrix[i][j] = matrix[i][j] * scalar
		end
	end
	return matrix
end

function matrix_lib.swap_rows(matrix, r1, r2)
	local tmp  = matrix[r1]
	matrix[r1] = matrix[r2]
	matrix[r2] = tmp
	return matrix
end

function matrix_lib.scale_row(matrix, r, scalar)
	for i = 1, #matrix do
		matrix[r][i] = matrix[r][i] * scalar
	end
	return matrix
end

function matrix_lib.shear_row(matrix, r1, r2, scalar)
	for i = 1, #matrix do
		matrix[r1][i] = matrix[r1][i] + (scalar * matrix[r2][i])
	end
	return matrix
end

function matrix_lib.destructive_invert(matrix_input, matrix_output)
	matrix_output = matrix_lib.set_identity(matrix_output)
	for i = 1, #matrix_input do
		if matrix_input[i][i] == 0.0 then
			local j
			for j = i + 1, #matrix_input do
				if matrix_input[r][i] ~= 0.0 then
					return
				end
			end

			if j == #matrix_input then
				return
			end

			matrix_input  = matrix_lib.swap_rows(matrix_input,  i, j)
			matrix_output = matrix_lib.swap_rows(matrix_output, i, j)
		end

		local scalar  = 1.0 / matrix_input[i][i]
		matrix_input  = matrix_lib.scale_row(matrix_input,  i, scalar)
		matrix_output = matrix_lib.scale_row(matrix_output, i, scalar)

		for r = 1, #matrix_input do
			if i ~= r then
				local shear_needed = -matrix_input[r][i]
				matrix_input  = matrix_lib.shear_row(matrix_input,  r, i, shear_needed)
				matrix_output = matrix_lib.shear_row(matrix_output, r, i, shear_needed)
			end
		end
	end
	return matrix_input, matrix_output
end

return matrix_lib