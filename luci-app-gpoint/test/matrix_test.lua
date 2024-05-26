
local matrix = require("matrix_lib")


function test_copy()
	local foo = matrix.create(3, 3)
	local bar = matrix.create(3, 3)
	foo[1][1] = 1337.0
	bar = matrix.copy(foo, bar)

	assert(bar[1][1] == 1337.0)
end

function test_inverse()
	local foo = matrix.create(4, 4)
	foo = matrix.set(foo, 1.0, 2.0,  3.0,  4.0,
						  4.0, 1.0,  7.0,  9.0,
	     				  0.0, 0.0, -4.0, -4.0,
	     				  2.3, 3.4,  3.1,  0.0)

	local foo_copy = matrix.copy(foo)
	local bar      = matrix.create(4, 4)
	local identity = matrix.create(4, 4)

	identity = matrix.set_identity(identity)

	matrix.print(foo)
	print("--------------")
	matrix.print(bar)
	print("--------------")
	assert(matrix.destructive_invert(foo, bar))
	matrix.print(foo)
	print("--------------")
	matrix.print(bar)
	print("--------------")

	assert(matrix.equal(foo, identity, 0.0001))
	foo = matrix.multiply(foo_copy, bar, foo)
	assert(matrix.equal(foo, identity, 0.0001))
	foo = matrix.multiply(bar, foo_copy, foo)
	assert(matrix.equal(foo, identity, 0.0001))
end

test_copy()
test_inverse()
print("OK")