#==============================================================================#
# AIC2021 Project1 - TPU Design                                                #
# file: matmul.py                                                              #
# description: 1. Implement a memory mapping method in global buffer for tpu   #
#              2. write golden output for testbench                            #
# authors: kaikai (deekai9139@gmail.com)                                       #
#          suhan  (jjs93126@gmail.com)                                         #
#==============================================================================#

import numpy as np
import random
import sys
import os

#------------------------------------------------------------------------------#
# Function Definations                                                         #
#------------------------------------------------------------------------------#

def write_binary_file_output(filename, matrix):
    fd = open(filename, "w")
    row, col = matrix.shape

    for r in range(row):
        line = ""
        for c in range(col):
            val = matrix[r][c]
            bin_str = format(val & ((1 << 37) - 1), '037b')  # Zero-padded 37-bit

            if (c % 32) != 0:
                line += "_"
            line += bin_str

            if (c + 1) % 32 == 0:
                fd.write(line + "\n")
                line = ""

        # Handle partial line
        if (col % 32) != 0:
            remaining = 32 - (col % 32)
            for _ in range(remaining):
                line += "_00000000000000000000000000000000000000000"
            fd.write(line + "\n")

    fd.close()
    print("<log> binary written in", filename)

def write_binary_file_input(filename, matrix):
    fd = open(filename, "w")
    row, col = matrix.shape

    for r in range(row):
        line = ""
        for c in range(col):
            # Convert value to 16-bit binary string, zero-padded
            val = matrix[r][c]
            bin_str = format(val & 0xFFFF, '016b')

            # Add separator if not the first value
            if (c % 32) != 0:
                line += "_"

            line += bin_str

            # Write and reset line every 32 values (512 bits)
            if (c + 1) % 32 == 0:
                fd.write(line + "\n")
                line = ""

        # Handle leftover values if not multiple of 32
        if (col % 32) != 0:
            remaining = 32 - (col % 32)
            for _ in range(remaining):
                line += "_0000000000000000"
            fd.write(line + "\n")

    fd.close()
    print("<log> binary written in", filename)

def write_binary_file0(filename, matrix):

  fd = open(filename, "w")
  row, col = matrix.shape
  reset_col = 0
  reset_row = 0
  r = 0
  c = 0
  p = 0

  while (p < col):
    while (r < row):
      while (c < col and reset_col != 1):

        # wirte word when 4bytes reached
        if ((c + 1) % 32 == 0):
          byte_value = "%08d\n" % int(bin(matrix[r][c])[2:])
          fd.write( byte_value )
          reset_col = 1
        elif ((c + 1) == col):
          byte_value = "%08d_" % int(bin(matrix[r][c])[2:])
          fd.write( byte_value )
          # Zero padding
          pad = c
          while ((pad + 1) % 32 != 0):
            byte_value = "00000000"
            fd.write( byte_value )
            pad+=1
            if ((pad + 1) % 32 == 0):
              delimeter = "\n"
              fd.write( delimeter )
              reset_col = 1
            else:
              delimeter = "_"
              fd.write( delimeter )
        else:
          byte_value = "%08d_" % int(bin(matrix[r][c])[2:])
          fd.write( byte_value )

        if (reset_col == 1):
          c = p
        else:
          c += 1

      r += 1
      reset_col = 0

    r = 0
    p += 32
    c = p

  fd.close()
  print("<log> binary written in ", filename)

def check_valid_mul_size(matrix_a, matrix_b):
  row_a, col_a = matrix_a.shape 
  row_b, col_b = matrix_b.shape 

  if(col_a != row_b):
    return 0
  else:
    return 1


#------------------------------------------------------------------------------#
# Matrix Declaration                                                           #
#------------------------------------------------------------------------------#

if (len(sys.argv) < 2):
  print("<error> Arguements lower than 2")
  exit()
else:
  inputs_set = sys.argv[1]


if (inputs_set == "monster"):
  row_r = random.randint(1,9)
  k     = random.randint(1,9)
  col_r = random.randint(1,9)

  matrix_a = (10 * np.random.rand(row_r, k)) % 4
  matrix_a = matrix_a.astype(int)
  matrix_b = (10 * np.random.rand(k, col_r)) % 4
  matrix_b = matrix_b.astype(int)

elif(inputs_set == "aih"):
  np.set_printoptions(threshold=sys.maxsize)
  row_r = 32
  k     = 32
  col_r = 32
  # matrix_a = (10 * np.random.rand(row_r, k)) % 4
  # matrix_a = matrix_a.astype(int)
  # matrix_b = (10 * np.random.rand(k, col_r)) % 4
  # matrix_b = matrix_b.astype(int)
  max_val = (1 << 16) - 1
  matrix_a = np.random.randint(0, max_val, size=(row_r, k), dtype=np.uint64)
  matrix_b = np.random.randint(0, max_val, size=(k, col_r), dtype=np.uint64)
else:
  filename_a = inputs_set + "/matrix_a.txt" 
  filename_b = inputs_set + "/matrix_b.txt" 

  matrix_a = np.genfromtxt(filename_a, delimiter = ",", dtype="int")
  matrix_b = np.genfromtxt(filename_b, delimiter = ",", dtype="int")


if (check_valid_mul_size(matrix_a, matrix_b) == 0):
  print("<error> Invalid input matrix size for multiplication")
  print("        matrix_a:", matrix_a.shape, ", matrix_b:", matrix_b.shape )
  exit() 

# matrix_a = np.array([[1, 1, 1, 1, 1, 1, 1, 1, 1],
#                      [2, 2, 2, 2, 2, 2, 2, 2, 2],
#                      [3, 3, 3, 3, 3, 3, 3, 3, 3],
#                      [4, 4, 4, 4, 4, 4, 4, 4, 4]
#                      ])
# 
# matrix_b = np.array([[1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1],
#                      [1, 0, 0, 1]])


#------------------------------------------------------------------------------#
# Matrix Multiplication                                                        #
#------------------------------------------------------------------------------#

print("Matrix A:", matrix_a.shape)
print(matrix_a)
print("Matrix B:", matrix_b.shape)
print(matrix_b)

res = np.matmul(matrix_a, matrix_b)
print("Matrix Multiplication: A x B")
print("Results:", res.shape)
print(res)

#------------------------------------------------------------------------------#
# Check if build/ folder exist                                                 #
#------------------------------------------------------------------------------#
if not os.path.exists("./build"):
  os.makedirs("./build")

#------------------------------------------------------------------------------#
# Write Matrix Parameters Definations                                          #
#------------------------------------------------------------------------------#
row_a, col_a = matrix_a.shape
row_b, col_b = matrix_b.shape
fd1 = open("./build/matrix_define.v", "w")

fd1.write("`define MATRIX_A_ROW %d\n" % row_a)
fd1.write("`define MATRIX_A_COL %d\n" % col_a)
fd1.write("`define MATRIX_B_ROW %d\n" % row_b)
fd1.write("`define MATRIX_B_COL %d\n" % col_b)

fd1.close()
print("<log> matrix definations written in ../build/matrix_define.v")

#------------------------------------------------------------------------------#
# Write Matrix A                                                               #
#------------------------------------------------------------------------------#
write_binary_file_input("./build/matrix_a.bin", np.transpose(matrix_a))

#------------------------------------------------------------------------------#
# Write Matrix B                                                               #
#------------------------------------------------------------------------------#
write_binary_file_input("./build/matrix_b.bin", matrix_b)

#------------------------------------------------------------------------------#
# Write golden output                                                          #
#------------------------------------------------------------------------------#
write_binary_file_output("./build/golden.bin", res)




