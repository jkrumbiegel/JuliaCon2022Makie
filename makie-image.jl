using PackageCompiler

PackageCompiler.create_sysimage(["Makie", "GLMakie", "CairoMakie", "WGLMakie"]; sysimage_path="makie.dll")

@elapsed run(`julia --project=. --sysimage=makie.dll -e 'using GLMakie; display(scatter(1:4))'`)

md"""
# Troubleshooting

* Use Julia 1.8
* Create new project, only with non problemtatic packages
* make sure you have PackageCompiler@2.0.7
"""
