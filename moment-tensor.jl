### A Pluto.jl notebook ###
# v0.19.12

#> [frontmatter]
#> title = "Radiation Patterns"
#> description = "See how P and S waves are radiated due to point sources with specified moment tensors."

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

# ╔═╡ 4a6eaf04-1efe-11ed-3e32-6bdb3afcc5b3
begin
    using PlutoUI
	using ForwardDiff
	using Interpolations
	import ForwardDiff.derivative
	using PlutoTeachingTools
    using CairoMakie # a better plotting lib to vis. vector fields
	# WGLMakie.activate!()
	using GeoMakie
    using LinearAlgebra
	import PlutoUI: combine
	using Meshes
	using CoordinateTransformations
	using PlutoTest
	using MeshViz
	set_theme!(theme_ggplot2())
end

# ╔═╡ 1169b57f-60e0-47cf-9e87-e987be9d72fd
md"""
# Far-field P & S Radiation Patterns

The purpose of this notebook is to visualize the far-field particle displacement, for both P and S waves, in a homogeneous medium due to an input seismic moment tensor. In the notebook, for a given input moment tensor, we shall first visualize the equivalent body-force couples and dipoles, then compute the far-field displacement for the equivalent forcing terms (see Aki & Richards; eq. 4.23).

##### [Interactive Seismology Notebooks](https://pawbz.github.io/Interactive-Seismology.jl/)
ES218; August 2022

Instructor: *Pawan Bharadwaj*,
Indian Institute of Science, Bengaluru, India
"""

# ╔═╡ 220ff7e0-2afe-4a29-8781-27f9ba7c8ff7
@bind moment_tensor confirm(PlutoUI.combine() do Child
		components=["x", "y", "z"]
	# components=[1, 2, 3]
		s1=[md"""
		   $(c,"x") $(
		Child(NumberField(range(-1, step=0.1, stop=1), default=0))
		)  $(c,"y") $(
		Child(NumberField(range(-1, step=0.1,stop=1), default=1))
		)  $(c,"z") $(
		Child(NumberField(range(-1, step=0.1, stop=1), default=0))
		)""" for c in components]

		md"""
		
		
		## Input Moment Tensor 
		Each element of the moment tensor is equivalent to a body-force couple.
		$(s1...)

		
		"""
end)

# ╔═╡ 8f53975e-6d81-42f8-8936-c6b952c7913f
warning_box(md"Here, we are **not** forcing the moment tensor to be symmetric!")

# ╔═╡ 01f3e07d-de2d-4efe-82b0-fd1363f32158
@bind body_forces confirm(PlutoUI.combine() do Child
	components=["x", "y", "z"]
	s2=[md"""
		"x" $(
			Child(NumberField(range(-1, step=0.1, stop=1), default=1))
		) "y" $( 
			Child(NumberField(range(-1, step=0.1, stop=1), default=0))
		) "z" $(
			Child(NumberField(range(-1, step=0.1, stop=1), default=0))
		)""" for is in 1:2]
	
md"""
	
## Input Body Forces
	
Add any body forces independent to that of the moment tensor. At the moment, we have 2 body forces.
#### Force I
$(s2[1])
#### Force II
$(s2[2])
"""
end)

# ╔═╡ a220fe12-8611-4630-9fd8-8aaa2a4818bc
md"""
## Force Distribution
"""

# ╔═╡ af057ffd-d750-4f04-8e70-e51b8c2b2a08
md"""
## Displacement Field (2-D projections)
We shall now plot the displacement field projected on either $xy$, $yz$ or $xz$ planes.
"""

# ╔═╡ c25ed391-bf65-472f-9b44-2888a26c18fe
tip(md"The far-field P displacement is curl free, and the far-field S displacement is divergence free.")

# ╔═╡ dc0ed979-2e37-4fbf-972d-b1f30cd7ce23
md"""
## Displacement Field (3D)
"""

# ╔═╡ 89b56471-6339-44c4-a81b-1c58e2fe72fc
tip(md"The above 3D plots from WGLMakie are interactive, so you can use them to train your intuition.")

# ╔═╡ bacfc397-1c38-4184-bbde-f5f81a9a5df3
md"""
## Appendix
"""

# ╔═╡ 5e687f7d-2f91-412d-ab2a-d1da145a5d47
md"""
### Equivalent Forces
Methods the are used to convert the input moment tensor to an equivalent for distribution. 
"""

# ╔═╡ c2983a3b-005e-4de5-b9dc-2692850ff627
xyz=Iterators.product([:x, :y, :z], [:x, :y, :z]); # need an iterator for elements of moment tensor

