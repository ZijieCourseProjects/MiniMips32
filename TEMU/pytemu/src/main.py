import numpy as np

a = np.ndarray(shape=3, dtype=np.uint8)
b = np.ndarray(shape=3, dtype=np.uint8)
b[2] = 1
print(a)
print(b)

a[0] = b[2]
print(a)

b[2] = 4
print(a)
