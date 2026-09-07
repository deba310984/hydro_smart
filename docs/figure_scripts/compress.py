"""Compress the paper to seven pages without dropping a figure.

Cuts body prose by roughly 40%, caps figure heights, moves the per-class chart
to a full-width band, and tightens leading. All 14 figures and 6 tables stay.
"""
import io, re

P = 'make_ieee_paper.js'
s = io.open(P, encoding='utf-8').read()

# ── 1. cap figure heights so no single figure dominates a page ──
old = """function figure(file, widthIn) {
  const p = path.join(FIGS, file);
  const { w, h } = pngSize(p);
  const wPt = widthIn * 72, hPt = (h / w) * wPt;"""
new = """function figure(file, widthIn, maxHin) {
  const p = path.join(FIGS, file);
  const { w, h } = pngSize(p);
  let wIn = widthIn, hIn = (h / w) * wIn;
  // Cap height: the confusion matrix was 6.2 in tall at full width, most of a page.
  if (maxHin && hIn > maxHin) { hIn = maxHin; wIn = (w / h) * hIn; }
  const wPt = wIn * 72, hPt = hIn * 72;"""
assert s.count(old) == 1, 'figure()'
s = s.replace(old, new)

# ── 2. tighter leading and paragraph spacing ──
s = s.replace("spacing: { after: opts.after === undefined ? 60 : opts.after, line: 228 },",
              "spacing: { after: opts.after === undefined ? 20 : opts.after, line: 206 },")
s = s.replace("spacing: { after: 50, line: 228 },", "spacing: { after: 20, line: 206 },")
s = s.replace("spacing: { before: 260, after: 110 },", "spacing: { before: 150, after: 60 },")   # H1
s = s.replace("spacing: { before: 150, after: 70 },", "spacing: { before: 90, after: 40 },")     # H2
s = s.replace("spacing: { before: 120, after: 60 },\n    children: [new ImageRun({",
              "spacing: { before: 70, after: 30 },\n    children: [new ImageRun({}",)
s = s.replace("children: [new ImageRun({}", "children: [new ImageRun({")   # undo typo guard
s = s.replace("    spacing: { after: 150 },\n    children: [\n      new TextRun({ text: `Fig. ${n}.  `",
              "    spacing: { after: 90 },\n    children: [\n      new TextRun({ text: `Fig. ${n}.  `")
s = s.replace("spacing: { before: 150, after: 20 },\n      children: [new TextRun({\n        text: `TABLE",
              "spacing: { before: 90, after: 10 },\n      children: [new TextRun({\n        text: `TABLE")
s = s.replace("margins: { top: 40, bottom: 40, left: 70, right: 70 },",
              "margins: { top: 25, bottom: 25, left: 60, right: 60 },")
s = s.replace("margins: { top: 30, bottom: 30, left: 70, right: 70 },",
              "margins: { top: 18, bottom: 18, left: 60, right: 60 },")
s = s.replace("spacing: { before: 26, after: 26 },", "spacing: { before: 12, after: 12 },")

# ── 3. figure calls: add height caps; per-class becomes full width ──
s = s.replace("figure('fig_architecture.png', FULL_IN)", "figure('fig_architecture.png', FULL_IN, 2.7)")
s = s.replace("figure('fig_sensor_profile.png', FULL_IN)", "figure('fig_sensor_profile.png', FULL_IN, 2.6)")
s = s.replace("figure('fig_confusion_matrix.png', FULL_IN)", "figure('fig_confusion_matrix.png', FULL_IN, 3.5)")
s = s.replace("figure('fig_per_class.png', COL_IN)", "figure('fig_per_class.png', FULL_IN, 2.3)")
s = s.replace("figCap('pc', 'Per-class F1 with precision and recall overlaid, sorted ascending. Bars below F1 0.80 are highlighted. The dashed line marks the macro average.', COL_IN)",
              "figCap('pc', 'Per-class F1 with precision and recall overlaid, sorted descending. Bars below F1 0.80 are highlighted; the dashed line marks the macro average.', FULL_IN)")
