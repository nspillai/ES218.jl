### A Pluto.jl notebook ###
# v0.19.23

#> [frontmatter]
#> title = "Love Waves"
#> description = "Dive into the world of plane Love waves in a single homogeneous layer overlying a homogeneous half-space, offering a simple yet fascinating exploration of the topic."

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 928f806a-3cc2-11ed-09c8-7f3b53b830e2
begin
    using PlutoUI
    using Symbolics
    using SymbolicUtils
    using PlutoTeachingTools
    using Latexify
    using Roots
    using PlutoPlotly
    using LaTeXStrings
end

# ╔═╡ 9b02e72d-be6b-485d-a186-ba2fe2dcd6fb
ChooseDisplayMode()

# ╔═╡ bdf3d004-653a-4b56-af7c-42ca1d6021e5
TableOfContents()

# ╔═╡ 2a41b15e-1a0e-4c92-a3a5-53603faacea1
md"""
# Love Waves
This notebook studies the simplest case of plane Love waves in a single homogeneous layer overlying a homogeneous half-space. This is an eigenvalue problem, where the boundary and the free-surface conditions limit the allowable eigenvalues and eigenfunctions. In other words, for a given frequency, the horizontal slowness can only take special values. It can often happen that more than one value of the horizontal slowness contributes to the Love wave of a particular frequency. 

By interacting with this notebook, we can

- visualize the displacement wavefield for different modes;
- notice the cut-off frequency of the $n$th order higher mode.

##### [Interactive Seismology Notebooks](https://pawbz.github.io/Interactive-Seismology.jl/)

Instructor: *Pawan Bharadwaj*,
Indian Institute of Science, Bengaluru, India

"""

# ╔═╡ 87b80ede-1da7-4c24-ada9-4327f0bb755e
@bind tt Clock(0.1)

# ╔═╡ 8d2fd2d9-da36-43f4-8dcb-dd931c8189f5
@syms β₁::Real β₂::Real μ₁::Real μ₂::Real ρ₁::Real ρ₂::Real

# ╔═╡ 25f32a28-4c57-4ed0-9fc4-4a40ca31e4dd
@syms H::Real

# ╔═╡ d8b52234-757b-441d-918d-585fd6593fcf
md"""
## Trail Wavefield

We shall now consider a trail solution for the $y$-component of the displacement field, denoted using `u`. This solution considers two planewaves with amplitudes $A$ and $B$ and slowness components $p$ and $\eta$. If the planewave if homogeneous $\eta$ is imaginary. Otherwise, if $\eta$ is real, we have either exponentially decaying or growing fields with depth with inhomogeneous waves travelling in the $x$ direction.
"""

# ╔═╡ b120da8e-dcd6-4280-819b-0e20b4675080
@syms p::Real η₂

# ╔═╡ c74c4a58-b47e-4509-aadd-7400c350ff6c
@syms ı::Complex{Real} # imaginary unit, going to substitute with im later

# ╔═╡ 44aa241c-bf9d-4a2a-b459-28a73a991606
@syms x::Real z::Real t::Real ω::Real

# ╔═╡ 5896fa94-ab7f-42f0-9fac-265e11faba2b
trail_soln(p, η, A, B) = (A * exp(-ω * η * z) + B * exp(ω * η * z)) * exp(ı * ω * (t - (p * x)))

# ╔═╡ 6e734951-2907-49d7-ae88-dffc463bf8a3
md"The wave operator corresponding to the top layer $z∈[0, H]$ is denoted using `L1`."

# ╔═╡ 2f40cb44-60af-4fbe-8f73-d8d06e99fc3b
begin
    Dz = Differential(z)
    Dx = Differential(x)
    Dt = Differential(t)
end

# ╔═╡ 4d859323-12e0-4fba-a796-48995f980f33
L1(u) = Dt(Dt(u)) - μ₁ / ρ₁ * (Dx(Dx(u)) + Dz(Dz(u)))

# ╔═╡ 79c4f3a4-65b6-4e02-9786-f168584c7781
md"We now write an expression for the wavefield in the top layer using the vertical component of the slowness vector $\eta_1$ and amplitudes $A_1$ and $B_1$."

# ╔═╡ dc709a17-ab03-406f-b232-d7658872a95e
@syms A₁::Real B₁::Real η₁

