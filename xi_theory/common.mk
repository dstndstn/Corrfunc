#### Science use-cases
OPT += -DPERIODIC
#OPT  += -DOUTPUT_RPAVG  ### Enabling this can cause up to a 2x performance hit

#### Code specs
#OPT += -DDOUBLE_PREC
OPT += -DUSE_AVX
OPT += -DUSE_OMP

INCLUDE=-I ../io -I ../utils -I ../include 

CC=gcc
CLINK=
CFLAGS=  $(OPT) $(INCLUDE) -Wsign-compare -Wall -Wextra -Wshadow -Wunused -std=c99 -g -m64 -fPIC -O3

ifneq (USE_OMP,$(findstring USE_OMP,$(OPT)))
  ifneq (clang,$(findstring clang,$(CC)))
     $(warning Recommended compiler for a serial build is clang)
  endif
endif

ifeq (OUTPUT_RPAVG,$(findstring OUTPUT_RPAVG,$(OPT)))
  ifneq (DOUBLE_PREC,$(findstring DOUBLE_PREC,$(OPT)))
    $(error DOUBLE_PREC must be enabled with OUTPUT_RPAVG -- loss of precision will give you incorrect results for the outer bins (>=20-30 million pairs))
  endif
endif


ifeq (icc,$(findstring icc,$(CC)))
  CFLAGS += -xhost   #-vec-report6  
	ifeq (USE_OMP,$(findstring USE_OMP,$(OPT)))
		CFLAGS += -openmp
	endif
else

  ### compiler specific flags for gcc
	ifeq (gcc,$(findstring gcc,$(CC)))
		CFLAGS += -funroll-loops -fprefetch-loop-arrays #-fprofile-use -fprofile-correction #-fprofile-generate
		ifeq (USE_OMP,$(findstring USE_OMP,$(OPT)))
			CFLAGS += -fopenmp
		endif
	endif

  ### compiler specific flags for clang
	ifeq (clang,$(findstring clang,$(CC)))
		CFLAGS += -funroll-loops
		ifeq (USE_OMP,$(findstring USE_OMP,$(OPT)))
      $(error clang does not support OpenMP - please use gcc/icc for compiling with openmp)
		endif
	endif

#### common options for gcc and clang
CFLAGS  +=  -mavx -march=native -O3 -mpopcnt 
CFLAGS  +=  -Wformat=2  -std=c99  -Wpacked  -Wnested-externs -Wpointer-arith  -Wredundant-decls  -Wfloat-equal -Wcast-qual  -Wshadow
CFLAGS  +=  -Wcast-align -Wmissing-declarations -Wmissing-prototypes  -Wnested-externs -fno-strict-aliasing #-D_POSIX_C_SOURCE=2 -Wpadded -Wstrict-prototypes -Wconversion
CLINK += -lm
endif