for f in ['fig_pipeline', 'fig_coverage', 'fig_model_comparison', 'fig_accuracy_vs_size',
          'fig_ablation', 'fig_importance', 'fig_learning_curve', 'fig_reliability',
          'fig_overlap', 'fig_latency']:
    s = s.replace(f"figure('{f}.png', COL_IN)", f"figure('{f}.png', COL_IN, 2.25)")

# ── 4. compressed prose ──
BLOCKS = {}

BLOCKS['part1'] = r"""
  new Paragraph({
    alignment: AlignmentType.BOTH,
    spacing: { after: 50, line: 200 },
    children: [
      new TextRun({ text: 'Abstract—', font: FONT, size: SMALL, bold: true, italics: true }),
      new TextRun({
        text: `Hydroponic cultivation removes soil as a buffer, so temperature, humidity and nutrient pH must be held inside narrow bands. Small Indian growers rarely have instrumentation at that resolution. We present HydroSmart, which couples an ESP32 pH telemetry node to a cloud crop recommender and a Flutter client. No public dataset maps ambient conditions and Indian location to hydroponic crop suitability, so we build ${Number(R.n_samples).toLocaleString()} samples from an explicit agronomic knowledge base of ${R.n_crops} crops across ${R.n_states} states, and report that synthetic provenance rather than presenting it as observational. The deployed gradient-boosted classifier reaches ${acc}% top-1 and ${top3}% top-3 accuracy, ${cvm}% ± ${cvs}% under five-fold cross-validation, Cohen kappa ${kap}. Three findings qualify this. A k-nearest-neighbour baseline reaches ${pc(knn.accuracy)}% at ${(knn.size_mb / ours.size_mb).toFixed(2)}× the artifact size, ${(ours.train_s / knn.train_s).toFixed(0)}× faster training and ${(R.latency['1'].mean / R.latency_knn['1'].mean).toFixed(0)}× faster inference: our deployed choice is not the best available, and we report it. Our five engineered features, including dew point and vapour pressure deficit, are worth ${gain.toFixed(2)} percentage points, inside one cross-validation standard deviation, yet permutation importance credits them with ${(engShare * 100).toFixed(0)}% of total importance; we trace the discrepancy to feature redundancy. Third, the residual error is not a capacity limit. An overlap coefficient computed from the knowledge base alone, using no model output, predicts per-class F1 at r = ${R.overlap_f1_corr.toFixed(2)} and off-diagonal confusion at r = ${R.overlap_confusion_corr.toFixed(2)}. The error floor belongs to the task, not the classifier.`,
        font: FONT, size: SMALL,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.BOTH,
    spacing: { after: 90, line: 200 },
    children: [
      new TextRun({ text: 'Index Terms—', font: FONT, size: SMALL, bold: true, italics: true }),
      new TextRun({ text: 'Precision agriculture, hydroponics, gradient boosting, Internet of Things, ESP32, crop recommendation, vapour pressure deficit, feature redundancy, synthetic data.', font: FONT, size: SMALL }),
    ],
  }),

  H1('Introduction'),
  P('Hydroponics replaces soil with a recirculating nutrient solution, and the medium therefore stops buffering error. A pH excursion that soil damps over hours by cation exchange reaches the root zone in minutes. Iron, manganese and boron precipitate above pH 6.5; phosphorus uptake collapses below pH 5.0. Holding the reservoir inside a narrow band is a precondition for the crop surviving, not an optimisation.'),
  P('That requirement collides with the economics of small-scale Indian horticulture. Continuous-read probes, controllers and the expertise to interpret them are priced for commercial installations, so the grower who would gain most from closed-loop monitoring can least afford it. Separately, the decision that most determines a season’s return — which crop to plant given locally achievable conditions — is usually made from habit rather than measurement.'),
  P('HydroSmart addresses both. An ESP32 node samples a pH probe, filters and calibrates at the edge, and streams to a Firebase Realtime Database; a Flutter client renders that stream and, independently, queries a classifier that recommends crops from temperature, humidity, state and month. We contribute:'),
  ...LIST([
    'A four-tier architecture decoupling live telemetry from inference, so sensor loss degrades one feature rather than the application.',
    `A recommender reaching ${acc}% top-1 and ${top3}% top-3 over ${R.n_crops} classes in a ${ours.size_mb.toFixed(1)} MB artifact, deployable in a 512 MB container.`,
    'A seven-classifier comparison reporting deployment cost alongside accuracy, in which k-NN beats our own deployed model — a negative result for our design choice.',
    'A feature-engineering null result, and an account of why permutation importance and retraining ablation disagree by an order of magnitude.',
    'An overlap analysis attributing the residual error to genuine ambiguity between crop envelopes rather than model capacity.',
  ]),

  H1('Related Work'),
  P('Published crop recommenders overwhelmingly target soil agriculture, trained on soil macronutrients, pH and rainfall. Those features are unavailable, and rainfall meaningless, inside a controlled enclosure: a model consuming nitrogen, phosphorus and potassium has no input in our setting. Ensemble methods dominate that literature, with random forests [1] and gradient boosting [2], [3] outperforming single trees and linear models on tabular agronomic data. Our comparison in Section V partially contradicts that expectation, which is why we ran it rather than assuming the result.'),
  P('IoT deployments for controlled-environment agriculture typically report the telemetry pipeline alone — microcontroller, broker, dashboard — and rarely state what the application does when the sensor is absent. We treat sensor loss as an expected failure mode. Vapour pressure deficit is the standard aggregate of temperature and humidity in plant physiology, since transpiration responds to the deficit rather than either quantity [4], and dew point via the Magnus approximation [5] is likewise established. Section VI-C reports what they contribute here, which is less than that literature suggests.'),

  H1('System Architecture and Dataset'),
  P(`${F('arch')} shows four tiers. The governing constraint is that no tier is a hard dependency of another: a grower without a probe still receives recommendations, and one without connectivity still sees cached market data.`),
"""