# ╔═╡ 83e2b2b3-f84a-4926-9332-b5570d52be8b
u1 = trail_soln(p, η₁, A₁, B₁)

# ╔═╡ 52c90f98-d314-4c5f-8b8d-4aff4c32b6d9
simplify(expand_derivatives(L1(u1)) / u1)

# ╔═╡ d6dc2422-6be3-447e-b7c1-be655971b6f7
md"Similarly, for the half space."

# ╔═╡ 1a13363a-9f8f-4123-9b37-c6dcad1ccdde
@syms A₂::Real B₂::Real

# ╔═╡ 2f80cfcf-9788-41a3-8797-cd1965216738
u2 = trail_soln(p, η₂, A₂, B₂)

# ╔═╡ de304d8c-253e-4cb5-8332-db79de20991c
md"""
We ignore the upcoming wave when $\eta_2$ is imaginary, and avoid exponential growth with depth when $\eta_2$ is real such that.
"""

# ╔═╡ 30219c41-a040-4056-adda-ce64ac3c6969
B₂ ~ 0

# ╔═╡ e1ab342d-84fe-4c00-9756-455436b0fad7
md"""
## Free Surface Condition
We shall now evaluate the traction corresponding to the free surface and set it to zero.
"""

# ╔═╡ ca377428-d597-47a2-b29e-f40884697bd6
σyz1 = expand_derivatives(μ₁ .* Dz(u1))

# ╔═╡ b819ce05-628a-49b6-aa57-f1ee765fb027
Symbolics.solve_for(substitute(σyz1, z => 0), B₁) |> simplify

# ╔═╡ 53799d32-3edc-4416-a928-868ea974c6bd
A₁ ~ B₁

# ╔═╡ f39b1e01-c16e-405e-a2fc-85408d53c762
md"## Dynamic Boundary Condition
We now impose continuity of $\sigma_{yz}$ component of the stress tensor across the boundary at $z=H$."


# ╔═╡ b3924a35-6565-46c4-9a6e-d29b1172668e
σyz2 = expand_derivatives(μ₂ .* Dz(u2))

# ╔═╡ 30f26e47-0a37-4165-b18b-a20f1148deb1
σyz1H = substitute(σyz1, z => H)

# ╔═╡ f7b5adba-09ca-4895-8b18-5fc84b752392
σyz2H = substitute(σyz2, z => H)

# ╔═╡ 8f35d8b0-ff20-442c-b5b2-f5a2616fe345
A₂ex1 = substitute(Symbolics.solve_for(σyz1H ~ σyz2H, A₂), [B₁ => A₁, B₂ => 0])

# ╔═╡ dab840e2-7d7c-4f65-b4ea-289babc430c8
md"## Kinematic Boundary Condition
Similarly, we impose the continuity of the displacement field across the boundary."

# ╔═╡ 644637c9-c32d-4335-af59-3452263a9707
u1H = substitute(u1, [z => H, B₁ => A₁])

# ╔═╡ 09a8041d-6443-4e83-8443-e0e2aa05317a
u2H = substitute(u2, [z => H, B₂ => 0])

# ╔═╡ 0fc4d1a1-25ac-49c9-b74b-a9f26928c652
A₂ex2 = Symbolics.solve_for(u1H ~ u2H, A₂)

# ╔═╡ 794a1f79-708d-4305-8aa0-d2673f34e31f
md"""
## Graphical Solution
This section reacts to the medium configuration selected above. In order to have a non-trivial solution, we need the two expressions for $A₂$ should be equal to each other. We begin by simplifying these expressions, substitute the UI medium configuration and plot them in following three ranges.
"""

# ╔═╡ bfb54c6f-a52c-4a10-87c7-9788f2f63629
ex1 = simplify(A₂ex1 * arguments(A₂ex1)[2] / A₁)

# ╔═╡ cbbae944-5377-44a4-ae32-868a75625248
ex2 = simplify(A₂ex2 * arguments(A₂ex1)[2] / A₁)

# ╔═╡ b5c5f1d0-0075-4727-a6a9-8b20d6f65bc4
md"Note that the goal here is to find zeros of the function `F` defined below,  which outputs `ex1-ex2` for a given horizontal slowness `p`."

