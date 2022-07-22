using JSON3
using HTTP
using FileIO
using GLMakie
using Dates
using Chain
using GLMakie.Colors
using Memoization

GLMakie.set_window_config!(float=true)
GLMakie.activate!()

##
metadata = open(JSON3.read, "images.json")

@memoize function load_image(url)
    @chain begin
        url
        HTTP.get
        _.body
        IOBuffer
        load
    end
end
##

index = Observable(1)

entry = @lift metadata[$index]

img = lift(entry) do e
    load_image(e["url"])
end

f = Figure(fontsize=30)

ax, im = image(f[1, 1], @lift($img'),
    axis=(;
        yreversed=true,
        aspect=DataAspect(),
        title=@lift($entry["title"])
    )
)
hidedecorations!(ax)

ax2 = Axis(f[1, 2])

subset = Observable{Any}()

onany(img, ax.finallimits) do img, lims
    (xlow, ylow), (xhigh, yhigh) = extrema(lims)
    xlow = clamp(round(Int, xlow), 1, size(img, 2) + 1)
    xhigh = clamp(round(Int, xhigh), 0, size(img, 2))
    ylow = clamp(round(Int, ylow), 1, size(img, 1) + 1)
    yhigh = clamp(round(Int, yhigh), 0, size(img, 1))
    subset[] = @view img[ylow:yhigh, xlow:xhigh]
    reset_limits!(ax2)
end
notify(img)

hist!(ax2, @lift(vec(Float64.(red.($subset)))), bins=range(0, 1, length=256), color=RGBAf(1, 0, 0, 0.3))
hist!(ax2, @lift(vec(Float64.(green.($subset)))), bins=range(0, 1, length=256), color=RGBAf(0, 1, 0, 0.3))
hist!(ax2, @lift(vec(Float64.(blue.($subset)))), bins=range(0, 1, length=256), color=RGBAf(0, 0, 1, 0.3))
ylims!(ax2, low=0)
xlims!(ax2, 0, 1)

gl = GridLayout(f[2, 1], tellwidth=false)

b = Button(gl[1, 2], label="Next")

function offset_index(b, i, label)
    try
        b.label = "Loading..."
        index[] = mod1(index[] + i, length(metadata))
        reset_limits!(ax)
        reset_limits!(ax2)
    finally
        b.label = label
    end
end

on(b.clicks) do c
    @async offset_index(b, 1, "Next")
end

b2 = Button(gl[1, 1], label="Previous")

on(b2.clicks) do c
    @async offset_index(b2, -1, "Previous")
end

f

