module ComputedArrays

# A = ComputedArray(fn, xs, ys, zs)
# => A[i,j,k] = fn(xs[i], ys[j], zs[k])

# A = ComputedArray(fn, xs, ys, zs, order=[2,3,1])
# => A[j,k,i] = fn(xs[i], ys[j], zs[k])
# => A[i,j,k] = fn(xs[k], ys[i], zs[j])

import Base: ndims, size, getindex, show
export ComputedArray, ComputedVector, ComputedMatrix

struct ComputedArray{F,C,T,N} <: DenseArray{T,N}
   fn     :: F
   coords :: C
   shape  :: NTuple{N,Int}
   perm   :: NTuple{N,Int}
end

const ComputedVector{F,C,T} = ComputedArray{F,C,T,1}
const ComputedMatrix{F,C,T} = ComputedArray{F,C,T,2}

function ComputedArray(fn, coords...; order=1:length(coords))
   N = length(coords)
   argtypes = map(eltype, coords)
   local T
   try
      T = Base.return_types(fn, argtypes)[1]
   catch
      warn("Cannot infer return type, defaulting to Any.")
      T = Any
   end
   @assert length(order)==N "order must have $N elements"
   @assert isperm(order) "order=$order is not a permutation"
   shape = ntuple(d->length(coords[order[d]]), N)
   perm = tuple( invperm(order)... )
   ComputedArray{typeof(fn), typeof(coords), T, N}(fn, coords, shape, perm)
end

size(A::ComputedArray) = A.shape

getindex(A::ComputedVector, i::Int) = A.fn(A.coords[1][i])

@generated function getindex(A::ComputedArray{F,C,T,N}, I::Vararg{Int,N}) where {F,C,T,N}
   defex = Expr(:block)
   callex = :( A.fn() )
   for d = 1:N
      xsym = Symbol(:x, d)
      push!(defex.args, :( $xsym = A.coords[$d][I[A.perm[$d]]] ))
      push!(callex.args, xsym)
   end
   # thanks to @mbauman for the following trick
   # inlining is needed to avoid allocations for larger N and more complicated F
   return :($defex; Base.@_inline_meta; $callex)
end

repr(A::ComputedArray{F,C,T,N}) where {F,C,T,N} =
   (N==1 ? "$(length(A))-element" : join(size(A), "x")) *
   " ComputedArray of $(A.fn)(" * join(map(xs->"::$(eltype(xs))", A.coords), ", ") * ")::$T"

show(io::IO, A::ComputedArray) = begin; write(io, repr(A)); nothing; end
# prevent REPL from doing fancy behavior inherited from AbstractArray
show(io::IO, ::MIME"text/plain", A::ComputedArray) = show(io, A)

end # module