# ╔═╡ b9fd379b-df75-4ba0-bd4d-0ddc64561e4a
md"""
### Displacement Field in Homogeneous Medium 
"""

# ╔═╡ 3db5e6c8-812f-49d7-a0c7-b00d8bc7f8ff
md"""
The displacement due to, for example, a body force $X_{0}(t)$ applied in the $x_{1}$ direction at the origin is composed of 3 terms: the first term is the near field term which is composed of both P and S-wave motions, the second term is the P-wave far field term and the third term is the S-wave far-field term. The $i$th component of the field is given by:

```math
{u_i}(\mathbf{x},t)=\frac{1}{4\pi\rho}\left(\frac{\partial^2}{\partial x_i \partial x_1}\frac{1}{r}\right)\int_{r/\alpha}^{r/\beta} \tau X_0(t-\tau) \,d\tau+\frac{1}{4\pi\rho\alpha^2r}\left(\frac{\partial r}{\partial x_i}\frac{\partial r}{\partial x_1}\right)X_0\left(t-\frac{r}{\alpha}\right)+
```
```math
\frac{1}{4\pi\rho\beta^2r}\left(\delta_{i1}-\frac{\partial r}{\partial x_i}\frac{\partial r}{\partial x_1}\right)X_0\left(t-\frac{r}{\beta}\right),
```
where, ${\rho}$ is the density of the medium, ${\alpha}$ is the P-wave velocity, ${\beta}$ is the S-wave velocity, ${r}$ is the distance between the source and receiver, ${\tau}$ is the convolution variable for time and ${\delta}_{i1}$ is the Kronecker Delta function.
"""

# ╔═╡ 4e4d324b-4405-402d-bbbf-d9287f7cc29f
α = 5000.0 # P-wave velocity in m/s

# ╔═╡ 96512612-6d21-4f80-b8f6-a9efee9797c8
β = 3000.0 # S-wave velocity in m/s

# ╔═╡ 3c5daacc-baad-4109-83d6-faba39137cf5
rand_receiver=randn(3)

# ╔═╡ eb072a57-352e-47de-af61-f6f6259ea763
rP = 1; rS= 1;

# ╔═╡ 875182de-0955-43ae-9805-6dbb8f44b057
# These are used for multiple dispatch
begin
	struct x end
	struct y end
	struct z end
	struct xy end
	struct yz end
	struct xz end
	struct P end
	struct S end
end

# ╔═╡ 64f2a518-83aa-4770-b421-1b3bc45bc7a2
# Functions that outputs the positions (x, y, z) of the force couples
begin
	dcouple = .5 # half distance b/w the elements of a force couple
	body_force_locations(::x) = [[dcouple, 0.0, 0.0], [-dcouple, 0.0, 0.0]]
	body_force_locations(::y) = [[0.0, dcouple, 0.0], [0.0, -dcouple, 0.0]]
	body_force_locations(::z) = [[0.0, 0.0, dcouple], [0.0, 0.0, -dcouple]]
end

# ╔═╡ e2ed2cef-1767-4586-92ad-fb28947cc4a9
# collect forces (just for plotting)
srclocs=reshape(cat([body_force_locations(eval(x[2])()) for x in xyz]..., dims=1), 1, 1, 9*2);

# ╔═╡ 1839abea-3eef-40cd-8e79-5647bb169364
# Functions that output the components of the forces
begin
	body_force_strengths(f, ::x) = reshape([(1, f), (2,0), (3,0), (1, -f), (2,0), (3,0)], 3, 2)
	body_force_strengths(f, ::y) = reshape([(1, 0), (2,f), (3,0), (1, 0), (2,-f), (3,0)], 3, 2)
	body_force_strengths(f, ::z) = reshape([(1, 0), (2,0), (3,f), (1, 0), (2,0), (3,-f)], 3,2)
end

# ╔═╡ c4f34e9b-8554-409a-aab4-df53e9a1e041
# collect strengths of all elements in the moment tensor X 2 forces (just for plotting)
srcstrength=reshape(cat([body_force_strengths(moment_tensor[i], eval(x[1])()) for (i, x) in enumerate(xyz)]..., dims=2), 1, 3, 9*2);