# ╔═╡ b2858a78-4498-4374-9ee0-c68f3dfca6e8
md"From the above plots, we can observe that there are no zeros in either (0,β₁) or (β₂, ∞). Therefore, we will now find the zeros of `F` in the interval [β₁, β₂]. The `find_zeros` function from the [`Roots.jl`](https://github.com/JuliaMath/Roots.jl) package can be used to search for all zeros in a specified interval in a derivative-free fashion. We only consider the real part of `F` as the imaginary part is zero in [β₁, β₂]. The zeros correspond to the eigenvalue phase velocities."

# ╔═╡ df35e923-b43c-4809-a9db-32a371fc9010
md"## Appendix"

# ╔═╡ 840a743a-e298-4f99-ae6e-11c85b6f5bc5
# a range for phase velocity (typical shear velocity values in crust/ mantle)
cgrid = range(1, stop=7, step=0.2)

# ╔═╡ 7bd19e44-b4f5-43f3-b6be-b557ca95c67f
md"In order to plot the displacement wavefield, we will now build functions that output the particle displacement in the first and second layers for input $x$, $z$, $t$ and $p$."

# ╔═╡ db4a22f5-74eb-477e-9426-065dcfd1751c
md"### UI"

# ╔═╡ ccbb61f1-c7a1-4cc1-a5c8-0555dd664e16
function medium_input()

    return PlutoUI.combine() do Child
        inputs1 = [
            md""" 
   H (km) $(Child("Hp", Slider(range(10, 100, step=5), default=35, show_value=true)))""",
            md"""
            β₁ (km/s) $(Child("β₁", Slider(cgrid, default=3.5, show_value=true)))
            """,
            md"""
            β₂ (km/s) $(Child("β₂", Slider(cgrid, default=4.5, show_value=true)))
            """,
            md"""
            ρ₁ (gm/cc) $(Child("ρ₁", Slider(range(1, 7, step=0.2), default=2.6, show_value=true)))
            """,
            md"""
            ρ₂ (gm/cc) $(Child("ρ₂", Slider(range(1, 7, step=0.2), default=3.4, show_value=true)))
            """
        ]
        inputs2 = [
            md"""
            $(Child("freq", Slider(range(0.0, 0.25, step=0.01), default=0.08, show_value=true)))
            """,
        ]

        md"""
##### Medium
Choose the depth of the boundary between the top layer and the halfspace.
Slide to adjust the seismic velocities ∈ [1, 7] km/s and densities ∈ [1, 7] gm/cc of the top layer and the halfspace. By default, the parameters corresponding to the curst and mantle will be chosen.
  $(inputs1)
		
##### Frequency (Hz)
  $(inputs2)
        """
    end
end

# ╔═╡ 19a31e92-8226-4ce5-aa04-933552953a9d
@bind medium confirm(medium_input())

# ╔═╡ 7bd5a551-3379-4270-81d0-9506292e6d8c
crange1 = range(medium.β₁, stop=medium.β₂, length=100)

# ╔═╡ b3e662bf-8d13-418b-886c-b29456d62454
crange2 = range(medium.β₁ - 0.5, stop=medium.β₁, length=100)

# ╔═╡ 3fa22358-6d61-4b9a-9aa8-39d2b1c6a917
crange3 = range(medium.β₂, stop=medium.β₂ + 0.5, length=100)

# ╔═╡ 355e039d-db6d-48b4-a7d7-5f73686e6d56
# substitute values of medium.Hp, medium.β₁, and medium.ρ₁ into the expression x, instead of μ, η.
# then return a function of horizontal slowness f(p) that can be plotted
function subs_βρ(x; output_function=true)
    x = substitute(x, [ω => 2 * pi * medium.freq, H => medium.Hp, μ₁ => medium.β₁ * medium.β₁ * medium.ρ₁, μ₂ => medium.β₂ * medium.β₂ * medium.ρ₂, η₁ => sqrt((p * p - 1 / medium.β₁^2 + eps() * im)), η₂ => sqrt((p * p - 1 / medium.β₂^2) + eps() * im)])
    if (output_function)
        return build_function(x, p, expression=Val{false})
    else
        x
    end
end

