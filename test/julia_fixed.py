import numpy as np
import matplotlib.pyplot as plt

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

RE_RANGE = RE_MAX - RE_MIN
IM_RANGE = IM_MAX - IM_MIN

STEP_HORI = (RE_RANGE * FIXED_SCALE) // (X_SIZE - 1)
STEP_VERT = (IM_RANGE * FIXED_SCALE) // (Y_SIZE - 1)

RE_MIN_FIXED = RE_MIN * FIXED_SCALE
IM_MIN_FIXED = IM_MIN * FIXED_SCALE
THRESHOLD_SQ = (THRESHOLD * FIXED_SCALE) ** 2

# Julia constant in fixed point
C_RE = int(0.285 * FIXED_SCALE)
C_IM = int(0.01 * FIXED_SCALE)

def fixed_mul(a, b):
	return (a * b) >> FIXED_BITS

def julia_fixed():
	divergence = np.zeros((Y_SIZE, X_SIZE), dtype=int)

	for y in range(Y_SIZE):
		for x in range(X_SIZE):
			# Coordinate generation
			z_re = RE_MIN_FIXED + x * STEP_HORI
			z_im = IM_MIN_FIXED + y * STEP_VERT

			iteration = 0
			while iteration < MAX_ITER:
				z_re_sq = fixed_mul(z_re, z_re)
				z_im_sq = fixed_mul(z_im, z_im)
				xy = fixed_mul(z_re, z_im)

				# |z|^2 = z_re^2 + z_im^2
				mag_sq = z_re_sq + z_im_sq
				if mag_sq > THRESHOLD_SQ:
					break

				# z_re_n+1 = z_re^2 - z_im^2 + C_RE
				z_re = z_re_sq - z_im_sq + C_RE
				
				# z_im_n+1 = 2 * z_re * z_im + C_im
				z_im = (xy << 1) + C_IM
				
				iteration += 1

			divergence[y, x] = iteration

	return divergence

# -----------------------------
# Display result
# -----------------------------
if __name__ == "__main__":
	div = julia_fixed()
	plt.figure(figsize=(8, 8))
	plt.imshow(div, cmap='inferno', extent=(RE_MIN, RE_MAX, IM_MIN, IM_MAX))
	plt.title(f"Fixed-Point Julia Set (VHDL-style)")
	plt.axis('off')
	plt.show()