# ╔═╡ 5bd9de9d-1cbf-4e89-8ab0-ade3181ff4b6
begin
	r(xr, yr, zr, xs=zero(xr), ys=zero(yr), zs=zero(zr)) = sqrt(abs2(xr - xs)+abs2(yr-ys)+abs2(zr-zs))
	dr(::x, xr, yr, zr)= xr / r(xr, yr, zr)
	dr(::y, xr, yr, zr)= yr / r(xr, yr, zr)
	dr(::z, xr, yr, zr)= zr / r(xr, yr, zr)
	# far-field P-wave; ignoring overall amplitude factor
	function g(::Nothing, ::P, xr, yr, zr, rc::Union{x, y, z}, sc::Union{x, y, z}, strength=1.0)		return dr(rc, xr, yr, zr) * dr(sc, xr,yr,zr) / r(xr, yr, zr) * strength
	end
	# far-field S-wave; ignoring overall amplitude factor;
	function g(::Nothing, ::S, xr, yr, zr, rc::Union{x, y, z}, sc::Union{x, y, z}, strength=1.0)
		return (isequal(rc,sc) - dr(rc, xr,yr,zr) * dr(sc, xr,yr,zr)) / r(xr, yr, zr) * strength
	end
	g(dc::Union{x, y, z}, ps::Union{P, S}, xr, yr, zr, rc, sc, strength) = g(nothing, ps, xr, yr, zr, rc, sc, strength)*dr(dc, xr, yr, zr)
	
	# Commented (will include near-field terms as well)
	# g(::x, ps::Union{P, S}, xr, yr, zr, rc, sc, strength) = derivative(x->g(nothing, ps, x, yr, zr, rc, sc, strength), xr)[1]
	# g(::y, ps::Union{P, S}, xr, yr, zr, rc, sc, strength) = derivative(y->g(nothing, ps, xr, y, zr, rc, sc, strength), yr)[1]
	# g(::z, ps::Union{P, S}, xr, yr, zr, rc, sc, strength) = derivative(z->g(nothing, ps, xr, yr, z, rc, sc, strength), zr)[1]
end

# ╔═╡ 559928f4-bac3-4ecd-918a-32c4c3c54119
# combine elements of the moment tensor and body forces together into a simple vector that we can later iterate over
m=vcat(broadcast(moment_tensor, vec(collect(xyz))) do m, c
	(m, eval(c[1])(), eval(c[2])())
end, 
	broadcast(tuple, body_forces, repeat([x(), y(), z()], div(length(body_forces), 3)), nothing)
);

# ╔═╡ a61a40b2-59f7-4aaa-85c2-a159984dfc25
function displacement(ps::Union{P,S}, rx, ry, rz, rc, m=m)
mapreduce(+, m) do c
	g(c[3], ps, rx, ry, rz, rc, c[2], c[1])
end
end

# ╔═╡ 2fabd638-b308-4927-99fe-8bccce404396
# method that computes displacement for all three components
displacement(ps::Union{P,S}, rx, ry, rz)=map(rc->displacement(ps, rx, ry, rz, rc, m), [x(), y(), z()])

# ╔═╡ eb75f980-4d19-438b-83d6-3ea5e1a0a1e0
# test if the P-wave displacement is parallal to r̂
@test all(abs.(cross(displacement(P(), rand_receiver...), rand_receiver)) .< eps())

# ╔═╡ 2d7ca9f8-7575-4b2f-8c2b-80d728a79635
# test if the S-wave displacement is always perpendicular to r̂
@test abs(dot(displacement(S(), rand_receiver...), rand_receiver)) < eps()

# ╔═╡ 2f29f440-4cc6-4ab0-95fe-6baf87c0cd06
begin
	ddisplacement(::x, ps, xr, yr, zr, rc, m=m)=derivative(x->displacement(ps, x, yr, zr, rc, m), xr)[1]
	ddisplacement(::y, ps, xr, yr, zr, rc)=derivative(y->displacement(ps, xr, y, zr, rc, m), yr)[1]
	ddisplacement(::z, ps, xr, yr, zr, rc)=derivative(z->displacement(ps, xr, yr, z, rc, m), zr)[1]
end

# ╔═╡ 4660b617-3d5f-422a-9747-f2405b1a4c29
md"""
We shall now choose the number of points, where the displacement vector is eventually evaluated. For 2D, we uniformly sample the azimuth, and for 3D, we will uniformly sample the surface of a unit sphere.
"""

# ╔═╡ 383bdfca-c621-49d9-9f8d-49221283754f
begin
	# define a cube in R^3
	points_cube=Meshes.Point3.(coordinates.(vertices(Meshes.Box(Meshes.Point(-1,-1,-1), Meshes.Point(1,1,1)))))

	connec_cube = connect.([(1,4,3,2),(5,6,7,8),(1,2,6,5),(3,4,8,7),(1,5,8,4),(2,3,7,6)])
	sphmesh = refine(refine(SimpleMesh(points_cube, connec_cube), CatmullClark()), CatmullClark());
	sphpts = broadcast(coordinates ∘ centroid, collect(elements(sphmesh)))


    n3 = length(sphpts);    n2 = 50
	# a grid for theta (azimuth)
    thgrid = range(-pi, stop = pi, length = n2)
	nothing