# ╔═╡ ad269679-e1f9-4d9d-827f-468e36f27bfc
F = subs_βρ(ex1 - ex2; output_function=true)

# ╔═╡ cc173455-2ed0-42f3-a9c0-0dfdbbe982ee
cn = sort(inv.(find_zeros(real ∘ F, inv(medium.β₁), inv(medium.β₂))))

# ╔═╡ ad78f0ef-460d-4b62-8bbc-0f7059214b38
# need prettier labels for MultiCheckBox
names_cn = map(enumerate(cn)) do (i, c)
    c => string(i, ") ", floor(c, digits=2))
end

# ╔═╡ cdaefb2c-818e-4d66-b1c3-f6ac8829ba45
function subs_u1(u; output_function=true)
    u = substitute(subs_βρ(u; output_function=false), [ı => im, B₁ => 1, A₁ => 1, B₂ => 0])
    if (output_function)
        build_function(u, x, z, t, p, expression=Val{false})
    else
        u
    end
end

# ╔═╡ 8912a771-1914-42a7-a35b-43cb63971a41
U1 = subs_u1(u1)

# ╔═╡ 236e2338-f057-4c33-80e2-7dd8ea9ce206
function subs_u2(u; output_function=true)
    A₂p = subs_u1(A₂ex1, output_function=false)
    u = substitute(subs_βρ(u; output_function=false), [ı => im, B₁ => 1, A₁ => 1, B₂ => 0, A₂ => A₂p])
    if (output_function)
        build_function(u, x, z, t, p, expression=Val{false})
    else
        u
    end
end

# ╔═╡ d49ae6c9-a4ee-45f0-99c3-ab9f23ab895d
U2 = subs_u2(u2)

# ╔═╡ d76e9b6a-a33c-4342-985e-48f8ee91bf71
function mode_input()

    return PlutoUI.combine() do Child

        input = [md""" 
        cₙ (km/s) $(Child("c", MultiCheckBox(names_cn, select_all=true, default=cn)))
        """,]

        return md"""
#### Phase-velocity Eigenvalues
  Depending on the parameters chosen above, the estimated phase-velocity eigenvalues (cₙ) are given below. Select them to plot the corresponding eigenfunction (uₙ) i.e., displacement wavefield of a particular mode. You may also select multiple eigenfunctions to plot their superposition. For example, for the crust-mantle configuration, we can notice the first higher-order mode for frequency $0.08$Hz.
$(input)
"""
    end
end

# ╔═╡ 2d89a043-dfd3-4662-8c29-8829987fa39c
@bind modes confirm(mode_input())

# ╔═╡ b79f409d-a91e-4e4b-8e16-dff4769924f6
md"### Plots"

# ╔═╡ 730defe8-8e5e-4162-88d4-0766e7df5c7b
function plot_roots(x1, x2, cgrid)

    f1 = subs_βρ(x1)
    f2 = subs_βρ(x2)

    a = [f1((inv(c))) for c in cgrid]
    b = [f2((inv(c))) for c in cgrid]

    trace1 = scatter(x=cgrid, y=real.(a), mode="lines", line_color="red", name="real(ex1)")
    trace2 = scatter(x=cgrid, y=imag.(a), mode="lines", line_color="blue", name="imag(ex1)")
    trace3 = scatter(x=cgrid, y=real.(b), mode="lines", line_color="red", line_dash="dash", name="real(ex2)")
    trace4 = scatter(x=cgrid, y=imag.(b), mode="lines", line_color="blue", line_dash="dash", name="imag(ex2)")
    trace5 = scatter(x=[medium.β₁], y=[0], mode="markers", marker_size=8, marker_color="black", marker_symbol="dot", name="β₁")
    trace6 = scatter(x=[medium.β₂], y=[0], mode="markers", marker_size=8, marker_color="black", marker_symbol="line-ns-open", name="β₂")

    layout = Layout(title="F(c)=ex1(c) - ex2(c)",
                    xaxis_title="phase velocity (c)",
                    margin=attr(l=50, r=50, b=50, t=50),
                    legend=attr(x=10, y=1.3),
                    width=700,
                    height=400,
                    xaxis_range=[cgrid[1], cgrid[end]])

    plot([trace1, trace2, trace3, trace4, trace5, trace6], layout)
end