BLOCKS['part2'] = r"""
  H2('A', 'Tiers'),
  P('An industrial pH probe with 4–20 mA output is read by an ESP32 across a shunt resistor. The analogue input is confined to ADC1, because ADC2 is unavailable to application code while the Wi-Fi radio is active and silently returns zeros if used; this dictated the pin assignment. Firmware median-filters the sampling window to reject the transient spikes characteristic of ion-selective electrodes, then converts to pH by a stored two-point calibration.'),
  P('Readings publish to a Firebase Realtime Database in asia-southeast1, minimising round-trip latency from Indian deployments. Records carry server-assigned timestamps, since the ESP32 has no battery-backed clock and would report epoch-zero after a power cycle. The recommender is served by FastAPI under a 512 MB memory ceiling, a constraint that Section V shows eliminates otherwise competitive models outright. The client applies a sixty-second staleness gate: a silently frozen last-known value is worse than an acknowledged absence when the quantity governs an irreversible decision.'),
  H2('B', 'Why the corpus is synthetic'),
  P('Our task maps ambient temperature, relative humidity, Indian state and month to a hydroponic crop. We know of no public labelled dataset over that domain; the datasets used for crop recommendation carry soil chemistry and rainfall and contain neither a state nor a month field. We therefore built the corpus from an explicit knowledge base, and state this plainly because presenting synthesised data as observational is the more serious failure, and because the construction is auditable in a way an opaque dataset is not.'),
  P(`Each crop carries an ideal temperature band, humidity band, permitted states and sowing months, partitioned into ten agro-climatic zones (${T('zones')}).`),
"""

BLOCKS['part3'] = r"""
  P(`A sample is drawn by selecting a crop, sampling temperature and humidity within its band under Gaussian perturbation, and drawing a state and month from its permitted sets; the crop becomes the label (${F('pipe')}). The corpus is balanced at ${(R.n_samples / R.n_crops).toLocaleString()} per class, split ${Number(R.n_train).toLocaleString()} training and ${Number(R.n_test).toLocaleString()} test, stratified.`),
"""