end

# ╔═╡ 9b735440-d831-4249-8083-d1469d8176a0
begin
	cart3D(r, sphpt)=r.*sphpt;
	cart2D(r, th)=[r*sin(th), r*cos(th)];
	cart2D(r, th, ::xy)=[r*sin(th), r*cos(th), 0];
	cart2D(r, th, ::yz)=[0, r*sin(th), r*cos(th)];
	cart2D(r, th, ::xz)=[r*sin(th), 0,  r*cos(th)];
	proj2D(ux, uy, uz, ::xy)=ux, uy
	proj2D(ux, uy, uz, ::yz)=uy, uz
	proj2D(ux, uy, uz, ::xz)=ux, uz
end

# ╔═╡ 8f1cc2eb-5c79-47a5-a35e-995d1e5d8775
function displacement2D(ps::Union{P,S}, plane::Union{xy, yz, xz})
	return map(c->broadcast(th->displacement(ps, cart2D(1.0, th, plane)..., c), thgrid), [x(), y(), z()])
end

# ╔═╡ e9450f23-8879-4b49-9689-c50c755463f0
function displacement3D(ps::Union{P,S})
	return map(c->broadcast(sphpt->displacement(ps, cart3D(1.0, sphpt)..., c), sphpts), [x(), y(), z()])
end

# ╔═╡ 2110ae2c-26ac-4f35-b392-897581ff4f5b
md"""
### Packages
"""

# ╔═╡ a09edfd9-64d6-413a-8766-e20d0b1ef8ba
TableOfContents()

# ╔═╡ 4f3e43cd-4f35-46b2-a972-0cc8f2ac7b3f
md"""
### Plotting Methods
"""

# ╔═╡ e2177159-23c1-42bd-a5f8-7fb46d68a31f
md"""
We are only interested in vis. of the direction of displacement. So lets define some function to normalize the fields and remove geometrical spreading.
"""

# ╔═╡ e453aca7-6d3c-421e-83bb-eb772cb001b2
function unormalize(args...)
	# fact=inv(norm(cat(args..., dims=3)))
	# return map(u->u .* fact, [args...])
	return args
end

# ╔═╡ 9c94f9ef-7241-4dd9-ab59-47bcc148a9bc
function get_arrow_sizes(args...)
	a = vec(sqrt.(sum(map(x->abs2.(x),  [args...]))))
    a = a * 10
end

# ╔═╡ b295b338-f97a-4c75-af23-f5ae291a12f2
md"""
Now lets work on plotting 2D/ 3D arrow heads using `Makie.jl`.
"""

# ╔═╡ 11d8323a-66e9-48e3-83f9-5b94c776dc09
begin
	function plotsources()
	ps = Figure(resolution = (800, 800))
    Axis3(
        ps[1, 1],
        xlabel = "x (m)",
        ylabel = "y (m)",
		zlabel = "z (m)",
        title = "Equivalent Force Distribution",
		    )
	limits!(-5, 5, -5, 5, -5, 5)
	arrows!(
		    vec(getindex.(srclocs, 1)), vec(getindex.(srclocs, 2)), vec(getindex.(srclocs, 3)), vec(getindex.(srcstrength[1,1,:],2)),
		vec(getindex.(srcstrength[1,2,:],2)), 
		vec(getindex.(srcstrength[1,3,:],2)), 
				  linecolor=:black, 
		# arrowsize=vec(ap3),
		arrowsize=0.5*Makie.Vec3f(1, 1, 1),
		lengthscale=1,
				arrowcolor=:black,
	    linewidth = 0.05,
	)
	return ps
	end
end

# ╔═╡ b2c260ad-2577-45cc-83ed-105d3d42f419
plotsources()