# ╔═╡ ca8f817d-8715-40d4-9f48-ded6a79b421e
plot_roots(ex1, ex2, crange1)

# ╔═╡ ed15bab9-c0dd-467a-93cf-e6edb5f03216
plot_roots(ex1, ex2, crange2)

# ╔═╡ ffb3cf31-0d33-48eb-9be0-cfa4e009b315
plot_roots(ex1, ex2, crange3)

# ╔═╡ 1b0fa006-6679-42ba-896e-990b7a3fa2ef
function plot_Love_waves(t)
    # we need to discretize space before plotting 
    xgrid = range(-100, stop=100, length=100)
    zgrid1 = range(0, stop=medium.Hp, length=100)
    zgrid2 = range(medium.Hp, stop=200, length=100)

    U1p = map(modes.c) do c
        return broadcast(Iterators.product(zgrid1, xgrid)) do (z, x)
			real(U1(x, z, t, inv(c)))
		end
    end
    U2p = map(modes.c) do c
        return broadcast(Iterators.product(zgrid2, xgrid)) do (z, x)
			real(U2(x, z, t, inv(c)))
		end
    end

    trace1 = heatmap(y=zgrid1, x=xgrid, zauto=false, zmin=-5, zmax=5, colorscale="RdBu", z=sum(U1p), showscale=false)
    trace2 = heatmap(y=zgrid2, x=xgrid, zauto=false, zmin=-5, zmax=5, colorscale="RdBu", z=sum(U2p), showscale=false,)

    layout = Layout(
        title="Love-wave Displacement",
        xaxis_title="Distance (x)",
        yaxis_title="Depth (z)",
		width=600,
        height=500,
        yaxis_scaleanchor="x",
        yaxis_scaleratio=1,
		yaxis_autorange="reversed",
        shapes=[Shape("a", type="line", x0=xgrid[1], y0=medium.Hp, x1=xgrid[end], y1=medium.Hp, line=attr(color="black", width=5)), Shape("b", type="line", x0=xgrid[1], y0=0, x1=xgrid[end], y1=0, line=attr(color="black", width=5, dash="dot"))
        ],
		annotations = [
    # annotation for the first line
    attr(
        text="Boundary",
        xref="paper", yref="y",
        x=0.1, y=medium.Hp,
        font=attr(size=12),
        showarrow=false, borderpad=4, bgcolor="white",
    ),
    # annotation for the second line
    attr(
        text="Free Surface",
        xref="paper", yref="y",
        x=0.1, y=0,
        font=attr(size=12),
        showarrow=false, borderpad=4, bgcolor="white",
    )
		],
        legend=attr(x=0, y=-0.3, traceorder="reversed")
    )

    return plot([trace1, trace2], layout)
end

# ╔═╡ fefb338f-0b89-4902-a85f-c8f87cf5c172
plot_Love_waves(mod(tt, 10))