BLOCKS['part4'] = r"""
  H2('C', 'An independent sensor corpus'),
  P(`To measure the gap between that distribution and physical reality we use a public CC0 record of ${Number(sens.usable_rows).toLocaleString()} readings from a hydroponic installation in India [6], logging temperature, humidity and heat index every thirty seconds (${T('sensor')}, ${F('sensorfig')}). It is discontinuous: ${sens.span_days.toFixed(0)} days of span carry data for only ${(sens.coverage_frac * 100).toFixed(0)}% of that time, the remainder falling in outages of 22 and 18 days, so effective coverage is about ${(sens.span_days * sens.coverage_frac).toFixed(0)} days.`),
"""

BLOCKS['part5'] = r"""
  P(`Measured temperature spans only ${sens.temp_min.toFixed(1)}–${sens.temp_max.toFixed(1)} °C at a standard deviation of ${sens.temp_std.toFixed(1)} °C, because one enclosure over one season does not traverse the range the knowledge base covers. ${F('cov')} overlays the two. The overlap is smaller than summary statistics suggest: measured humidity extends to ${sens.hum_min.toFixed(0)}%, below the synthetic floor, while the synthetic corpus covers temperatures under 10 °C the enclosure never reached. The distributions are largely disjoint. This corpus cannot serve as a validation set, since it does not span the input space the model must cover; and r = ${sens.corr.toFixed(3)} between temperature and humidity indicates the two vary near-independently under ventilation, supporting their use as separate inputs.`),
  H1('Feature Engineering'),
  P('Temperature, humidity, label-encoded state and month are supplied; five features are derived. Month as an integer implies December and January are eleven units apart, so we project it onto the unit circle as sin(2πm/12) and cos(2πm/12). A multiplicative temperature–humidity term reflects that the agronomic bands are jointly constrained. Dew point follows Magnus [5] and vapour pressure deficit is the difference between saturation and actual vapour pressure [4]; VPD is what transpiration actually responds to, so it should carry information neither input expresses alone. Section VI-C reports the measurement, which does not support that motivation.'),
  P('All numeric features are standardised. The encoded state index is deliberately excluded: it is a nominal code, and scaling it would impose a spurious ordering and magnitude on an unordered label.'),
  H1('Model Selection'),
  P(`Seven classifiers were evaluated under identical features, splits and seed (${T('comp')}, ${F('comp')}, ${F('size')}).`),
"""

BLOCKS['part7'] = r"""
  P(`Two results matter. First, deployment cost excludes models outright: random forest reaches ${pc(rf.accuracy)}% and extra trees ${pc(et.accuracy)}%, but serialise to ${rf.size_mb.toFixed(0)} MB and ${et.size_mb.toFixed(0)} MB, both past the 512 MB ceiling. Accuracy-only comparisons hide exactly this kind of exclusion.`),
  P(`Second, our deployed choice is not the best performer. k-NN at k = 15 attains ${pc(knn.accuracy)}%, ${((knn.accuracy - ours.accuracy) * 100).toFixed(2)} points above the gradient-boosted model, at ${knn.size_mb.toFixed(1)} MB against ${ours.size_mb.toFixed(1)} MB and ${knn.train_s.toFixed(1)} s against ${ours.train_s.toFixed(0)} s. It is better on every axis we measured except that it must retain the training set. We report this rather than omit it. The result is explicable: recovering a rule set of axis-aligned bands in nine dimensions, from a corpus dense enough that a query almost always has near neighbours from its own generating band, suits local interpolation, and the inductive bias of boosting buys little.`),
  P('The deployed configuration uses 400 boosting iterations, learning rate 0.10, minimum 20 samples per leaf, L2 0.1. Early stopping is off — not because the model does not overfit, since Section VI-D shows it interpolates the training set almost exactly, but because held-out accuracy never degrades. Gradient boosting is retained for its calibrated probabilities, on which the client’s confidence display depends.'),

  H1('Results'),
  H2('A', 'Overall'),
  P(`${T('head')} gives headline performance. Top-1 is ${acc}% and top-3 ${top3}%. The gap matters operationally: the client shows three ranked candidates, so ${top3}% describes what a grower experiences — a figure worth stating carefully, since with ${R.n_crops} classes and a dominant location signal three guesses almost always contain the answer. Cohen kappa ${kap} against 5% chance agreement shows the result is not an artefact of class priors, and cross-validation at ${cvm}% ± ${cvs}% confirms the split is not favourable.`),
"""