# ╔═╡ 873277ce-a1c0-456c-8964-a3b973e9f41e
function plot_displacement_2D()
	f2 = Figure(resolution = (800, 1200))
	for (i,dim) in enumerate([["x","y"], ["y","z"], ["x","z"]])
		plane=eval(Symbol(dim...))()
	up1, up2, up3 = displacement2D(P(), plane);
	us1, us2, us3 = displacement2D(S(), plane);
	
	# prepare for 2-D vis.
	up1_plot, up2_plot, up3_plot, us1_plot, us2_plot, us3_plot= unormalize(up1, up2, up3, us1, us2, us3)
	up1_plot, up2_plot = proj2D(up1_plot, up2_plot, up3_plot, plane)
	us1_plot, us2_plot = proj2D(us1_plot, us2_plot, us3_plot, plane)

	pp2 = vec(broadcast(x->Makie.Point2f(cart2D(rP,x)), thgrid))
	ps2 = vec(broadcast(x->Makie.Point2f(cart2D(rS,x)), thgrid))
    ns2 = broadcast((x, y) -> Makie.Vec2f(x, y), us1_plot, us2_plot)
    np2 = broadcast((x, y) -> Makie.Vec2f(x, y), up1_plot, up2_plot)
    ap2 = get_arrow_sizes(up1_plot, up2_plot)
    as2 = get_arrow_sizes(us1_plot, us2_plot)
	
    Axis(
        f2[i, 1],
        xlabel = "$(dim[1]) (m)",
        ylabel = "$(dim[2]) (m)",
        title = "Displacement field ($(dim...)) slice",
		aspect=1
    )

    arrows!(pp2, np2, lengthscale = 0.1, arrowcolor = :blue, linecolor=:blue,arrowsize = ap2, xlabel = "x", align=:center)
			
    Axis(
        f2[i, 2],
        xlabel = "$(dim[1]) (m)",
        ylabel = "$(dim[2]) (m)",
        title = "Displacement field ($(dim...)) slice",
    )
    arrows!(ps2, ns2, lengthscale = 0.1, arrowcolor = :red, linecolor=:red, arrowsize = as2, align=:center)
	
    
	end
	f2
	
end

# ╔═╡ 3a39ae6e-d4eb-4d1f-99dc-210bb6a22772
plot_displacement_2D()

# ╔═╡ 32aec472-4002-42ff-b67c-2c08fe3fa0bc
function plot_displacement_3D()

	uxp3, uyp3, uzp3 = displacement3D(P());
	uxs3, uys3, uzs3 = displacement3D(S());
	
	# prepare for 3-D vis.
	uxp3_plot, uyp3_plot, uzp3_plot, uxs3_plot, uys3_plot, uzs3_plot = unormalize(uxp3, uyp3, uzp3, uxs3, uys3, uzs3)
	
	pp3 = vec(broadcast(x->Makie.Point3f(cart3D(rP, x)), sphpts))
	ps3 = vec(broadcast(x->Makie.Point3f(cart3D(rS, x)), sphpts))
	ns3 = broadcast((x, y, z) -> Makie.Vec3f(x, y, z), uxs3_plot, uys3_plot, uzs3_plot)
    np3 = broadcast((x, y, z) -> Makie.Vec3f(x, y, z), uxp3_plot, uyp3_plot, uzp3_plot)
    ap3 = get_arrow_sizes(uxp3_plot, uyp3_plot, uzp3_plot)
    as3 = get_arrow_sizes(uxs3_plot, uys3_plot, uzs3_plot)
	f3 = Figure(resolution = (800, 800))
    Axis3(
        f3[1, 1],
        xlabel = "x (m)",
        ylabel = "y (m)",
		zlabel = "z (m)",
        title = "Displacement field"
    )
	global Pcolors=broadcast((ux, uy, uz, s)->dot(s, [ux, uy, uz]), uxp3, uyp3, uzp3, sphpts)
	viz!(sphmesh, color=Pcolors, alpha=0.5)
	arrows!(
		    getindex.(pp3, 1), getindex.(pp3, 2), getindex.(pp3, 3), vec(uxp3_plot), vec(uyp3_plot), vec(uzp3_plot);
		  linecolor=:black, 
		# arrowsize=vec(ap3),
		arrowsize = 0.1*Makie.Vec3f(1, 1, 1),
		lengthscale=0.1,
				arrowcolor=:blue,
	    linewidth = 0.02, align=:center
	)
	 Axis3(
        f3[2, 1],
        xlabel = "x (m)",
        ylabel = "y (m)",
		zlabel = "z (m)",
        title = "Displacement field",
    )
	# limits!(-rP, rP, -rP, rP, -rP, rP)	
viz!(sphmesh, color = :gray, alpha=0.1)
	arrows!(#ps3, ns3,
	    getindex.(ps3, 1), getindex.(ps3, 2), getindex.(ps3, 3), vec(uxs3_plot), vec(uys3_plot), vec(uzs3_plot);
		  linecolor=:black, 
		lengthscale=0.1,
		arrowsize = 0.1*Makie.Vec3f(1, 1, 1),
		# arrowsize=vec(ap3),
		arrowcolor=:red,
	    linewidth = 0.02, align=:center
	)	
	f3
