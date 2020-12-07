using GeoArrays

b = bbox(1, 2, 3, 4)
bbox(xmin = 1, ymin = 2, xmax = 3, ymax = 4)


function hello(x::AbstractArray{T}) where T <: Real
    println(x)
end

hello(zeros(3))
hello(zeros(4, 4))
hello(zeros(4, 4, 4))