BLOCKS['part8'] = r"""
  H2('B', 'Per class'),
  P(`${F('pc')} and ${F('cm')} decompose the aggregate. Kale, Coriander and Arugula exceed F1 0.95; Pea, Strawberry and Microgreens fall to ${R.per_class.find((c) => c.crop === 'Pea').f1.toFixed(2)}, ${R.per_class.find((c) => c.crop === 'Strawberry').f1.toFixed(2)} and ${R.per_class.find((c) => c.crop === 'Microgreens').f1.toFixed(2)}. Errors are not diffuse: Pea is confused with Lettuce and Cauliflower, Strawberry with Broccoli. A model failing through insufficient capacity would spread error broadly across the matrix; this one does not.`),
"""

BLOCKS['part9'] = r"""
  H2('C', 'Feature ablation: a null result'),
  P(`${T('abl')} and ${F('abl')} retrain from scratch on each feature subset. The full nine features reach ${pc(abl[3].accuracy)}% against ${pc(abl[0].accuracy)}% for the four raw inputs — a gain of ${gain.toFixed(2)} points, where five-fold cross-validation has a standard deviation of ${(R.cv_std * 100).toFixed(2)} points. The entire ablation range sits inside one standard deviation, and the sequence is not monotonic: adding the interaction term to the cyclical encoding costs ${((abl[1].accuracy - abl[2].accuracy) * 100).toFixed(2)} points. We cannot claim dew point and VPD improve this model. They are not resolvable above noise, and the four raw inputs already carry essentially all the signal.`),
"""

BLOCKS['part10'] = r"""
  H2('D', 'Why permutation importance disagrees'),
  P(`Permutation importance reaches the opposite conclusion (${F('imp')}): month cosine ranks third at ${R.importance.find((d) => d.feature === 'month_cos').mean.toFixed(3)}, VPD fourth at ${R.importance.find((d) => d.feature === 'vpd').mean.toFixed(3)}, and the derived features together take ${(engShare * 100).toFixed(0)}% of attributed importance. Both measures are computed correctly, and they differ by an order of magnitude on the same features.`),
"""

BLOCKS['part11'] = r"""
  P('Redundancy explains it. Permutation operates on a fixed trained model: when VPD is shuffled, the model has already committed its splits to using it and cannot fall back on temperature and humidity, though both remain present and jointly determine VPD. The drop is real but measures reliance, not necessity. Ablation retrains without the feature, letting the model route the same information through its correlates — and since VPD, dew point and the interaction term are all deterministic functions of temperature and humidity, that rerouting is free.'),
  P(`Reported alone, permutation importance would support a ${(engShare * 100).toFixed(0)}% contribution that ablation values at ${gain.toFixed(2)} points. We report both, as reliance and necessity. Practically, the five derived features can leave the production pipeline at no measurable cost — a simplification, not a disappointment. Setting them aside, state dominates at ${R.importance[0].mean.toFixed(3)} and humidity follows at ${R.importance[1].mean.toFixed(3)}, since each crop is admissible in only a subset of the ${R.n_states} states.`),
  H2('E', 'Learning curve'),
  P(`${F('lc')} plots accuracy against corpus size. Held-out accuracy rises monotonically from ${pc(R.learning_curve[0].test)}% at ${Number(R.learning_curve[0].n).toLocaleString()} samples to ${pc(R.learning_curve[R.learning_curve.length - 1].test)}% at ${Number(R.learning_curve[R.learning_curve.length - 1].n).toLocaleString()}, the last doubling buying under half a point. The training curve tells a different story: ${pc(R.learning_curve[R.learning_curve.length - 1].train)}% at the full corpus, a gap narrowing from ${((R.learning_curve[0].train - R.learning_curve[0].test) * 100).toFixed(1)} to ${((R.learning_curve[R.learning_curve.length - 1].train - R.learning_curve[R.learning_curve.length - 1].test) * 100).toFixed(1)} points but never closing. The model interpolates its training set almost exactly while generalising to roughly ${pc(R.accuracy, 0)}%.`),
  P('This is memorisation, but not the harmful kind: held-out accuracy never degrades, so early stopping would cost accuracy rather than recover it. The cause is specific. Where two crops share an envelope, the training set holds near-identical feature vectors with different labels; the model can memorise which point carried which label, and that transfers to no new point. A persistent train–test gap is the signature of irreducible label ambiguity, not of weak regularisation.'),
"""