end

# ╔═╡ 98442df9-beac-41c4-aeb8-490b3377ccc8
plot_displacement_3D()

# ╔═╡ 473acfd0-0a69-4426-af47-4ac283965431

TODO()


# ╔═╡ e4721ad5-e407-47ed-89c9-6ca3d099c9ad
md"""
* Have beachballs plotted for a given moment tensor.
* Choose the moment tensors corresponding to strike-slip, normal, reverse, and oblique faults. Explain your choices and plot the corresponding radiation patterns.
"""

# ╔═╡ ada78100-ede9-4b42-a04f-eb87461ce9fc
begin
lons =  rad2deg.(getfield.(SphericalFromCartesian().(sphpts), :θ))
lats =  rad2deg.(getfield.(SphericalFromCartesian().(sphpts), :ϕ))

# 	lons1 = -180:180
# lats1 = -90:90
	I = sortperm(lons)
	lons = lons[I]
	lats = lats[I]
# 
	field=Pcolors[I]
	
	field .-= sum(field)
	field=sign.(field)
	# itp = interpolate((lons,) , field, Gridded(Linear()))
	

	# field = [itp[l, y] for l in lons1, y in lats1]
	
	fig = Figure()
	ax1 = GeoAxis(fig[1, 1], dest = "+proj=vitk1 +lat_1=0 +lat_2=96",
	    coastlines = false, aspect=1)
	heatmap!(ax1, lons, lats, field; shading = false, colormap = :viridis)
	fig
end

# ╔═╡ e10dd2e3-9753-4745-97ee-c40ad1621491
broadcast(coordinates ∘ centroid, collect(elements(sphmesh)))

# ╔═╡ 26390557-abfa-4495-b94f-1dd4e639faa3
# broadcast(coordinates centroid, collect(elements(sphmesh)))

# ╔═╡ d377fe49-08fe-49d4-b85d-990f3f8b4503
 rad2deg.(getfield.(SphericalFromCartesian().(sphpts), :ϕ))

# ╔═╡ 46a5ffa0-7c12-4561-9fb8-8ac6f4fa57f9
unique(lats)

# ╔═╡ 11cf79d3-efd5-494f-abed-c22a4a29ce21
sortperm

# ╔═╡ 51fcd87e-a560-442f-a933-e1c6dc95bba5
Pcolors .- sum(Pcolors)

# ╔═╡ 7b0a5157-ab2c-414e-9f4c-74b041a91cd1
field

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CoordinateTransformations = "150eb455-5306-5404-9cee-2592286d6298"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
GeoMakie = "db073c08-6b98-4ee5-b6a4-5efafb3259c6"
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
MeshViz = "9ecf9c4f-6e5a-4b5e-83ae-06f2c7a661d8"
Meshes = "eacbb407-ea5a-433e-ab97-5258b1ca43fa"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CairoMakie = "~0.8.13"
CoordinateTransformations = "~0.6.2"
ForwardDiff = "~0.10.32"
GeoMakie = "~0.4.2"
Interpolations = "~0.14.5"
MeshViz = "~0.5.0"
Meshes = "~0.23.1"
PlutoTeachingTools = "~0.1.7"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "f2e63cf4b52d27ffef023661085c68471dc64f07"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA"]
git-tree-sha1 = "387e0102f240244102814cf73fe9fbbad82b9e9e"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.8.13"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5f5a975d996026a8dd877c35fe26a7b8179c02ba"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.6"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "8a494fe0c4ae21047f28eb48ac968f0b8a6fcaa7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.4"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CircularArrays]]
deps = ["OffsetArrays"]
git-tree-sha1 = "3587fdbecba8c44f7e7285a1957182711b95f580"
uuid = "7a955b69-7140-5f4e-a0ed-f168c5e2e749"
version = "1.3.1"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "1833bda4a027f4b2a1c984baddcf755d77266818"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.0"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

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

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "992a23afdb109d0d2f8802a30cf5ae4b1fe7ea68"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "8579b5cdae93e55c0cff50fbb0c2d1220efd5beb"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.70"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "94f5101b96d2d968ace56f7f2db19d0a5f592e28"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.15.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "b5c7fe9cea653443736d264b85466bad8c574f4a"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.9"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GeoInterface]]
deps = ["RecipesBase"]
git-tree-sha1 = "6b1a29c757f56e0ae01a35918a2c39260e2c4b98"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "0.5.7"

