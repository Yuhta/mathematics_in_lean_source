import analysis.normed_space.finite_dimension
import analysis.convolution
import measure_theory.function.jacobian
import measure_theory.integral.bochner
import measure_theory.measure.lebesgue

open set filter
open_locale topological_space filter ennreal
open measure_theory

noncomputable theory

variables {α : Type*} [measurable_space α]
variables {μ : measure α}

/- TEXT:
.. _integration:

Integration
-----------

Now that we have measurable spaces and measures we can consider integrals. As explained above, mathlib uses a very general notion of
integration that allows any Banach space as the target.
As usual, we don't want our notation to
carry around assumptions, so we define integration in such a way
that an integral is equal to zero if the function in question is
not integrable.
Most lemmas having to do with integrals have integrability assumptions.
EXAMPLES: -/
-- QUOTE:
section

variables {E : Type*} [normed_group E] [normed_space ℝ E] [complete_space E]
  {f : α → E}

example {f g : α → E} (hf : integrable f μ) (hg : integrable g μ) :
  ∫ a, f a + g a ∂μ = ∫ a, f a ∂μ + ∫ a, g a ∂μ :=
integral_add hf hg
-- QUOTE.

/- TEXT:
As an example of the complex interactions between our various conventions, let us see how to integrate constant functions.
Recall that a measure ``μ`` takes values in ``ℝ≥0∞``, the type of extended non-negative reals.
There is a function ``ennreal.to_real : ℝ≥0∞ → ℝ`` which sends ``⊤``,
the point at infinity, to zero.
For any ``s : set α``, if ``μ s = ⊤``, then nonzero constant functions are not integrable on ``s``.
In that case, their integrals are equal to zero by definition, as is ``(μ s).to_real``.
So in all cases we have the following lemma.
EXAMPLES: -/
-- QUOTE:
example {s : set α} (c : E) :
  ∫ x in s, c ∂μ = (μ s).to_real • c :=
set_integral_const c
-- QUOTE.

/- TEXT:
We now quickly explain how to access the most important theorems in integration theory, starting
with the dominated convergence theorem. There are several versions in mathlib,
and here we only show the most basic one.
EXAMPLES: -/
-- QUOTE:
example {F : ℕ → α → E} {f : α → E} (bound : α → ℝ)
  (hmeas : ∀ n, ae_strongly_measurable (F n) μ)
  (hint : integrable bound μ)
  (hbound : ∀ n, ∀ᵐ a ∂μ, ∥F n a∥ ≤ bound a)
  (hlim : ∀ᵐ a ∂μ, tendsto (λ (n : ℕ), F n a) at_top (𝓝 (f a))) :
  tendsto (λ n, ∫ a, F n a ∂μ) at_top (𝓝 (∫ a, f a ∂μ)) :=
tendsto_integral_of_dominated_convergence bound hmeas hint hbound hlim
-- QUOTE.

/- TEXT:
Then we have Fubini's theorem for integrals on product type.
EXAMPLES: -/
-- QUOTE:
example
  {α : Type*} [measurable_space α]
  {μ : measure α} [sigma_finite μ]
  {β : Type*} [measurable_space β] {ν : measure β} [sigma_finite ν]
  (f : α × β → E) (hf : integrable f (μ.prod ν)) :
  ∫ z, f z ∂μ.prod ν = ∫ x, ∫ y, f (x, y) ∂ν ∂μ :=
integral_prod f hf
-- QUOTE.

end
/- TEXT:
There is a very general version of convolution that applies to any
continuous bilinear form.
EXAMPLES: -/
section
-- QUOTE:
open_locale convolution

-- EXAMPLES:
variables {𝕜 : Type*} {G : Type*} {E : Type*} {E' : Type*} {F : Type*} [normed_group E]
  [normed_group E'] [normed_group F] [nondiscrete_normed_field 𝕜]
  [normed_space 𝕜 E] [normed_space 𝕜 E'] [normed_space 𝕜 F]
  [measurable_space G] [normed_space ℝ F] [complete_space F] [has_sub G]

example (f : G → E) (g : G → E') (L : E →L[𝕜] E' →L[𝕜] F) (μ : measure G) :
  f ⋆[L, μ] g = λ x, ∫ t, L (f t) (g (x - t)) ∂μ :=
rfl
-- QUOTE.

end
/- TEXT:
Finally, mathlib has a very general version of the change-of-variables formula.
In the statement below, ``borel_space E`` means the
:math:`\sigma`-algebra on ``E`` is generated by the open sets of ``E``,
and ``is_add_haar_measure μ`` means that the measure ``μ`` is left-invariant,
gives finite mass to compact sets, and give positive mass to open sets.
EXAMPLES: -/
-- QUOTE:
example {E : Type*} [normed_group E] [normed_space ℝ E] [finite_dimensional ℝ E]
  [measurable_space E] [borel_space E] (μ : measure E) [μ.is_add_haar_measure]
  {F : Type*}[normed_group F] [normed_space ℝ F] [complete_space F]
  {s : set E} {f : E → E} {f' : E → (E →L[ℝ] E)}
  (hs : measurable_set s)
  (hf : ∀ (x : E), x ∈ s → has_fderiv_within_at f (f' x) s x)
  (h_inj : inj_on f s)
  (g : E → F) :
  ∫ x in f '' s, g x ∂μ = ∫ x in s, |(f' x).det| • g (f x) ∂μ :=
integral_image_eq_integral_abs_det_fderiv_smul μ hs hf h_inj g
-- QUOTE.
