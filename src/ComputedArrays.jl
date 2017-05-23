module ComputedArrays

# A = ComputedArray(fn, xs, ys, zs)
# => A[i,j,k] = fn(xs[i], ys[j], zs[k])

# A = ComputedArray(fn, xs, ys, zs, order=(2,3,1))
# => A[j,k,i] = fn(xs[i], ys[j], zs[k])
# => A[i,j,k] = fn(xs[k], ys[i], zs[j])

import Base: size, getindex
export ComputedArray, ComputedVector, ComputedMatrix

struct ComputedArray{F,C,T,N} <: AbstractArray{T,N}
   fn     :: F
   coords :: C
end

const ComputedVector{F,C,T} = ComputedArray{F,C,T,1}
const ComputedMatrix{F,C,T} = ComputedArray{F,C,T,2}

function ComputedArray(fn, coords...)
   N = length(coords)
   argtypes = map(eltype, coords)
   T = Core.Inference.return_type(fn, argtypes)
   ComputedArray{typeof(fn), typeof(coords), T, N}(fn, coords)
end

size(A::ComputedArray) = map(length, A.coords)

getindex(A::ComputedVector, i::Int) = A.fn(A.coords[1][i])
getindex(A::ComputedMatrix, i::Int, j::Int) = A.fn(A.coords[1][i], A.coords[2][j])

@generated function getindex(A::ComputedArray{F,C,T,N}, I::Vararg{Int,N}) where {F,C,T,N}
   ex = :( A.fn() )
   for d = 1:N
      push!(ex.args, :( A.coords[$d][I[$d]] ))
   end
   return ex
end

end # module