[[deps.GeoJSON]]
deps = ["GeoInterface", "JSON3"]
git-tree-sha1 = "4764da92d333658552b2bedc9f6b379f017c727b"
uuid = "61d90e0f-e114-555e-ac52-39dfb47a3ef9"
version = "0.5.1"

[[deps.GeoMakie]]
deps = ["Colors", "Downloads", "GeoInterface", "GeoJSON", "GeometryBasics", "ImageIO", "LinearAlgebra", "Makie", "Proj", "Reexport", "Statistics", "StructArrays"]
git-tree-sha1 = "dd17cf50e517d04966aa9dd13fbdaee6e64e7a21"
uuid = "db073c08-6b98-4ee5-b6a4-5efafb3259c6"
version = "0.4.2"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "53c7e69a6ffeb26bd594f5a1421b889e7219eeaa"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

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

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "f67b55b6447d36733596aea445a9f119e83498b6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.5"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "076bb0da51a8c8d1229936a1af7bdfacd65037e1"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.2"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

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

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "f1572de22c866dc92aea032bc89c2b137cbddd6a"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.10.0"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "1a43be956d433b5d0321197150c2f94e16c0aaa0"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.16"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "41d162ae9c868218b1f3fe78cba878aa348c2d26"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.1.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "b0323393a7190c9bf5b03af442fc115756df8e59"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.17.13"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "fbf705d2bdea8fc93f1ae8ca2965d8e03d4ca98c"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.4.0"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "114ef48a73aea632b8aebcb84f796afcc510ac7c"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.4.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MeshViz]]
deps = ["CategoricalArrays", "ColorSchemes", "Colors", "Makie", "Meshes", "Tables"]
git-tree-sha1 = "96ddea37b98481f9be4150d1fce09586520b231a"
uuid = "9ecf9c4f-6e5a-4b5e-83ae-06f2c7a661d8"
version = "0.5.0"

[[deps.Meshes]]
deps = ["CategoricalArrays", "CircularArrays", "Distances", "IterTools", "IteratorInterfaceExtensions", "LinearAlgebra", "NearestNeighbors", "Random", "RecipesBase", "ReferenceFrameRotations", "SparseArrays", "SpecialFunctions", "StaticArrays", "StatsBase", "TableTraits", "Tables"]
git-tree-sha1 = "2e8fa01cd89ccfeb9dcb78e1a6ca6583e824c98c"
uuid = "eacbb407-ea5a-433e-ab97-5258b1ca43fa"
version = "0.23.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "0e353ed734b1747fc20cd4cba0edd9ac027eff6a"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.11"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "dfd8d34871bc3ad08cd16026c1828e271d554db9"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.1"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "e925a64b8585aa9f4e3047b8d2cdc3f0e79fd4e4"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.16"

[[deps.PROJ_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Libtiff_jll", "Pkg", "SQLite_jll"]
git-tree-sha1 = "fcb3f39ae1184a056ecc415863d46d2109aa6947"
uuid = "58948b4f-47e0-5654-a9ad-f609743f8632"
version = "900.100.0+0"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a121dfbba67c94a5bec9dde613c3d0cbcf3a12b"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.3+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "67c917d383c783aeadd25babad6625b834294b30"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.1.7"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.Proj]]
deps = ["CEnum", "CoordinateTransformations", "NetworkOptions", "PROJ_jll"]
git-tree-sha1 = "a67bfa088ffc52a684808efeb0d1cebc3a3a7af7"
uuid = "c94c279d-25a6-4763-9509-64d165bea63e"
version = "1.1.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.ReferenceFrameRotations]]
deps = ["Crayons", "LinearAlgebra", "Printf", "Random", "StaticArrays"]
git-tree-sha1 = "ec9bde2e30bc221e05e20fcec9a36a9c315e04a6"
uuid = "74f56ac7-18b3-5285-802d-d4bd4f104033"
version = "3.0.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
git-tree-sha1 = "7dbc15af7ed5f751a82bf3ed37757adf76c32402"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.1"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "e7c1d14d4c93e2d0f85970f818052de200eba5d2"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.39.2+0"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "dfec37b90740e3b9aa5dc2613892a3fc155c3b42"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.6"