BLOCKS['part12'] = r"""
  H2('F', 'Calibration'),
  P(`A recommender that displays confidence must be calibrated or the display misleads. Expected calibration error is ${R.ece.toFixed(3)}, with mean predicted confidence ${R.mean_confidence.toFixed(3)} against realised accuracy ${R.accuracy.toFixed(3)} (${F('rel')}). The model is neither materially over- nor under-confident, so the probability beside each recommendation can be read at face value.`),
"""

BLOCKS['part13'] = r"""
  H2('G', 'Where the residual error comes from'),
  P(`For every crop pair we computed an overlap coefficient as the product of the Jaccard overlaps of their temperature bands, humidity bands, permitted states and sowing months — derived from the knowledge base alone, using no model output. It predicts model behaviour closely: cumulative overlap correlates with per-class F1 at r = ${R.overlap_f1_corr.toFixed(2)}, and pairwise overlap with off-diagonal confusion at r = ${R.overlap_confusion_corr.toFixed(2)} (${F('ov')}). Pea and Strawberry carry the highest overlap and the lowest F1; Kale and Coriander, whose envelopes are disjoint from all others, are classified essentially perfectly.`),
  P('The error floor is a property of the task. Two crops thriving in the same conditions, state and month are not separable from those inputs, and no model consuming only those inputs can separate them. This also explains the ablation: derived features cannot resolve an ambiguity that exists in the label definition.'),
"""

BLOCKS['part14'] = r"""
  H2('H', 'Sensor augmentation and inference cost'),
  P(`Retraining with measured sensor samples injected alongside profile sampling moved accuracy to ${pc(R.augmented.accuracy)}%. We do not claim this as an improvement from real data: injection adds rather than substitutes samples, so corpus size (${Number(R.augmented.n_samples).toLocaleString()} against ${Number(R.n_samples).toLocaleString()}) and distribution change together. The comparison is uncontrolled; the deployed model uses the synthetic corpus alone.`),
  P(`${T('lat')} and ${F('lat')} report single-threaded latency. This needed correction: with the default thread pool our first pass recorded ${R.latency_threaded['1'].mean.toFixed(0)} ms for one prediction and ${R.latency_threaded['512'].mean.toFixed(0)} ms for 512, and a 512-fold increase in work costing ${((R.latency_threaded['512'].mean / R.latency_threaded['1'].mean - 1) * 100).toFixed(0)}% more time identifies that as per-call thread-pool setup, not inference.`),
  P(`Corrected, one prediction costs ${R.latency['1'].mean.toFixed(0)} ms, falling to ${(R.latency['512'].per_sample_ms).toFixed(2)} ms per sample only under batching, because a single query traverses roughly ${(400 * R.n_crops).toLocaleString()} trees. We had assumed inference negligible against network round-trip; for the single-query pattern actually served, it dominates. k-NN answers the same query in ${R.latency_knn['1'].mean.toFixed(2)} ms, about ${(R.latency['1'].mean / R.latency_knn['1'].mean).toFixed(0)} times faster. Latency was not among our original selection criteria; had it been, the comparison would have been decided on this axis alone.`),
"""