# ╔═╡ 16c826bf-fa48-423c-bfec-195f7fc502f8
md"""
## TODO
- Have a plot that shows how a wavelet disperses as it propagates, which needs a sum of frequencies, with some initial phases assigned.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
PlutoPlotly = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Roots = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
SymbolicUtils = "d1185830-fcd6-423d-90d6-eec64667417b"
Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"

[compat]
LaTeXStrings = "~1.3.0"
Latexify = "~0.15.18"
PlutoPlotly = "~0.3.6"
PlutoTeachingTools = "~0.2.8"
PlutoUI = "~0.7.50"
Roots = "~2.0.10"
SymbolicUtils = "~1.0.4"
Symbolics = "~5.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "6d52942e1a04b5477ab70714a60fb7e970bff289"

[[deps.AbstractAlgebra]]
deps = ["GroupsCore", "InteractiveUtils", "LinearAlgebra", "MacroTools", "Markdown", "Random", "RandomExtensions", "SparseArrays", "Test"]
git-tree-sha1 = "a69dbe3b376ace7d9eebe2db43216e8b52ba6da9"
uuid = "c3fe647b-3220-5bb0-a1ea-a7954cac585d"
version = "0.29.2"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cc37d689f599e8df4f464b2fa3870ff7db7492ef"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SnoopPrecompile", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "38911c7737e123b28182d89027f4216cfc8a9da7"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bijections]]
git-tree-sha1 = "fe4f8c5ee7f76f2198d5c2a06d3961c249cce7bd"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.4"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "d730914ef30a06732bdd9f763f6cc32e92ffbff1"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSolve]]
git-tree-sha1 = "9441451ee712d1aec22edad62db1a9af3dc8d852"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.3"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.CompositeTypes]]
git-tree-sha1 = "02d2316b7ffceff992f3096ae48c7829a8aa0638"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.3"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "89a9db8d28102b094992472d333674bd1a83ce2a"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "a4ad7ef19d2cdc2eff57abbbe68032b1cd0bd8f8"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.13.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "13027f188d26206b9e7b863036f87d2f2e7d013a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.87"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "698124109da77b6914f64edd696be8dccf90229e"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.6.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.DynamicPolynomials]]
deps = ["DataStructures", "Future", "LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Pkg", "Reexport", "Test"]
git-tree-sha1 = "8b84876e31fa39479050e2d3395c4b3b210db8b0"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.4.6"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.ExprTools]]
git-tree-sha1 = "c1d06d129da9f55715c6c212866f5b1bddc5fa00"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.9"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "fc86b4fd3eff76c3ce4f5e96e2fdfa6282722885"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.0.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "00e252f4d706b3d55a8863432e742bf5717b498d"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.35"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "1cd7f0af1aa58abc02ea1d872953a97359cb87fa"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.4"

[[deps.Groebner]]
deps = ["AbstractAlgebra", "Combinatorics", "Logging", "MultivariatePolynomials", "Primes", "Random"]
git-tree-sha1 = "827f29c95676735719f8d6acbf0a3aaf73b3c9e5"
uuid = "0b43b601-686d-58a3-8a1c-6623616c7cd4"
version = "0.3.2"

[[deps.GroupsCore]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9e1a5e9f3b81ad6a5c613d181664a0efc6fe6dd7"
uuid = "d5909c97-4eac-4ecc-a3dc-fdd0858a4120"
version = "0.4.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "d926e9c297ef4607866e8ef5df41cde1a642917f"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.14"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "f366daebdfb079fd1fe4e3d560f99a0c892e15bc"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "16c0cc91853084cb5f58a78bd209513900206ce6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "6a125e6a4cb391e0b9adbd1afa9e771c2179f8ef"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.23"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LabelledArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "LinearAlgebra", "MacroTools", "PreallocationTools", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "cd04158424635efd05ff38d5f55843397b7416a9"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.14.0"

[[deps.LambertW]]
git-tree-sha1 = "c5ffc834de5d61d00d2b0e18c96267cffc21f648"
uuid = "984bce1d-4616-540c-a9ee-88d1112d94c9"
version = "0.4.6"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

[[deps.Lazy]]
deps = ["MacroTools"]
git-tree-sha1 = "1370f8202dac30758f3c345f9909b97f53d87d3f"
uuid = "50d2b5c4-7a5e-59d5-8109-a42b560f39c0"
version = "0.15.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MultivariatePolynomials]]
deps = ["ChainRulesCore", "DataStructures", "LinearAlgebra", "MutableArithmetics"]
git-tree-sha1 = "eaa98afe2033ffc0629f9d0d83961d66a021dfcc"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.4.7"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "3295d296288ab1a0a2528feb424b854418acff57"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.2.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoPlotly]]
deps = ["AbstractPlutoDingetjes", "Colors", "Dates", "HypertextLiteral", "InteractiveUtils", "LaTeXStrings", "Markdown", "PlotlyBase", "PlutoUI", "Reexport"]
git-tree-sha1 = "dec81dcd52748ffc59ce3582e709414ff78d947f"
uuid = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
version = "0.3.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "b970826468465da71f839cdacc403e99842c18ea"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.8"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff", "Requires"]
git-tree-sha1 = "f739b1b3cc7b9949af3b35089931f2b58c289163"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.12"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "311a2aa90a64076ea0fac2ad7492e914e6feeb81"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RandomExtensions]]
deps = ["Random", "SparseArrays"]
git-tree-sha1 = "062986376ce6d394b23d5d90f01d81426113a3c9"
uuid = "fb686558-2515-59ef-acaa-46db3789a887"
version = "0.4.3"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "140cddd2c457e4ebb0cdc7c2fd14a7fbfbdf206e"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.38.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "feafdc70b2e6684314e188d95fe66d116de834a7"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.2"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.Roots]]
deps = ["ChainRulesCore", "CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "b45deea4566988994ebb8fb80aa438a295995a6e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.0.10"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "f139e81a81e6c29c40f1971c9e5309b09c03f2c3"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.6"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SciMLBase]]
deps = ["ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "Preferences", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "SnoopPrecompile", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables", "TruncatedStacktraces"]
git-tree-sha1 = "392d3e28b05984496af37100ded94dc46fa6c8de"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.91.7"

[[deps.SciMLOperators]]
deps = ["ArrayInterface", "DocStringExtensions", "Lazy", "LinearAlgebra", "Setfield", "SparseArrays", "StaticArraysCore", "Tricks"]
git-tree-sha1 = "e61e48ef909375203092a6e83508c8416df55a83"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "b8d897fe7fa688e93aef573711cb207c08c9e11e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.19"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SymbolicIndexingInterface]]
deps = ["DocStringExtensions"]
git-tree-sha1 = "f8ab052bfcbdb9b48fad2c80c873aa0d0344dfe5"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.2.2"

[[deps.SymbolicUtils]]
deps = ["AbstractTrees", "Bijections", "ChainRulesCore", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "IfElse", "LabelledArrays", "LinearAlgebra", "MultivariatePolynomials", "NaNMath", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "TimerOutputs", "Unityper"]
git-tree-sha1 = "bfbd444c209b41c7b2fef36b6e146a66da0be9f1"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "1.0.4"

[[deps.Symbolics]]
deps = ["ArrayInterface", "ConstructionBase", "DataStructures", "DiffRules", "Distributions", "DocStringExtensions", "DomainSets", "Groebner", "IfElse", "LaTeXStrings", "LambertW", "Latexify", "Libdl", "LinearAlgebra", "MacroTools", "Markdown", "NaNMath", "RecipesBase", "Reexport", "Requires", "RuntimeGeneratedFunctions", "SciMLBase", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicUtils", "TreeViews"]
git-tree-sha1 = "7ecd651e3829d2957478516e92f693f12d5b4781"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "5.2.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f2fd3f288dfc6f507b0c3a2eb3bac009251e548b"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.22"

[[deps.TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.TruncatedStacktraces]]
deps = ["InteractiveUtils", "MacroTools", "Preferences"]
git-tree-sha1 = "7bc1632a4eafbe9bd94cf1a784a9a4eb5e040a91"
uuid = "781d530d-4396-4725-bb49-402e4bee1e77"
version = "1.3.0"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Unityper]]
deps = ["ConstructionBase"]
git-tree-sha1 = "d5f4ec8c22db63bd3ccb239f640e895cfde145aa"
uuid = "a7c27f48-0311-42f6-a7f8-2c11e75eb415"
version = "0.1.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═9b02e72d-be6b-485d-a186-ba2fe2dcd6fb
# ╠═bdf3d004-653a-4b56-af7c-42ca1d6021e5
# ╟─2a41b15e-1a0e-4c92-a3a5-53603faacea1
# ╟─87b80ede-1da7-4c24-ada9-4327f0bb755e
# ╟─fefb338f-0b89-4902-a85f-c8f87cf5c172
# ╟─19a31e92-8226-4ce5-aa04-933552953a9d
# ╟─2d89a043-dfd3-4662-8c29-8829987fa39c
# ╠═8d2fd2d9-da36-43f4-8dcb-dd931c8189f5
# ╠═25f32a28-4c57-4ed0-9fc4-4a40ca31e4dd
# ╟─d8b52234-757b-441d-918d-585fd6593fcf
# ╠═b120da8e-dcd6-4280-819b-0e20b4675080
# ╠═c74c4a58-b47e-4509-aadd-7400c350ff6c
# ╠═44aa241c-bf9d-4a2a-b459-28a73a991606
# ╠═5896fa94-ab7f-42f0-9fac-265e11faba2b
# ╟─6e734951-2907-49d7-ae88-dffc463bf8a3
# ╠═2f40cb44-60af-4fbe-8f73-d8d06e99fc3b
# ╠═4d859323-12e0-4fba-a796-48995f980f33
# ╟─79c4f3a4-65b6-4e02-9786-f168584c7781
# ╠═dc709a17-ab03-406f-b232-d7658872a95e
# ╠═83e2b2b3-f84a-4926-9332-b5570d52be8b
# ╠═52c90f98-d314-4c5f-8b8d-4aff4c32b6d9
# ╟─d6dc2422-6be3-447e-b7c1-be655971b6f7
# ╠═1a13363a-9f8f-4123-9b37-c6dcad1ccdde
# ╠═2f80cfcf-9788-41a3-8797-cd1965216738
# ╟─de304d8c-253e-4cb5-8332-db79de20991c
# ╠═30219c41-a040-4056-adda-ce64ac3c6969
# ╟─e1ab342d-84fe-4c00-9756-455436b0fad7
# ╠═ca377428-d597-47a2-b29e-f40884697bd6
# ╠═b819ce05-628a-49b6-aa57-f1ee765fb027
# ╠═53799d32-3edc-4416-a928-868ea974c6bd
# ╟─f39b1e01-c16e-405e-a2fc-85408d53c762
# ╠═b3924a35-6565-46c4-9a6e-d29b1172668e
# ╠═30f26e47-0a37-4165-b18b-a20f1148deb1
# ╠═f7b5adba-09ca-4895-8b18-5fc84b752392
# ╠═8f35d8b0-ff20-442c-b5b2-f5a2616fe345
# ╟─dab840e2-7d7c-4f65-b4ea-289babc430c8
# ╠═644637c9-c32d-4335-af59-3452263a9707
# ╠═09a8041d-6443-4e83-8443-e0e2aa05317a
# ╠═0fc4d1a1-25ac-49c9-b74b-a9f26928c652
# ╟─794a1f79-708d-4305-8aa0-d2673f34e31f
# ╠═7bd5a551-3379-4270-81d0-9506292e6d8c
# ╠═b3e662bf-8d13-418b-886c-b29456d62454
# ╠═3fa22358-6d61-4b9a-9aa8-39d2b1c6a917
# ╠═bfb54c6f-a52c-4a10-87c7-9788f2f63629
# ╠═cbbae944-5377-44a4-ae32-868a75625248
# ╠═ca8f817d-8715-40d4-9f48-ded6a79b421e
# ╠═ed15bab9-c0dd-467a-93cf-e6edb5f03216
# ╠═ffb3cf31-0d33-48eb-9be0-cfa4e009b315
# ╟─b5c5f1d0-0075-4727-a6a9-8b20d6f65bc4
# ╠═ad269679-e1f9-4d9d-827f-468e36f27bfc
# ╟─b2858a78-4498-4374-9ee0-c68f3dfca6e8
# ╠═cc173455-2ed0-42f3-a9c0-0dfdbbe982ee
# ╠═ad78f0ef-460d-4b62-8bbc-0f7059214b38
# ╟─df35e923-b43c-4809-a9db-32a371fc9010
# ╠═928f806a-3cc2-11ed-09c8-7f3b53b830e2
# ╠═840a743a-e298-4f99-ae6e-11c85b6f5bc5
# ╠═355e039d-db6d-48b4-a7d7-5f73686e6d56
# ╟─7bd19e44-b4f5-43f3-b6be-b557ca95c67f
# ╠═cdaefb2c-818e-4d66-b1c3-f6ac8829ba45
# ╠═236e2338-f057-4c33-80e2-7dd8ea9ce206
# ╠═8912a771-1914-42a7-a35b-43cb63971a41
# ╠═d49ae6c9-a4ee-45f0-99c3-ab9f23ab895d
# ╟─db4a22f5-74eb-477e-9426-065dcfd1751c
# ╠═ccbb61f1-c7a1-4cc1-a5c8-0555dd664e16
# ╠═d76e9b6a-a33c-4342-985e-48f8ee91bf71
# ╟─b79f409d-a91e-4e4b-8e16-dff4769924f6
# ╠═730defe8-8e5e-4162-88d4-0766e7df5c7b
# ╠═1b0fa006-6679-42ba-896e-990b7a3fa2ef
# ╟─16c826bf-fa48-423c-bfec-195f7fc502f8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