[[deps.StaticArraysCore]]
git-tree-sha1 = "ec2bd695e905a3c755b33026954b119ea17f2d22"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.3.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

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

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78736dab31ae7a53540a6b752efc61f77b304c5b"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.8.6+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─1169b57f-60e0-47cf-9e87-e987be9d72fd
# ╟─220ff7e0-2afe-4a29-8781-27f9ba7c8ff7
# ╟─8f53975e-6d81-42f8-8936-c6b952c7913f
# ╟─01f3e07d-de2d-4efe-82b0-fd1363f32158
# ╠═a220fe12-8611-4630-9fd8-8aaa2a4818bc
# ╠═b2c260ad-2577-45cc-83ed-105d3d42f419
# ╟─af057ffd-d750-4f04-8e70-e51b8c2b2a08
# ╠═3a39ae6e-d4eb-4d1f-99dc-210bb6a22772
# ╟─c25ed391-bf65-472f-9b44-2888a26c18fe
# ╟─dc0ed979-2e37-4fbf-972d-b1f30cd7ce23
# ╠═98442df9-beac-41c4-aeb8-490b3377ccc8
# ╟─89b56471-6339-44c4-a81b-1c58e2fe72fc
# ╟─bacfc397-1c38-4184-bbde-f5f81a9a5df3
# ╟─5e687f7d-2f91-412d-ab2a-d1da145a5d47
# ╠═c2983a3b-005e-4de5-b9dc-2692850ff627
# ╠═c4f34e9b-8554-409a-aab4-df53e9a1e041
# ╠═e2ed2cef-1767-4586-92ad-fb28947cc4a9
# ╠═64f2a518-83aa-4770-b421-1b3bc45bc7a2
# ╠═1839abea-3eef-40cd-8e79-5647bb169364
# ╟─b9fd379b-df75-4ba0-bd4d-0ddc64561e4a
# ╟─3db5e6c8-812f-49d7-a0c7-b00d8bc7f8ff
# ╠═4e4d324b-4405-402d-bbbf-d9287f7cc29f
# ╠═96512612-6d21-4f80-b8f6-a9efee9797c8
# ╠═5bd9de9d-1cbf-4e89-8ab0-ade3181ff4b6
# ╠═559928f4-bac3-4ecd-918a-32c4c3c54119
# ╠═a61a40b2-59f7-4aaa-85c2-a159984dfc25
# ╠═2fabd638-b308-4927-99fe-8bccce404396
# ╠═3c5daacc-baad-4109-83d6-faba39137cf5
# ╠═eb75f980-4d19-438b-83d6-3ea5e1a0a1e0
# ╠═2d7ca9f8-7575-4b2f-8c2b-80d728a79635
# ╠═2f29f440-4cc6-4ab0-95fe-6baf87c0cd06
# ╠═eb072a57-352e-47de-af61-f6f6259ea763
# ╠═8f1cc2eb-5c79-47a5-a35e-995d1e5d8775
# ╠═e9450f23-8879-4b49-9689-c50c755463f0
# ╠═875182de-0955-43ae-9805-6dbb8f44b057
# ╟─4660b617-3d5f-422a-9747-f2405b1a4c29
# ╠═383bdfca-c621-49d9-9f8d-49221283754f
# ╠═9b735440-d831-4249-8083-d1469d8176a0
# ╟─2110ae2c-26ac-4f35-b392-897581ff4f5b
# ╠═4a6eaf04-1efe-11ed-3e32-6bdb3afcc5b3
# ╠═a09edfd9-64d6-413a-8766-e20d0b1ef8ba
# ╟─4f3e43cd-4f35-46b2-a972-0cc8f2ac7b3f
# ╟─e2177159-23c1-42bd-a5f8-7fb46d68a31f
# ╠═e453aca7-6d3c-421e-83bb-eb772cb001b2
# ╠═9c94f9ef-7241-4dd9-ab59-47bcc148a9bc
# ╟─b295b338-f97a-4c75-af23-f5ae291a12f2
# ╠═11d8323a-66e9-48e3-83f9-5b94c776dc09
# ╠═873277ce-a1c0-456c-8964-a3b973e9f41e
# ╠═32aec472-4002-42ff-b67c-2c08fe3fa0bc
# ╟─473acfd0-0a69-4426-af47-4ac283965431
# ╠═e4721ad5-e407-47ed-89c9-6ca3d099c9ad
# ╠═ada78100-ede9-4b42-a04f-eb87461ce9fc
# ╠═e10dd2e3-9753-4745-97ee-c40ad1621491
# ╠═26390557-abfa-4495-b94f-1dd4e639faa3
# ╠═d377fe49-08fe-49d4-b85d-990f3f8b4503
# ╠═46a5ffa0-7c12-4561-9fb8-8ac6f4fa57f9
# ╠═11cf79d3-efd5-494f-abed-c22a4a29ce21
# ╠═51fcd87e-a560-442f-a933-e1c6dc95bba5
# ╠═7b0a5157-ab2c-414e-9f4c-74b041a91cd1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