BLOCKS['part15'] = r"""
  H1('Discussion and Conclusion'),
  P(`Our ${acc}% is accuracy at recovering an encoded agronomic rule set, measured on held-out samples from the same generative process. It is not accuracy against field outcomes and should not be read as such. The model’s ceiling is the knowledge base it was distilled from. We consider this the most important limitation of the work and state it in preference to a figure that looks stronger without it.`),
  ...LIST([
    'Construct validity. Labels are agronomic prescriptions, not observed yields; a crop the knowledge base excludes from a state is never recommended there, whether or not it would grow.',
    `External validity. The independent corpus covers roughly ${(sens.span_days * sens.coverage_frac).toFixed(0)} days from one enclosure at ${sens.temp_mean.toFixed(1)} °C mean, and its multi-week outages preclude seasonal analysis.`,
    'Internal validity. Train and test are drawn from one generative process, so the split measures generalisation within that process, not to physical reality.',
    'Hardware. The pH pipeline is validated on a single probe and calibration; electrode drift over a season is uncharacterised.',
  ]),
  P(`Three design consequences follow. Because error concentrates in overlapping pairs, a single recommendation would mislead precisely where the model is least certain, so the client shows three ranked candidates and effective accuracy is ${top3}%. Because calibration is good at ECE ${R.ece.toFixed(3)}, that display is meaningful rather than decorative. And least comfortably, Section V shows the deployed model is beaten by k-NN on accuracy, size, training time and latency; it does not yield calibrated probabilities as directly, which is why the current system retains boosting, but that is a weaker justification than a measured advantage would have been.`),
  P(`We presented an integrated hydroponics system reaching ${acc}% top-1 and ${top3}% top-3 over ${R.n_crops} crops in a ${ours.size_mb.toFixed(1)} MB artifact. The contribution is less the accuracy than the account of what constrains it: the residual error follows genuine agronomic ambiguity, with knowledge-base overlap predicting per-class F1 at r = ${R.overlap_f1_corr.toFixed(2)}; physics-derived features credited with ${(engShare * 100).toFixed(0)}% of permutation importance survive ablation worth ${gain.toFixed(2)} points; and a k-NN baseline outperforms our deployed model.`),
  P('The priority for future work follows from the first limitation. The knowledge base should be replaced, or corrected, by observed outcomes — a longitudinal record of what was planted, under what measured conditions, and what it yielded. That converts rule recovery into genuine supervised learning and lifts the ceiling this work operates under. Secondary directions include adopting or calibrating k-NN, closed-loop dosing under the confidence estimates, characterising electrode drift across a season, and extending the node to electrical conductivity and dissolved oxygen.'),

  H1('References'),
"""

for name, body in BLOCKS.items():
    pat = re.compile(r'^const ' + name + r' = \[\n.*?^\];$', re.S | re.M)
    m = pat.search(s)
    if not m:
        raise SystemExit(f'block {name} not found')
    s = s[:m.start()] + 'const ' + name + ' = [' + body + '];' + s[m.end():]

# part6 folded into part5; empty it
s = re.sub(r'^const part6 = \[\n.*?^\];$', 'const part6 = [];', s, flags=re.S | re.M)

# ── 5. per-class chart moves into the full-width band with the matrix ──
s = s.replace("sections.push(twoCol([...part5, ...covFig, ...part6, ...compTable, ...compFigs,\n                      ...part7, ...headTable, ...part8, ...pcFig]));\nsections.push(oneCol(cmFig));",
              "sections.push(twoCol([...part5, ...covFig, ...part6, ...compTable, ...compFigs,\n                      ...part7, ...headTable, ...part8]));\nsections.push(oneCol([...pcFig, ...cmFig]));")

# ── 6. trim two table rows that the prose already states ──
s = s.replace("      ['Top-5 accuracy', `${top5} %`],\n", "")
s = s.replace("      ['Weighted F1', wf1],\n", "")
s = s.replace("      ['field3 — heat index', 'Mean 30.9, range 27.1–40.7'],\n", "")

io.open(P, 'w', encoding='utf-8').write(s)
print('compressed')
