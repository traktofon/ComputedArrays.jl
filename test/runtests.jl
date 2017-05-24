using ComputedArrays
using Base.Test


ca1 = ComputedArray(cospi, linspace(0,1,1000));
@test size(ca1) == (1000,)
@test eltype(ca1) == Float64

pot(x,i) = ceil(Int32, i*x^i);
ca2 = ComputedArray(pot, linspace(0,1,11), 1:5);
@test size(ca2) == (11,5)
@test eltype(ca2) == Int32

v(x1,y1,x2,y2) = 1/hypot(x1-x2, y1-y2);
x1s = 0 + linspace(-1,1,10) |> collect
y1s = 0 + linspace(-1,1,11) |> collect
x2s = 3 + linspace(-1,1,12) |> collect
y2s = 4 + linspace(-1,1,13) |> collect
ca4 = ComputedArray(v, x1s, y1s, x2s, y2s)
@test size(ca4) == (10,11,12,13)
@test eltype(ca4) == Float64

ca4p = ComputedArray(v, x1s, y1s, x2s, y2s, order=(2,3,4,1))
@test size(ca4p) == (11,12,13,10)
@test ca4[3,5,6,8] == ca4p[5,6,8,3]
pca4 = PermutedDimsArray(ca4, (2,3,4,1))
@test ca4p == pca4
