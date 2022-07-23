using CairoMakie
CairoMakie.activate!()

# what units does Makie use? px? pt? cm?

# 1 inch == 72 pt
# 1 inch == 2.54 cm

# Nature full width figure: 183 mm

width_pt = 183 / 25.4 * 72
height_pt = width_pt * 2 / 3

f = Figure(resolution=(width_pt, height_pt), fontsize=10)
Axis(f[1, 1], title="Axis 1")
Axis(f[1:2, 2], title="Axis 2")
Axis(f[2, 1], title="Axis 3")
f

##

CairoMakie.activate!(type="svg", pt_per_unit=0.75)
CairoMakie.activate!(type="png", px_per_unit=1)
CairoMakie.activate!(type="png", px_per_unit=2)
CairoMakie.activate!(type="png", px_per_unit=4)

##

save("test.pdf", f, pt_per_unit=1)
save("test.png", f, px_per_unit=2)


## figure size following content

f = Figure()
for i in 1:4, j in 1:3
    Axis(f[i, j], width=100, height=100)
end

# resize_to_layout!(f)

f

##
