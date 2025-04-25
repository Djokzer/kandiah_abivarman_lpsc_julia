import numpy as np
import matplotlib.pyplot as plt

# GENERIC CONSTANT
X_SIZE = 1000
Y_SIZE = 1000

RE_MIN = -2
RE_MAX = 2
IM_MIN = -2
IM_MAX = 2

FIXED_BITS = 20
FIXED_SCALE = 1 << FIXED_BITS

MAX_ITER = 100
THRESHOLD = 2

# JULIA COMPLEX CONSTANT IN FIXED POINT
C_RE = int(0.285 * FIXED_SCALE)
C_IM = int(0.01 * FIXED_SCALE)

# COMPLEX PLANE RANGE
RE_RANGE = RE_MAX - RE_MIN
IM_RANGE = IM_MAX - IM_MIN

# COMPLEX STEP
STEP_HORI = (RE_RANGE * FIXED_SCALE) // (X_SIZE - 1)
STEP_VERT = (IM_RANGE * FIXED_SCALE) // (Y_SIZE - 1)

# COMPLEX OFFSET SCALED
RE_MIN_FIXED = RE_MIN * FIXED_SCALE
IM_MIN_FIXED = IM_MIN * FIXED_SCALE

# THRESHOLD SCALED AND SQUARED
THRESHOLD_SQ = ((THRESHOLD * FIXED_SCALE) ** 2) >> FIXED_BITS

# UTILITY FUNCTIONS
def fixed_mul(a, b):
	return int(a * b) >> FIXED_BITS

def save_complex_coord():
	pass

def load_complex_coord(filename):
	c_array = np.zeros((Y_SIZE, X_SIZE), dtype=[('x', 'int'), ('y', 'int')])
	lines = []
	with open(filename) as f:
		lines = np.array([line.strip().split(',') for line in f.readlines()]).astype(int)
	
	for y in range(Y_SIZE):
		for x in range(X_SIZE):
			c_array[y, x] = (lines[x + y * X_SIZE][0], lines[x + y * X_SIZE][1])
	
	return c_array

# JULIA FRACTAL COMPUTING FUNCTIONS
def gen_complex_coord():
	c_array = np.zeros((Y_SIZE, X_SIZE), dtype=[('x', 'int'), ('y', 'int')])

	for y in range(Y_SIZE):
		for x in range(X_SIZE):
			# Complex coordinate
			z_re = RE_MIN_FIXED + x * STEP_HORI
			z_im = IM_MIN_FIXED + y * STEP_VERT
			c_array[y, x] = (z_re, z_im)
	
	return c_array
	
def julia_compute(c_array):
	julia = np.zeros((Y_SIZE, X_SIZE), dtype=int)

	for y in range(Y_SIZE):
			for x in range(X_SIZE):
				# Get Complex coordinate
				z_re = c_array[y, x][0]
				z_im = c_array[y, x][1]


				# Check if coordinate in julia set
				iteration = 0
				while iteration < MAX_ITER:
					z_re_sq = fixed_mul(z_re, z_re)
					z_im_sq = fixed_mul(z_im, z_im)
					xy = fixed_mul(z_re, z_im)

					# z^2 = z_re^2 + z_im^2
					mag_sq = z_re_sq + z_im_sq
					if mag_sq > THRESHOLD_SQ:
						break

					# z_re_n+1 = z_re^2 - z_im^2 + C_RE
					z_re = z_re_sq - z_im_sq + C_RE
					
					# z_im_n+1 = 2 * z_re * z_im + C_im
					z_im = (xy << 1) + C_IM
					
					iteration += 1

				julia[y, x] = iteration

	return julia

# JULIA PYTHON TESTING
def test_fixed_julia():
	# COMPUTE JULIA FRACTAL
	c = gen_complex_coord()
	div = julia_compute(c)

	# FRACTAL RENDERING
	plt.figure(figsize=(8, 8))
	plt.imshow(div, cmap='cubehelix', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	plt.title(f"Fixed-Point Julia Set")
	plt.axis('off')
	plt.show()

# VHDL TESTING FUNCTION
def test_gen_complex_coord():
	# GENERATE COMPLEX COORDINATE WITH PYTHON
	c = gen_complex_coord()
	div_py = julia_compute(c)
	
	# GENERATE COMPLEX COORDINATE WITH VHDL
	c = load_complex_coord("output/complex_output.csv")
	div_vhdl = julia_compute(c)

	# PLOT BOTH IMAGES SIDE BY SIDE
	fig, axs = plt.subplots(1, 2, figsize=(12, 6))

	axs[0].imshow(div_py, cmap='cubehelix', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	axs[0].set_title("Python Computation")
	axs[0].axis('off')

	axs[1].imshow(div_vhdl, cmap='cubehelix', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	axs[1].set_title("VHDL Output Comparison")
	axs[1].axis('off')

	plt.tight_layout()
	plt.show()

def test_julia_compute_vhdl():
	# COMPUTE JULIA FRACTAL
	c = gen_complex_coord()
	div = julia_compute(c)

	# GET VHDL JULIA FRACTAL
	div_vhdl = np.loadtxt("output/julia_output.csv", dtype=np.uint8).reshape((X_SIZE, Y_SIZE))

	# PLOT BOTH IMAGES SIDE BY SIDE
	fig, axs = plt.subplots(1, 2, figsize=(12, 6))

	axs[0].imshow(div, cmap='cubehelix', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	axs[0].set_title("Python Computation")
	axs[0].axis('off')

	axs[1].imshow(div_vhdl, cmap='cubehelix', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	axs[1].set_title("VHDL Output Comparison")
	axs[1].axis('off')

	plt.tight_layout()
	plt.show()

if __name__ == "__main__":
	#test_fixed_julia()
	#test_gen_complex_coord()
	test_julia_compute_vhdl()