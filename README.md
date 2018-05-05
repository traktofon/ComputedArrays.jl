# ComputedArrays

[![Build Status](https://travis-ci.org/traktofon/ComputedArrays.jl.svg?branch=master)](https://travis-ci.org/traktofon/ComputedArrays.jl)
[![Coverage Status](https://coveralls.io/repos/traktofon/ComputedArrays.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/traktofon/ComputedArrays.jl?branch=master)
[![codecov.io](http://codecov.io/github/traktofon/ComputedArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/traktofon/ComputedArrays.jl?branch=master)

This small Julia package provides the type `ComputedArray`, which behaves (hopefully) like a dense, read-only n-dimensional array where the elements get computed on the fly. This can be useful in situations where you would like to have access to the values of a function on a Cartesian grid (i.e. a function-based tensor) but it wouldn't be economical to precompute or store all the elements. The aim is for low overhead and type stability.

The constructor requires a function of *n* elements and *n* coordinate ranges. These ranges can be almost anything as long as they have a length and you can index into them, e.g. `Vector`s, `linspace`s, or even another `ComputedArray`. In short,
```julia
A = ComputedArray(fn, xs, ys, zs)
```
results in an object where `A[i,j,k] = fn(xs[i], ys[j], zs[k])`.

Example:
```julia
using ComputedArrays

xs = linrange(0,1,11)
ys = linspace(0,10,11)
zs = ComputedArray(x->x*x, xs)
collect(zs)'
# --> 0.0  0.01  0.04  0.09  0.16  0.25  0.36  0.49  0.64  0.81  1.0

fn(x,y,z) = y - x^3 + sin(z)
A = ComputedArray(fn, xs, ys, zs)
# --> 11x11x11 ComputedArray of fn(::Float64, ::Float64, ::Float64)::Float64
length(A)   # --> 1331
size(A)     # --> (11, 11, 11)
A[3,4,5]    # --> 3.151318206614246

# testing the overhead
using BenchmarkTools
@btime $A[1,2,3]     # -->  23.666 ns (0 allocations: 0 bytes)
@btime collect($A);  # -->  35.925 μs (1 allocation: 10.56 KiB)
```
