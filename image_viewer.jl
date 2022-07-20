using JSON3
using HTTP
using FileIO
using GLMakie
using Dates
using Chain
using GLMakie.Colors


metadata = open(JSON3.read, "images.json")

index = Observable(1)

entry = @lift metadata[$index]

img = lift(entry) do e
    @chain begin
        e["url"]
        HTTP.get
        _.body
        IOBuffer
        load
    end
end

##

f = Figure(fontsize=30)

ax, im = image(f[1, 1], @lift($img'),
    axis=(;
        yreversed=true,
        aspect=DataAspect(),
        title=@lift($entry["title"])
    )
)

subset = lift(img, ax.finallimits) do img, lims
    (xlow, ylow), (xhigh, yhigh) = extrema(lims)
    xlow = clamp(round(Int, xlow), 1, size(img, 2))
    xhigh = clamp(round(Int, xhigh), 1, size(img, 2))
    ylow = clamp(round(Int, ylow), 1, size(img, 1))
    yhigh = clamp(round(Int, yhigh), 1, size(img, 1))
    img'[xlow:xhigh, ylow:yhigh]
end

ax2 = Axis(f[1, 2])
hist!(ax2, @lift(vec(Float64.(red.($subset)))), bins=range(0, 1, length=256), color=(:red, 0.3))
hist!(ax2, @lift(vec(Float64.(green.($subset)))), bins=range(0, 1, length=256), color=(:green, 0.3))
hist!(ax2, @lift(vec(Float64.(blue.($subset)))), bins=range(0, 1, length=256), color=(:blue, 0.3))
ylims!(ax2, low=0)
xlims!(ax2, 0, 1)

gl = GridLayout(f[2, 1], tellwidth=false)

b = Button(gl[1, 2], label="Next")

function offset_index(b, i, label)
    b.label = "Loading..."
    index[] = mod1(index[] + i, length(metadata))
    reset_limits!(ax)
    reset_limits!(ax2)
    b.label = label
end

on(b.clicks) do c
    offset_index(b, 1, "Next")
end

b2 = Button(gl[1, 1], label="Previous")

on(b2.clicks) do c
    offset_index(b2, -1, "Previous")
end

f

##

image(randn(3000, 3000))